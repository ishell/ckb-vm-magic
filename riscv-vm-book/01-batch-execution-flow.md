# 批次一：执行主线与系统骨架（第 1-4 章扩展稿）

## 第 1 章 共识系统中的虚拟机：第一性原理不是快，而是准

### 1.1 工程事实

在 `ckb-vm` 里，很多设计都直接服务于“可复现执行”：

- 通过 `SupportMachine::add_cycles`（`src/machine/mod.rs`）把每条指令计费与上限检查绑定。
- 通过 `Error::CyclesExceeded` / `Error::CyclesOverflow`（`src/error.rs`）把资源耗尽变成协议级可观测事件。
- 通过 `Pause`（`src/machine/mod.rs`）让运行可以中断且可恢复，而不是依赖宿主线程的不可控行为。

### 1.2 深度解析

区块链 VM 与本地 VM 的区别在于：

- 本地 VM 追求“平均速度”；
- 共识 VM 追求“所有节点在同输入下得到同输出”。

这意味着“可定价”与“可中断”并不是附加功能，而是共识安全的一部分。`ckb-vm` 把 cycles 作为一等公民放到 `SupportMachine` trait 里，而不是放在外层 wrapper，这个决定避免了“执行语义”和“计费语义”分裂。

### 1.3 一针见血结论

如果你的 VM 无法把“执行结果 + 资源消耗”一起确定化，它就不适合放在共识层。

---

## 第 2 章 从 `run()` 到退出码：一条最短可审计执行链

### 2.1 入口路径（Rust API）

`src/lib.rs` 中 `run()`/`run_with_memory()`的路径是理解全项目的起点：

1. 创建 `DefaultCoreMachine::<R, WXorXMemory<M>>`；
2. 用 `RustDefaultMachineBuilder` 构造 `DefaultMachine`；
3. 外包一层 `TraceMachine`；
4. `load_program()` 完成装载 + 栈初始化；
5. `run()` 进入解释循环并返回退出码。

### 2.2 关键流程图

```text
run_with_memory
  -> DefaultCoreMachine::new_with_memory
  -> RustDefaultMachineBuilder::build
  -> TraceMachine::new
  -> load_program
       -> load_elf(parse_elf + init_pages)
       -> initialize_stack
  -> run
       -> decode
       -> add_cycles
       -> execute
       -> ecall/ebreak
  -> exit_code
```

### 2.3 运行循环的关键控制点

在 `DefaultMachineRunner::run_with_decoder`（`src/machine/mod.rs`）中，循环体明确了三件事：

- 可中断：先检查 `pause`；
- 可重置：`reset_signal()` 后清 decoder cache；
- 可计费：每步 `step()` 前后都受 cycles 上限约束。

这不是普通解释器的“while(true) fetch-decode-execute”，而是“可抢占、可审计、可恢复”的执行器。

### 2.4 `ecall` 边界

`Machine::ecall` 默认只内建处理 syscall 编号 93（退出）。其余 syscall 交由注册的 `Syscalls` trait 逐个尝试处理。这个模型有两个好处：

- VM 内核保持最小化；
- 宿主能力显式注入，避免隐式系统依赖。

### 2.5 一针见血结论

`ckb-vm` 的运行链条不是“方便调用”，而是“方便审计”：入口短、边界清、状态机可穷尽。

---

## 第 3 章 ELF 装载与页权限：把程序翻译成受控内存动作

### 3.1 从 ELF 到 `ProgramMetadata`

`parse_elf`（`src/elf.rs`）不直接依赖高层 `Elf::parse`，而是手工解析 headers 后生成 `ProgramMetadata { actions, entry }`。每个 `LoadingAction` 都明确：

- 目标地址 `addr`
- 目标大小 `size`（页对齐后）
- 页标志 `flags`
- 源字节区间 `source`
- 页面内偏移 `offset_from_addr`

这使“装载过程”可序列化、可缓存、可重放。

### 3.2 权限策略的硬约束

`convert_flags` 做了两个关键拒绝：

- 段不可读直接拒绝；
- `writable && executable` 直接拒绝。

`WXorXMemory` 进一步在读写执行时做页权限检查：

- `execute_loadXX` 必须在可执行页；
- `storeXX/store_bytes` 必须在可写页；
- 权限不匹配即 `MemWriteOnExecutablePage`。

这就是操作系统 W^X 原则在区块链 VM 里的落地。

### 3.3 栈初始化的协议兼容性

`initialize_stack`（`src/machine/mod.rs`）包含版本化分支：

- `VERSION1+` 对 SP 做 16 字节对齐；
- `argv[argc] = null`；
- `VERSION2+` 对越界参数提早报 `MemOutOfStack`。

说明该项目在“修 bug”时优先保留历史链上行为，通过 version gate 兼容旧语义。

### 3.4 一针见血结论

这个 VM 的装载器不是“把文件放进内存”，而是“把外部输入缩减成可验证内存状态转换”。

---

## 第 4 章 解码与执行：解释器性能来自结构化优化，而非神秘技巧

### 4.1 指令获取的页边界优化

`DefaultDecoder::decode_bits`（`src/decoder.rs`）区分两条路径：

- 普通路径：一次 `execute_load32`，再判定是否 RVC；
- 页尾路径：先 `load16`，必要时再跨页取后半段。

这是“正确性优先 + 局部快路径”的典型写法：热点快，边界稳。

### 4.2 解码缓存与 MOP 融合

`instructions_cache` 使用 PC 派生 key，降低重复解码成本。
`decode_mop` 则把多条常见指令模式融合成单条宏操作（如 `WIDE_MUL`、`ADD3A/B/C`），减少解释器调度开销。

这类融合尤其针对大整数和密码学常见算术链，直接对应链上高频负载。

### 4.3 执行阶段：先推进 PC，再提交

`execute`（`src/instructions/execute.rs`）的顺序是：

1. 依据指令长度预计算 `next_pc`；
2. `update_pc(next_pc)`；
3. 执行 opcode handler；
4. `commit_pc()`。

这让分支/跳转类指令可以覆盖默认 `next_pc`，保持语义统一。

### 4.4 TraceMachine：解释器里的“线程化执行”

`TraceMachine`（`src/machine/trace.rs`）把基本块缓存成 trace：

- 每个 trace 缓存最多 16 条指令；
- 每条指令预绑定对应处理函数（thread）；
- 命中后避免反复 decode + dispatch。

这不是 JIT，但在不牺牲确定性的前提下接近 JIT 的局部收益。

### 4.5 一针见血结论

`ckb-vm` 的性能策略不是“冒险动态优化”，而是“在确定性边界内做静态可审计优化”。

---

## 本批次小结

- 这套系统把“执行、计费、权限、中断”统一进同一状态机。
- 它的关键价值不在跑分，而在节点间可重放与行为可解释。
- 对区块链而言，这种架构是现实主义：牺牲一部分峰值速度，换取协议级确定性。


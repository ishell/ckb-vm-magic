# 《Rust 与 RISC-V：区块链虚拟机的工程必然性》写作总纲

## 0. 写作定位

- 目标读者：有系统编程、区块链、密码学基础的工程师与架构师。
- 目标风格：严肃、专业、可审计，不做口号式技术宣传。
- 核心任务：基于 `ckb-vm` 代码，回答一个尖锐问题——为什么这类共识关键系统会选择 Rust + RISC-V。

## 1. 一针见血的总论点

1. 区块链虚拟机首先是“共识机器”，不是“本地性能机器”；其第一性原理是可复现、可验证、可定价。
2. RISC-V 被选中，不是因为“新潮”，而是因为其 ISA 语义稳定、编码规整、生态开放，便于做确定性解释执行与形式化验证。
3. Rust 被选中，不是因为“安全感”，而是因为它能把共识软件最昂贵的风险（未定义行为、内存破坏、并发不确定性）前移到编译期。
4. `ckb-vm` 不是在“模拟 CPU”这么简单，而是在构建一个微型操作系统式执行环境：装载、页权限、陷入、调度（cycles）、快照恢复。

## 2. 代码锚点（全书分析索引）

- 入口与对外 API：`src/lib.rs`
- 机器抽象层：`src/machine/mod.rs`
- Trace 执行器：`src/machine/trace.rs`
- 汇编执行器与桥接：`src/machine/asm/mod.rs`, `src/machine/asm/traces.rs`, `build.rs`
- ELF 解析与装载：`src/elf.rs`
- 内存与权限模型：`src/memory/mod.rs`, `src/memory/flat.rs`, `src/memory/sparse.rs`, `src/memory/wxorx.rs`
- 指令解码：`src/decoder.rs`
- 指令执行：`src/instructions/execute.rs`, `src/instructions/common.rs`, `src/instructions/register.rs`
- 资源定价：`src/cost_model.rs`
- 系统调用边界：`src/syscalls/mod.rs`
- 快照机制：`src/snapshot.rs`, `src/snapshot2.rs`

## 3. 全书章节大纲

## 第一篇：问题与约束（Why VM Architecture Matters）

### 第 1 章 共识系统中的虚拟机：先验约束不是性能，而是确定性
- 核心问题：什么是区块链 VM 的第一性原理？
- 关键点：确定性、可计费、可回放、抗 DoS。
- 代码锚点：`Error::CyclesExceeded`, `SupportMachine::add_cycles`, `Pause`。

### 第 2 章 从 `run()` 到 `exit code`：代码主流程的最短路径
- 核心问题：一次合约执行在本项目中的完整路径是什么？
- 关键点：创建 machine、加载 ELF、初始化栈、decode/execute 循环、ecall 退出。
- 代码锚点：`src/lib.rs`, `DefaultMachine::load_program`, `DefaultMachineRunner::run_with_decoder`。

## 第二篇：操作系统化执行模型（How It Behaves Like a Tiny OS）

### 第 3 章 ELF 装载与页权限：从程序文件到受控地址空间
- 核心问题：ELF 如何被翻译成内存页动作？
- 关键点：`ProgramMetadata::actions`, `convert_flags`, W^X, freeze。
- 代码锚点：`parse_elf`, `load_binary_inner`, `WXorXMemory::init_pages`。

### 第 4 章 指令获取、解码、融合与执行：解释器不等于“慢速 for 循环”
- 核心问题：解释执行为何仍有工程级优化空间？
- 关键点：decode cache、RVC 支持、MOP 融合、Trace threading。
- 代码锚点：`DefaultDecoder`, `decode_mop`, `TraceMachine`, `execute_instruction`。

### 第 5 章 系统调用、陷入与宿主边界：最小化可信计算基
- 核心问题：VM 与宿主如何交互且不丢失确定性？
- 关键点：`A7` 约定、`ecall` 分发、默认仅处理 `exit(93)`。
- 代码锚点：`Machine::ecall`, `Syscalls` trait。

### 第 6 章 快照与恢复：把 VM 当作可迁移进程
- 核心问题：为什么需要 snapshot，以及它如何降成本？
- 关键点：dirty page、source page、恢复一致性。
- 代码锚点：`snapshot.rs`, `snapshot2.rs`。

## 第三篇：为什么是 Rust（Why Rust Is a Consensus Language Here）

### 第 7 章 类型系统就是执行语义：`Register` trait 的设计哲学
- 核心问题：如何在一个实现中兼容 32/64 位寄存器并保持语义一致？
- 关键点：显式溢出语义、符号/无符号操作、位操作原语。
- 代码锚点：`src/instructions/register.rs`。

### 第 8 章 安全与性能并行：Rust 主体 + 汇编快路径
- 核心问题：为什么不用纯 Rust 或纯汇编？
- 关键点：汇编作为优化边界，Rust 作为语义锚点。
- 代码锚点：`build.rs`, `src/machine/asm/mod.rs`。

## 第四篇：为什么是 RISC-V（Why RISC-V Fits Blockchain VM）

### 第 9 章 开放 ISA 与工程可持续性：从授权问题到生态问题
- 核心问题：ISA 选择如何影响协议寿命？
- 关键点：开放标准、工具链成熟、ELF 兼容。
- 代码锚点：`README.md`, `decoder` 对 IMC/B/A 支持。

### 第 10 章 密码学工作负载与 RISC-V 扩展：B/M/A/MOP 的现实意义
- 核心问题：密码学合约为何偏爱这组扩展？
- 关键点：位操作、乘除长链、原子语义、宏操作融合。
- 代码锚点：`instructions/b.rs`, `execute.rs` 中 `WIDE_MUL/ADD3` 等。

## 第五篇：锋利结论与未来路线

### 第 11 章 一针见血的架构评估：优势、代价与下一步
- 核心问题：这套架构真正赢在哪里，又难在哪里？
- 关键点：双执行引擎一致性挑战、cycles 定价、形式化验证缺口。
- 输出：可执行改进路线图。

## 4. 分批完善计划（本次交付批次）

- 批次一（已写）：第 1–4 章，聚焦执行主线与 OS 化骨架。
- 批次二（已写）：第 7–10 章核心论证，聚焦 Rust 与 RISC-V 的必然性。
- 批次三（已写）：第 5、6、11 章，聚焦系统边界、快照、风险与路线图。

## 5. 本书的方法论

- 只讲“可被代码证明”的观点。
- 每章都包含“工程事实 -> 安全/性能含义 -> 架构判断”。
- 每章给出“一针见血结论”，避免空泛叙述。


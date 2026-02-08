# 第 2 章 从 run 到 exit：执行主流程的可审计链条

## 2.1 核心问题

一段合约二进制在 `ckb-vm` 中如何从字节变成退出码？

## 2.2 图 2-1：最短执行链

```text
run_with_memory
  -> DefaultCoreMachine::new_with_memory
  -> RustDefaultMachineBuilder::build
  -> TraceMachine::new
  -> load_program
       -> load_elf
       -> initialize_stack
  -> run_with_decoder loop
       -> decode
       -> add_cycles
       -> execute
       -> ecall/ebreak
  -> exit_code
```

代码入口位于 `src/lib.rs`。

## 2.3 代码证据

`DefaultMachine::load_program`（`src/machine/mod.rs`）将装载拆成两段：

- `load_elf`：写入代码与数据页
- `initialize`：初始化 syscall/debugger + stack

`DefaultMachineRunner::run_with_decoder` 保证每轮执行都经过三道门：

1. 中断检查（`Pause`）
2. 重置检查（`reset_signal`）
3. 指令步进（`step`）

## 2.4 深度分析

这条链条的价值在于“层次边界清晰”：

- 装载层只处理映像和内存状态。
- 执行层只处理取指、解码、执行。
- 系统调用层只在 `ecall` 发生时介入。

这种分层减少了隐藏副作用，提升了审计效率。

## 2.5 案例：为什么 `exit(93)` 是内建而不是插件

`Machine::ecall` 中只内建处理 93 号 syscall（退出），其余交由外部 `Syscalls` 插件处理。原因是：退出语义属于 VM 最小闭环能力，必须由内核稳定定义；外部能力应该是可替换模块，而非核心耦合逻辑。

## 2.6 术语表（本章）

- `Runner`：驱动 VM 生命周期的循环控制器。
- `CoreMachine`：寄存器、PC、内存等基础状态接口。
- `SupportMachine`：在 CoreMachine 之上增加 cycles、load、reset 等能力。

## 2.7 一针见血结论

`ckb-vm` 的主流程不是“调用方便”，而是“审计友好”：路径短、状态少、边界硬。

## 2.8 反例分析：单体运行循环与隐式副作用

反例场景：把装载、执行、宿主调用、调试输出混在同一循环里，短期开发快，但长期出现：

- 状态修改路径难追踪，审计复杂度指数上升。
- 线上 bug 难复现，尤其在异常路径和重入路径。

教训：主流程必须分层，且每层职责可单独验证。

## 2.9 架构评审清单（出版版）

- [ ] 主流程是否可画出无歧义状态图（load/run/exit）。
- [ ] `load_program` 与 `run` 的副作用边界是否清晰。
- [ ] `ecall` 和异常返回码是否有稳定定义。
- [ ] 是否支持在中断点安全恢复并保持结果一致。

## 2.10 参考实现清单（代码锚点）

- `src/lib.rs`: `run`, `run_with_memory`
- `src/machine/mod.rs`: `DefaultMachine::load_program`, `DefaultMachineRunner::run_with_decoder`, `Machine::ecall`
- `src/decoder.rs`: `InstDecoder`, `DefaultDecoder`

## 2.11 术语索引交叉（参见附录 B 与附录 D）

- `Runner`
- `CoreMachine`
- `SupportMachine`
- `Ecall`


## 2.12 审稿人问题清单（出版评审）

1. 执行主线是否在单张流程中闭环到 `exit_code`？
2. 是否清晰解释了 load/run/ecall 的边界职责？
3. 是否指出了中断与重置路径的审计价值？
4. 是否避免把宿主逻辑混入 VM 主循环叙事？
5. 本章代码锚点是否覆盖了入口、循环、退出三段？
6. 章节结论是否可用于指导实际架构评审？

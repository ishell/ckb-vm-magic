# CKB-VM 项目流程与 RISC-V 模块详解

> 面向 Rust 初学者与初级工程师的实践指南

本说明文档希望帮助刚接触 Rust 或 RISC-V 的同学快速理解 Nervos CKB-VM 项目的结构与运行流程。我们将从工程目录、程序执行流程、RISC-V 指令体系支持、内存与寄存器模型、系统调用、调试工具等角度出发，循序渐进地解释核心概念，并结合源码位置说明关键实现细节。

## 1. 项目背景与定位

CKB-VM 是 Nervos CKB 区块链在链上运行脚本时使用的虚拟机实现。它完全遵循 RISC-V 指令集规范，支持 32/64 位寄存器、压缩指令（RVC）、原子操作（A 扩展）、乘除法（M 扩展）、分支扩展（B 扩展）以及宏操作融合（Macro-Op Fusion，MOP）。项目目标是提供确定性、高性能、易审计的执行环境，以便运行链上合约和验证逻辑。

与很多虚拟机不同，CKB-VM 并不发明新的指令集，而是直接复用 RISC-V ISA。这意味着：

- 合约编译工具链可以使用通用的 RISC-V 编译器（如 GCC/LLVM）。
- VM 的行为完全由 RISC-V 规范定义，降低审计成本。
- 通过扩展模块（指令、系统调用）也能支持定制需求。

## 2. 快速体验：如何构建与运行

项目根目录包含标准的 Cargo 工程结构。常用命令如下：

```bash
cargo build            # 构建库与可执行测试组件
make test              # 运行内置测试集（等价于 cargo test + 额外脚本）
```

项目提供两种执行模式：

- **ASM 模式（默认）**：核心循环使用手写汇编提升性能，是生产环境默认选择。
- **Rust 解释器模式**：完全由 Rust 实现的解释器，主要用于调试与开发。默认入口 `ckb_vm::run` 使用此模式（参见 `src/lib.rs`），方便阅读理解。

对于初学者，建议先关注 Rust 模式的代码路径，理解整体流程后再探索 ASM 模式的优化细节。

## 3. 工程目录总览

- `src/lib.rs`：库入口，公开 `run`、`DefaultMachine` 等关键 API。
- `src/machine/`：虚拟机状态机实现。`mod.rs` 定义核心 trait、默认机器、构建器；`trace.rs` 实现带缓存的 Trace 运行器。
- `src/instructions/`：按 RISC-V 扩展分类的指令解码与执行逻辑（I/M/A/B/RVC/MOP）。
- `src/decoder.rs`：指令解码器，负责从内存取指、识别指令长度、宏操作融合。
- `src/memory/`：内存模型（线性、稀疏、WXorX）与加载接口。
- `src/elf.rs`：ELF 文件解析与装载，实现从 RISC-V 二进制到内存布局的转换。
- `src/syscalls/`：宿主系统调用接口，用于扩展 VM 能力（如调试、动态加载）。
- `definitions/`：`ckb_vm_definitions` 子 crate，集中存放常量、寄存器表、指令编码等数据。
- `tests/` 与 `examples/`：集成测试与示例程序，帮助了解 VM 实际使用方式。

理解这些模块的职责后，再阅读源码会更加顺畅。

## 4. 运行主流程（以 `ckb_vm::run` 为例）

`src/lib.rs` 中的 `run` 是最直观的起点：

1. **构建 CoreMachine**：`DefaultCoreMachine::<R, WXorXMemory<M>>::new_with_memory` 负责配置 ISA、VM 版本（`machine::VERSION2`）、最大执行周期、可用内存。这里的 `WXorXMemory` 强制执行「写与执行互斥」的安全策略。
2. **包装成 DefaultMachine**：通过 `RustDefaultMachineBuilder::new(core_machine).build()` 构建 `DefaultMachine`，注入调试器、系统调用、周期计费回调等组件。
3. **外层 TraceMachine**：`TraceMachine::new(...)` 再次包装，提供指令缓存与基本块（basic block）执行优化。
4. **加载程序**：`load_program(program, args)` 会自动解析 ELF、初始化内存、设置寄存器与栈。
5. **执行循环**：`machine.run()` 进入 `TraceMachine::run_with_decoder` 主循环，持续取指、解码、执行直至 `ecall`/`ebreak`/异常停止。

### 4.1 ELF 加载与栈初始化

- `DefaultMachine::load_program` 内部调用 `SupportMachine::load_elf_inner`，该函数由 `src/elf.rs` 提供 `parse_elf`，根据段信息调用 `memory.init_pages` 将指令与数据写入 VM 内存。
- 旧版本（`VERSION0/1`）与 `VERSION2` 在内存初始化上有兼容性差异（例如是否写入补零字节），通过 `version` 字段分支处理。
- 栈初始化由 `initialize_stack` 完成，负责写入 argv/argc，设置栈顶寄存器（`SP`），并在 `VERSION1` 及以上保证 16 字节对齐。

### 4.2 运行循环

在 `TraceMachine::run_with_decoder` 中，循环步骤如下：

1. **取指缓存**：依据当前 `pc` 计算 Trace 槽位，缓存最近一个基本块内最多 16 条指令。
2. **解码**：调用 `DefaultDecoder::decode` 读取内存、识别是 16 位压缩指令还是完整 32 位指令，并在启用 MOP 时尝试对相邻指令做宏操作融合。
3. **计费**：借助 `instruction_cycle_func`（默认来自 `cost_model.rs`，可自定义）为每条指令累加运行周期，溢出或超过 `max_cycles` 会触发 `Error::CyclesExceeded`。
4. **执行**：通过 `execute_with_thread` 把指令映射到对应的「解释线程」（`ThreadFactory`），最终调用 `instructions::execute` 中各个扩展模块的实现。
5. **系统调用/调试**：遇到 `ecall`/`ebreak` 时，转入 `DefaultMachine::ecall/ebreak`。例如 `ecall 93` 用于从程序内部退出并设置返回码。

循环会持续到 `DefaultMachine::running()` 变为 `false`（例如执行了退出系统调用或发生异常）。

## 5. RISC-V 指令支持模块

`src/instructions/` 目录按照 RISC-V 扩展拆分具体实现：

- `i.rs`：基础整数指令集（RV32/64I），涵盖算术、逻辑、跳转、加载/存储。
- `m.rs`：乘除扩展（M）。
- `a.rs`：原子指令扩展（A）。
- `b.rs`：分支/位操作扩展（B）。
- `rvc.rs`：压缩指令（RVC），与解码器配合支持 16 位编码。
- `mop` 相关逻辑分布在 `decoder.rs` 和 `instructions::execute` 内，负责识别并执行宏操作融合后的指令。
- `tagged.rs`：Tagged memory 扩展支持（用于附加额外元数据）。

`execute.rs` 定义了大型匹配驱动的执行函数：依据指令 opcode 分发到不同扩展，实现寄存器读写、内存访问、跳转、异常处理等。每条指令在执行前会通过 `Register` trait 与 `Memory` trait 获得统一的读写接口，既保证类型安全，又让不同内存实现可以替换。

`register.rs` 中定义了 `Register` trait 以及 `CKBVMRegister` 等具体实现，确保指令可以以统一方式处理 `u64`/`u32` 等数据类型。完整的寄存器 ABI 名称（`x0`-`x31` 与别名如 `sp`、`t0`）由 `ckb_vm_definitions::registers` 提供。

## 6. 指令解码器细节（`src/decoder.rs`）

`DefaultDecoder` 是理解 RISC-V 支持的关键：

- **指令长度识别**：先读取 16 位，如末两位是 `0b11` 则表明是 32 位指令，否则为压缩指令。由于 RISC-V 小端编码，内存读取按字节顺序处理即可。
- **越界检查**：在访问指令缓存前，会确认 `pc` 未超出分配内存，否则返回 `Error::MemOutOfBound`。
- **缓存**：使用容量为 4096 的数组缓存已解码指令，键值由 `pc` 经过移位与取模计算得出，有效减少重复解码开销。
- **宏操作融合**：在启用 MOP 时，某些常见指令序列（例如 `add`+`sltu` 用于实现加带进位）会被组合成一个逻辑单元，提升性能同时保持语义一致。

解码器输出的是 `instructions::Instruction`（实质为 `u64` 编码的结构体），随后由执行模块进一步解析寄存器索引与立即数。

## 7. 内存模型与寄存器

CKB-VM 将内存操作抽象为 `Memory` trait（见 `src/memory/mod.rs`），常见实现包括：

- `FlatMemory`：连续映射的线性内存，适合小型程序或测试。
- `SparseMemory`：使用页表/哈希结构按需分配内存，节省空间。
- `WXorXMemory`：装饰器模式，包装上述内存实现，在同一页内禁止同时写入与执行，遵循 W^X 安全策略。

指令执行所需的寄存器通过 `Register` trait 操作，核心实现为 `CKBVMRegister`（`u64` 封装），提供转换成多种整数类型的方法，确保既能表示 32 位寄存器（RV32）也能表示 64 位寄存器（RV64）。

## 8. 系统调用与 VM 拓展

系统调用由 `DefaultMachine::ecall` 管理：

- 根据 `A7` 寄存器的值选择系统调用编号，`A0` 等寄存器承载参数/返回值。
- `code == 93` 时代表程序主动退出（与 Linux RISC-V ABI 保持一致）。
- 其他编号会依次尝试 `syscalls` 列表中的处理器（实现 `Syscalls` trait 的对象）。如果没有处理器声明支持该编号，则返回 `Error::InvalidEcall`。
- 项目内置的 syscall 示例包括调试、动态设置内存页属性等，也允许上层按需扩展。

当需要调试时，还可以注入实现 `Debugger` trait 的对象，接管 `ebreak` 行为，实现断点、单步等功能。

## 9. 周期计费与成本模型

`src/cost_model.rs` 定义了 CKB 对指令执行的周期估算方式，用以限制脚本执行时间、防止滥用资源。默认情况下：

- `DefaultMachine` 在构建时注入了一个 `instruction_cycle_func` 回调。
- 每条指令执行前都会调用该回调，累加所需周期并与 `max_cycles` 比较。
- 出现溢出或超过上限则抛出 `Error::CyclesExceeded`。

对于自定义 VM 实例，可以在构建器中替换此回调，以适配不同的计费策略。

## 10. 快照、调试与 Trace 支持

- `src/machine/trace.rs` 提供了 TraceMachine，它在运行时保存最近的指令序列，利于性能优化与调试。
- `src/snapshot.rs`、`src/snapshot2.rs` 提供状态快照功能，可用于暂停后恢复、在 fuzz 测试中快速回滚。
- `src/debugger.rs` 定义了 Debugger 接口，可以实现自定义断点、寄存器检查等工具。

这些工具组合起来，可以满足区块链脚本在安全性与可验证性上的特殊需求。

## 11. RISC-V 版本与兼容性

`src/machine/mod.rs` 中定义了多个 `VERSION` 常量，用于兼容历史行为：

- `VERSION0`：主网上线时的最初版本。
- `VERSION1`/`VERSION2`：修复了内存越界、RVC 解码等已知问题。不同版本在初始化时会触发不同的兼容行为，例如是否补齐最后一个字节。

同一 ELF 程序在不同版本上运行可能存在细微差异，因此默认入口统一使用最新版（`VERSION2`）。

在选择 ISA 时，`run_with_memory` 会启用 `ISA_IMC | ISA_B | ISA_MOP` 等标志。更多常量定义位于 `ckb_vm_definitions` 中，可参考 `definitions/src/machine/mod.rs` 等文件了解完整清单。

## 12. 学习与调试路径建议

1. **从示例入手**：阅读 `examples/` 下的简易脚本（如 `is13.rs`），了解程序如何与 VM 交互。
2. **逐步跟踪执行**：使用 `cargo test -- --nocapture` 或在测试中插入调试输出来观察指令流。
3. **阅读指令实现**：从 `instructions/i.rs` 开始，结合 RISC-V 规范验证每条指令的实现方式。
4. **尝试扩展**：实现一个简单的自定义 syscall（实现 `Syscalls` trait 并注入构建器）或修改 cost model，观察影响。
5. **对比 ASM 模式**：当熟悉 Rust 版本后，再深入 `src/machine/asm/` 了解性能优化。

通过以上步骤，初学者可以逐渐掌握 CKB-VM 的整体结构、RISC-V 指令执行管线以及如何在 Rust 中实现一个可扩展的虚拟机。

---

若有进一步的阅读需求，可配合 RISC-V 官方手册、Nervos CKB RFC 文档以及 `ckb_vm_definitions` 子仓库中的定义文件进行交叉参考。祝你学习顺利！

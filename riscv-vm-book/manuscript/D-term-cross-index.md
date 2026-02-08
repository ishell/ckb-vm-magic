# 附录 D 术语索引交叉（章节 x 代码 x 定义）

> 使用方式：先在本附录定位术语，再跳到附录 B 对应定义，再回到章节中的应用语境。

| 术语 | 主要章节 | 代码锚点 | 定义入口 |
|---|---|---|---|
| Determinism | 第 1, 5, 7, 11 章 | `src/machine/mod.rs`, `src/error.rs` | 附录 B `Determinism` |
| Cycle Budget | 第 1, 11 章 | `SupportMachine::add_cycles` | 附录 B `Cycle Budget` |
| CoreMachine | 第 2 章 | `src/machine/mod.rs` trait 定义 | 附录 B `CoreMachine` |
| SupportMachine | 第 2 章 | `src/machine/mod.rs` trait 定义 | 附录 B `SupportMachine` |
| Runner | 第 2 章 | `DefaultMachineRunner` | 附录 B `Runner` |
| ELF | 第 3 章 | `src/elf.rs` | 附录 B `ELF` |
| ProgramMetadata | 第 3, 6 章 | `ProgramMetadata`, `LoadingAction` | 附录 B `ProgramMetadata` |
| W^X | 第 3, 11 章 | `src/memory/wxorx.rs` | 附录 B `W^X` |
| WXorXMemory | 第 3, 11 章 | `WXorXMemory` | 附录 B `WXorXMemory` |
| RVC | 第 4, 9 章 | `decode_bits` | 附录 B `RVC` |
| MOP | 第 4, 10 章 | `decode_mop`, `handle_wide_*` | 附录 B `MOP` |
| Trace | 第 4, 10 章 | `src/machine/trace.rs` | 附录 B `Trace` |
| Fast Path | 第 4, 8 章 | ASM 执行快路径 | 附录 B `Fast Path` |
| Slow Path | 第 4, 8 章 | `RET_SLOWPATH` 回退 | 附录 B `Slow Path` |
| Ecall | 第 2, 5 章 | `Machine::ecall` | 附录 B `Ecall` |
| Syscalls Trait | 第 5 章 | `src/syscalls/mod.rs` | 附录 B `Syscalls Trait` |
| TCB | 第 5 章 | syscall 边界设计 | 附录 B `TCB` |
| Snapshot | 第 6 章 | `snapshot.rs`, `snapshot2.rs` | 附录 B `Snapshot` |
| Dirty Page | 第 6 章 | `FLAG_DIRTY` | 附录 B `Dirty Page` |
| DataSource | 第 6 章 | `Snapshot2Context::store_bytes` | 附录 B `DataSource` |
| Zero Register | 第 7 章 | `update_register` | 附录 B `Zero Register` |
| Semantic Drift | 第 7, 8, 11 章 | 多后端同步风险 | 附录 B `Semantic Drift` |
| Differential Testing | 第 8, 11 章 | Rust/ASM 对拍 | 附录 B `Differential Testing` |
| Open ISA | 第 9 章 | ISA 公开规范收益 | 附录 B `Open ISA` |
| Governance Cost | 第 9 章 | 工具链/升级长期成本 | 附录 B `Governance Cost` |
| B Extension | 第 10 章 | `src/instructions/b.rs` | 附录 B `B Extension` |
| M Extension | 第 10 章 | `src/instructions/execute.rs` | 附录 B `M Extension` |
| Gas Fairness | 第 10 章 | `src/cost_model.rs` | 附录 B `Gas Fairness` |
| Execution Governance | 第 9, 11 章 | 版本策略与发布门禁 | 附录 B `Execution Governance` |
| V Extension | 附录 C | 向量扩展引入路线 | 附录 B `V Extension` |


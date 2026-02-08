# 附录 B 术语总表（带锚点）

> 说明：本附录为术语定义入口；跨章节映射见附录 D。

<a id="term-a-extension"></a>
### A Extension

RISC-V 原子指令扩展，包含 `LR/SC/AMO`。

<a id="term-b-extension"></a>
### B Extension

RISC-V 位操作扩展，覆盖旋转、位计数、无进位乘法等。

<a id="term-coremachine"></a>
### CoreMachine

`ckb-vm` 中只描述寄存器/PC/内存等核心状态的抽象接口。

<a id="term-consensus-safety"></a>
### Consensus Safety

同一交易在所有诚实节点上产出一致状态结果，不出现语义分叉。

<a id="term-cycle"></a>
### Cycle

VM 的执行计费单位，用于资源预算控制。

<a id="term-cycle-budget"></a>
### Cycle Budget

一次执行可用的最大 cycle 上限，超限应返回确定错误。

<a id="term-datasource"></a>
### DataSource

`snapshot2` 中可复用稳定数据源抽象，用于减少快照体积。

<a id="term-defaultmachine"></a>
### DefaultMachine

`ckb-vm` 核心机器实现，组合 inner machine、syscalls、debugger 与计费。

<a id="term-determinism"></a>
### Determinism

同输入同输出同错误语义。

<a id="term-differential-testing"></a>
### Differential Testing

通过多后端/多平台对拍验证执行一致性的测试方法。

<a id="term-dirty-page"></a>
### Dirty Page

执行期间发生写入的内存页。

<a id="term-ecall"></a>
### Ecall

RISC-V 系统调用陷入指令。

<a id="term-elf"></a>
### ELF

Executable and Linkable Format，可执行文件格式。

<a id="term-execution-governance"></a>
### Execution Governance

执行层升级、兼容、回滚与发布门禁的治理体系。

<a id="term-fast-path"></a>
### Fast Path

高频执行路径，通常为性能优化重点。

<a id="term-gas-fairness"></a>
### Gas Fairness

计费与实际资源消耗之间的一致性。

<a id="term-governance-cost"></a>
### Governance Cost

协议在长期维护、升级与审计中需要支付的综合成本。

<a id="term-imc"></a>
### IMC

RISC-V 基础整数指令集与压缩指令组合。

<a id="term-m-extension"></a>
### M Extension

RISC-V 乘除扩展。

<a id="term-mop"></a>
### MOP

Macro-Operation Fusion，宏操作融合。

<a id="term-open-isa"></a>
### Open ISA

规范公开、可实现、可审计的指令集架构。

<a id="term-pause"></a>
### Pause

`ckb-vm` 中断控制信号机制，可用于安全暂停执行。

<a id="term-program-metadata"></a>
### ProgramMetadata

ELF 解析后生成的装载动作集合。

<a id="term-runner"></a>
### Runner

驱动 VM 生命周期（加载、执行、退出）的调度器抽象。

<a id="term-rvc"></a>
### RVC

RISC-V Compressed Instructions，16 位压缩指令。

<a id="term-semantic-drift"></a>
### Semantic Drift

实现随时间偏离既定语义规范。

<a id="term-slow-path"></a>
### Slow Path

低频或复杂路径，通常在快路径无法覆盖时触发。

<a id="term-snapshot"></a>
### Snapshot

用于挂起/恢复 VM 的状态序列化结构。

<a id="term-supportmachine"></a>
### SupportMachine

在 `CoreMachine` 基础上扩展 cycles/load/reset 等能力的接口。

<a id="term-syscalls-trait"></a>
### Syscalls Trait

宿主能力注入接口，定义 `initialize` 与 `ecall`。

<a id="term-tcb"></a>
### TCB

Trusted Computing Base，可信计算基。

<a id="term-trace"></a>
### Trace

按基本块缓存的指令与执行线程集合。

<a id="term-v-extension"></a>
### V Extension

RISC-V 向量扩展。

<a id="term-wxorx"></a>
### W^X

Write xor Execute，页不可同时写与执行。

<a id="term-wxorxmemory"></a>
### WXorXMemory

`ckb-vm` 的权限包装内存，实现 W^X 检查。

<a id="term-zero-register"></a>
### Zero Register

RISC-V `x0` 寄存器，读恒为 0，写入被忽略。


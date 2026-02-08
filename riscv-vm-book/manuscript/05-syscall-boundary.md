# 第 5 章 Syscall 与宿主边界：最小可信计算基

## 5.1 核心问题

VM 与宿主系统如何交互，才能既可扩展又不牺牲确定性？

## 5.2 图 5-1：`ecall` 分发路径

```text
guest ecall
  -> Machine::ecall
      if A7 == 93:
         set exit_code, stop running
      else:
         for syscall module in syscalls:
            if module.ecall() handled: return
         error InvalidEcall
```

> 延伸阅读（批次二）：
> - [图 5-1 长文](../standalone-articles/batch-02/05-ecall-dispatch-boundary.md)
> - [图 5-1 审计模板](../standalone-articles/audit-templates/05-ecall-dispatch-boundary-audit-template.md)
> - [对应实验手册](../standalone-articles/labs/batch-02-labs.md)

## 5.3 代码证据

- `src/machine/mod.rs`：`Machine::ecall` 内核仅处理退出。
- `src/syscalls/mod.rs`：`Syscalls` trait 规定 `initialize` + `ecall`。

设计重点：内核只保留最小语义闭环，其余全部插件化。

## 5.4 深度分析

这种设计像微内核：

- 内核职责小：执行状态、陷入、错误语义
- 外部模块大：宿主能力、环境访问、I/O 代理

优点：可信计算基收敛，安全评审范围更可控。缺点：宿主集成要显式实现更多桥接逻辑。

## 5.5 案例：调试输出 syscall

示例 `examples/ckb_vm_runner.rs` 里的 `DebugSyscall` 读取 VM 内存字符串并输出日志。该能力不是 VM 内建，而是由宿主注入。这样既保留可扩展性，也避免把调试能力污染到共识内核。

## 5.6 术语表（本章）

- `Ecall`：从 guest 到 host 的系统调用陷入。
- `TCB`：Trusted Computing Base，可信计算基。
- `Module Chaining`：syscall 模块串行尝试处理。

## 5.7 一针见血结论

系统调用边界做得越小，协议安全边界就越清晰。

## 5.8 反例分析：把宿主能力塞进 VM 内核

反例场景：为了“易用”，把文件系统、网络、时间等能力内建到 VM 核心，结果：

- TCB 快速膨胀，安全审计范围失控。
- 共识执行依赖宿主环境细节，跨节点一致性下降。

教训：宿主能力必须模块化注入，核心只保留最小陷入语义。

## 5.9 架构评审清单（出版版）

- [ ] 内核默认 syscall 集是否最小化。
- [ ] syscall 编号、参数、返回码是否有稳定 ABI。
- [ ] 外部 syscall 模块是否可禁用、可替换、可审计。
- [ ] 是否禁止宿主隐式副作用影响共识结果。

## 5.10 参考实现清单（代码锚点）

- `src/machine/mod.rs`: `Machine::ecall`, `DefaultMachine::initialize`
- `src/syscalls/mod.rs`: `Syscalls` trait
- `examples/ckb_vm_runner.rs`: `DebugSyscall` 参考实现

## 5.11 术语索引交叉（参见附录 B 与附录 D）

- `Ecall`
- `Syscalls Trait`
- `TCB`
- `Determinism`


## 5.12 审稿人问题清单（出版评审）

1. 是否明确内核与宿主能力的责任分界？
2. `ecall` 默认最小语义是否解释到位？
3. 插件式 syscall 的风险与收益是否平衡呈现？
4. 是否讨论了 TCB 收敛与可扩展性的张力？
5. 案例是否足够说明“能力注入而非内建堆叠”？
6. 本章是否形成可执行的边界审计 checklist？

## 5.13 Syscall ABI 契约模板

建议在每个 syscall 说明中固定写明：

- 编号（`A7`）
- 输入寄存器与内存约定
- 输出寄存器约定
- 失败错误码
- 是否影响 cycles

这种模板化契约可以显著降低宿主实现偏差。

## 5.14 能力最小化的两种实现模式

1. `内核固定最小集 + 外部插件扩展`（ckb-vm 当前模式）
2. `内核全量能力 + 运行时开关`（不推荐）

前者的优势是审计范围可控，后者常因“默认开启过多能力”引入隐性攻击面。

## 5.15 实务建议：syscall 改动发布门禁

- 必须附 ABI 变更对照表
- 必须附旧合约兼容性说明
- 必须附差分测试（有/无该 syscall 模块）

任何一项缺失都不应进入发布分支。

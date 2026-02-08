# 第 8 章 Rust + ASM 混合执行：性能路径与语义锚点

## 8.1 核心问题

为什么不选“纯 Rust”或“纯汇编”，而是混合架构？

## 8.2 图 8-1：混合执行控制流

```text
ASM execute loop
  -> return RET_* status
     - RET_DECODE_TRACE
     - RET_ECALL
     - RET_SLOWPATH
     - ...
  -> Rust side handles status
     -> maybe fallback execute_instruction
```

## 8.3 代码证据

- `build.rs`：按目标平台条件启用汇编后端。
- `src/machine/asm/mod.rs`：汇编返回状态码，Rust 统一处理。
- `src/machine/asm/traces.rs`：固定 trace 与动态 trace 支持。

## 8.4 深度分析

这种架构的分工是：

- Rust：语义中心、错误模型、边界控制
- ASM：热点执行器、低层性能实现

这是一种“以语义安全为中心的性能外包”模型。不是追求极致裸金属速度，而是追求“可控加速”。

## 8.5 案例：`RET_SLOWPATH` 的设计意义

当汇编路径遇到慢路径指令，系统回退到 Rust `execute_instruction`。这保证了即使汇编快路径未覆盖所有情况，语义依旧闭环。工程上它降低了“汇编全覆盖”压力，也避免了性能优化绑架语义完整性。

## 8.6 术语表（本章）

- `Fast Path`：高频快路径。
- `Slow Path`：低频或复杂路径。
- `Semantic Anchor`：语义锚点，指最终正确性归属层。

## 8.7 一针见血结论

混合架构的正确姿势不是“让汇编统治一切”，而是“让汇编服务于 Rust 语义边界”。

## 8.8 反例分析：纯汇编快跑、语义文档缺失

反例场景：性能后端快速迭代，但缺少与语义后端的对齐机制：

- 新 opcode 在某后端生效、另一个后端未同步。
- 边界错误只能在线上暴露，回溯成本高。

教训：快路径必须服从语义锚点，并配置长期差分测试。

## 8.9 架构评审清单（出版版）

- [ ] 汇编返回码与错误语义是否完整映射。
- [ ] `RET_SLOWPATH` 回退链是否稳定可测。
- [ ] Rust/ASM 是否有常态化差分回归。
- [ ] 构建系统是否明确支持矩阵与回退策略。

## 8.10 参考实现清单（代码锚点）

- `build.rs`: 汇编后端启用矩阵
- `src/machine/asm/mod.rs`: `RET_*` 状态码处理、`RET_SLOWPATH` 回退
- `src/machine/asm/traces.rs`: `TraceDecoder` 与 fixed/dynamic trace

## 8.11 术语索引交叉（参见附录 B 与附录 D）

- `Fast Path`
- `Slow Path`
- `Differential Testing`
- `Semantic Drift`


## 8.12 审稿人问题清单（出版评审）

1. 是否明确 Rust 与 ASM 的职责边界与主从关系？
2. 是否解释 `RET_SLOWPATH` 对语义闭环的价值？
3. 双后端一致性成本是否被充分揭示？
4. 构建矩阵与平台限制是否说明完整？
5. 是否给出差分测试作为长期治理机制？
6. 结论是否避免“性能优先于语义”的误导？

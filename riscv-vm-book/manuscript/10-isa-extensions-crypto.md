# 第 10 章 密码学负载与指令扩展：从 B/M/A 到 MOP

## 10.1 核心问题

为什么密码学合约需要的不只是“能跑”，而是“跑得可定价”？

## 10.2 图 10-1：密码学操作到扩展映射

```text
Big-int mul/div chain -> M + MOP (WIDE_MUL/WIDE_DIV)
Bit permutation       -> B (REV8/ORCB)
Carry-less arithmetic -> B (CLMUL/CLMULH/CLMULR)
Atomic handshakes     -> A (LR/SC/AMO)
```

> 延伸阅读（批次三）：
> - [图 10-1 长文](../standalone-articles/batch-03/10-crypto-extension-real-division.md)
> - [图 10-1 审计模板](../standalone-articles/audit-templates/10-crypto-extension-real-division-audit-template.md)
> - [对应实验手册](../standalone-articles/labs/batch-03-labs.md)

## 10.3 代码证据

- `src/instructions/b.rs`：位操作与无进位乘法相关指令解码。
- `src/instructions/execute.rs`：`handle_wide_mul`, `handle_wide_div`, `handle_add3*`。
- `src/decoder.rs`：`decode_mop` 识别并融合高频序列。
- `src/cost_model.rs`：不同指令映射不同 cycle 开销。

## 10.4 深度分析

密码学负载常见瓶颈并不在“单条指令速度”，而在“长链操作的调度开销和计费公平性”。MOP 的意义在于：

- 不改变最终语义
- 缩短解释层调度链
- 让计费模型更贴近真实复杂度

## 10.5 案例：大整数乘加进位链

大整数库中，`mul + add + carry` 模式极高频。若全部走单指令解释分发，会产生大量 dispatch 成本。MOP 将固定模式压缩后，能够在不破坏确定性的前提下降低单位计算成本。

## 10.6 术语表（本章）

- `Carry-less Multiply`：无进位乘法，常用于 GF(2) 运算。
- `Macro-Op Fusion`：宏操作融合。
- `Gas Fairness`：计费公平性。

## 10.7 一针见血结论

密码学友好 VM 的核心，不是指令“多”，而是把高频模式压缩成可预测成本。

## 10.8 反例分析：只做微基准，不做真实负载画像

反例场景：通过单指令 microbenchmark 宣称优化成功，但上线后费用模型失真：

- 热点负载并非该指令，实际收益有限。
- cycles 估值偏差导致 DoS 面或过度收费。

教训：密码学优化必须基于真实合约路径与端到端计费验证。

## 10.9 架构评审清单（出版版）

- [ ] 是否有 secp/hash/Merkle 等代表性 workload 的 profiling。
- [ ] MOP 融合是否附带等价证明与回归测试。
- [ ] cycles 参数是否按版本持续校准。
- [ ] 是否明确区分确定性保证与恒时安全保证。

## 10.10 参考实现清单（代码锚点）

- `src/instructions/b.rs`: B 扩展解码
- `src/instructions/execute.rs`: `handle_wide_mul`, `handle_wide_div`, `handle_add3*`
- `src/decoder.rs`: `decode_mop`
- `src/cost_model.rs`: `estimate_cycles`

## 10.11 术语索引交叉（参见附录 B 与附录 D）

- `B Extension`
- `M Extension`
- `MOP`
- `Gas Fairness`


## 10.12 审稿人问题清单（出版评审）

1. 密码学负载画像是否覆盖 secp/hash/Merkle 三类典型路径？
2. MOP 与扩展指令收益是否基于真实 workload 而非微基准？
3. 计费公平性是否与安全风险绑定讨论？
4. 是否区分了确定性与恒时安全的边界？
5. 代码锚点是否足以复核核心论点？
6. 本章是否能指导性能优化 PR 的审查？

## 10.13 案例展开：一次签名验证的大致执行剖面

以 secp256k1 验签为例，执行热点通常分布在：

- 标量与点运算的大整数乘加链
- 模约简循环
- 少量控制流与内存搬运

若记录 opcode 统计，常见现象是算术与位操作长期占据前列，这也是 B/M/MOP 优化优先级高的原因。

## 10.14 计费校准的常见误区

- 只看总耗时，不看 opcode 结构
- 只看单机，不看跨平台偏差
- 只看平均值，不看长尾交易

正确方式应是“结构化统计 + 跨后端对拍 + 长尾分析”。

## 10.15 优化发布建议

优化 PR 应至少附三份报告：

1. 语义等价报告
2. 性能收益报告（真实 workload）
3. 计费影响报告（费用曲线变化）

缺一不可。

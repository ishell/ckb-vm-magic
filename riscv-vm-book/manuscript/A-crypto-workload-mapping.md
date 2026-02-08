# 附录 A 密码学专题：工作负载、指令映射与审计框架

## A.1 目标与范围

本附录回答三个实战问题：

1. 链上密码学负载在 VM 中到底花在哪些指令类型上？
2. `ckb-vm` 的 B/M/A/MOP 设计分别解决了什么真实瓶颈？
3. 如何把“优化”转化为“可验证、可计费、可审计”的发布资产？

本文聚焦三类工作负载：

- secp256k1（大整数和椭圆曲线主导）
- 哈希族（SHA-256/BLAKE2b）
- Merkle 验证与序列化路径

## A.2 图 A-1：密码学执行分层

```text
算法层:   ECDSA/Schnorr, SHA-2, BLAKE2b, Merkle proof
算子层:   mul/div/addcarry, bit-mix, permutation, memory moves
指令层:   IMC + B + M + A + MOP
执行层:   decode cache + trace + asm fastpath
计费层:   cycles model + max_cycles guard
```

核心判断：密码学优化不是单指令竞速，而是跨层协同。

## A.3 secp256k1 负载画像

### A.3.1 高占比算子

- 256 位乘法扩展（结果 512 位）
- 模约简（乘加、减法、条件选择）
- 点加/点倍的有限域链式运算

### A.3.2 `ckb-vm` 指令映射

- `M` 扩展：基础乘除语义
- `MOP`：`WIDE_MUL/WIDE_DIV/ADD3*` 压缩高频算术模板
- `Trace`：降低循环体重复解码和分发开销

对应代码锚点：

- `src/instructions/execute.rs`
- `src/decoder.rs`
- `src/machine/trace.rs`

### A.3.3 关键结论

大整数路径常见瓶颈是“调度开销 + 指令链长度”，而非单算子理论峰值。

## A.4 哈希负载画像（SHA-256/BLAKE2b）

### A.4.1 高占比算子

- rotate/shift/xor
- 字节重排与消息扩展
- 固定轮函数的高频循环

### A.4.2 指令映射

- `B` 扩展：`REV8/ORCB/CLMUL*` 与各类位操作
- IMC：基础加载存储和算术逻辑
- `Trace`：稳定循环体高命中，收益可观

### A.4.3 关键结论

哈希路径收益来自“位操作收敛 + 循环体命中”，不是某一条魔法指令。

## A.5 Merkle 验证与序列化路径

Merkle 负载常由“频繁小块哈希 + 边界拼接”组成。主要风险在于：

- 不必要的数据拷贝
- syscall 边界过细导致陷入频率过高
- 计费模型未覆盖小块高频模式

建议优先优化数据布局与调用边界，再优化单条算术路径。

## A.6 扩展价值矩阵

| 扩展/机制 | 主要收益点 | 典型负载 | 风险点 |
|---|---|---|---|
| B | 位操作压缩 | 哈希、比特域计算 | 指令覆盖不完整导致回退频繁 |
| M | 乘除语义原生化 | 大整数、模运算 | cycles 估值偏差 |
| A | 原子语义支持 | 并发协议/锁语义模拟 | 非核心密码学热点 |
| MOP | 高频模式融合 | 乘加进位链 | 等价性验证复杂 |
| Trace | 降低解释器噪声 | 稳定循环体 | cache 命中退化 |

## A.7 计费校准框架（出版版）

### A.7.1 校准流程

1. 采集真实合约 trace（而非 microbenchmark）。
2. 统计 opcode 和融合 opcode 占比。
3. 比较“cycles 估值”与“实际执行成本”偏差。
4. 回归更新 `estimate_cycles`，并做跨版本对拍。

### A.7.2 需长期追踪的指标

- `cycles_per_tx` 分布
- opcode 热点排名变化
- DoS 可疑交易的成本密度
- 版本升级前后费用漂移

## A.8 恒时安全与确定性的边界

需要明确：

- VM 确定性保证的是“结果一致”。
- 恒时安全关注的是“执行轨迹不泄露秘密”。

两者相关但不等价。密码学库仍需：

- 避免 secret-dependent 分支
- 避免 secret-dependent 访存
- 用审计与测试验证恒时性质

## A.9 反例分析：优化 KPI 与安全 KPI 断裂

反例场景：团队仅追求“TPS 提升 20%”，不做等价验证与计费校准。

后果通常是：

- 热点负载性能提升不明显，冷路径语义反而漂移。
- 费用模型失真，出现低成本重计算窗口。

教训：密码学优化必须同时满足“功能等价 + 计费一致 + 安全边界不退化”。

## A.10 审计清单（出版版）

- [ ] 是否覆盖 secp/hash/Merkle 三类代表性 workload。 
- [ ] MOP 融合是否有等价性测试与反例测试。 
- [ ] Rust/ASM 双后端是否做密码学路径差分回归。 
- [ ] cycles 模型是否按版本持续校准。 
- [ ] 是否单独评估恒时风险，不与确定性测试混用。 

## A.11 采样模板（可直接落地）

```text
Workload: secp256k1_verify_batch
Input size: N signatures
Backend: rust-trace / asm
VM version: VERSION2
ISA flags: IMC|B|A|MOP

Metrics:
- total cycles
- top 20 opcodes
- MOP hit ratio
- trace miss ratio
- syscall count
```

## A.12 发布门禁建议

1. 性能门禁：关键 workload 不低于基线。
2. 语义门禁：跨后端、跨平台差分一致。
3. 计费门禁：费用曲线变化在阈值内。
4. 安全门禁：新增路径完成侧信道风险复核。

## A.13 一针见血结论

密码学专题的本质不是“让几条指令更快”，而是把高频密码学模式收敛成可预测成本、可证明语义、可持续治理的执行体系。


# 第 6 章 快照与恢复：把执行过程对象化

## 6.1 核心问题

为什么区块链 VM 需要快照能力，而不仅是“跑完一次即结束”？

## 6.2 图 6-1：快照数据分层

```text
VM state
  = registers + pc + cycles + lr
  + memory pages

snapshot v1:
  dirty pages only

snapshot v2:
  dirty pages + pages_from_source(id,offset,length)
```

## 6.3 代码证据

- `src/snapshot.rs`：基础版脏页快照。
- `src/snapshot2.rs`：引入 `DataSource`，支持页面引用与去重。

`Snapshot2Context::make_snapshot` 会把内存页拆成两类：

1. 已知稳定来源页（不重复存内容）
2. 真正写脏页（存增量内容）

## 6.4 深度分析

这背后的思想是“增量状态传输”：

- 稳定数据不重复序列化
- 可变数据精准记录

收益直接体现在：

- 更小快照体积
- 更低网络/存储开销
- 更快恢复速度

## 6.5 案例：长任务分段执行

当单笔预算不足以完成复杂合约执行时，可以：

1. 运行至预算耗尽
2. 生成快照
3. 提高预算恢复执行

只要快照语义确定，分段与一次性执行应得到同样状态结果。这是链上“长任务可支付化”的关键能力。

## 6.6 术语表（本章）

- `Dirty Page`：执行期间被写入的页。
- `DataSource`：外部稳定数据源抽象。
- `Resume`：从快照恢复执行状态。

## 6.7 一针见血结论

快照不是调试功能，而是区块链执行经济学的基础设施。

## 6.8 反例分析：全量快照与无版本恢复

反例场景：每次保存全内存快照且恢复时不校验版本，短期简单，长期问题明显：

- 快照体积大，网络与存储成本不可控。
- 升级后恢复语义可能偏移，埋下一致性风险。

教训：快照要分层（来源页/脏页），恢复要强版本校验。

## 6.9 架构评审清单（出版版）

- [ ] 恢复时是否强制校验 VM 版本与关键参数。
- [ ] 是否只保存必要增量状态而非全量内存。
- [ ] 脏页标记与 source 页追踪是否可证明正确。
- [ ] 分段执行与一次性执行是否可对拍验证。

## 6.10 参考实现清单（代码锚点）

- `src/snapshot.rs`: `make_snapshot`, `resume`
- `src/snapshot2.rs`: `Snapshot2Context`, `DataSource`, `make_snapshot`, `resume`
- `src/memory/mod.rs`: `FLAG_DIRTY`, `get_page_indices`

## 6.11 术语索引交叉（参见附录 B 与附录 D）

- `Snapshot`
- `Dirty Page`
- `DataSource`
- `ProgramMetadata`


## 6.12 审稿人问题清单（出版评审）

1. 快照被定位为“执行经济工具”而非调试工具，论证是否充分？
2. 是否清晰比较 snapshot v1 与 snapshot2 的适用差异？
3. 是否解释了 `DataSource` 对体积和恢复成本的影响？
4. 恢复路径是否强调了版本校验与一致性验证？
5. 是否给出分段执行与一次性执行对拍建议？
6. 章节清单是否可直接用于上线前检查？

## 6.13 快照一致性不变量

恢复后必须满足以下不变量：

1. `pc/registers/cycles/max_cycles` 与快照一致
2. 脏页内容一致，且页标志一致
3. `lr`（load reservation）一致
4. 恢复后继续执行结果与不中断执行一致

这四条是“快照正确”最小充分集。

## 6.14 Snapshot2 的成本收益估算

在典型链上场景中，程序代码与常量数据占比高，可通过 `pages_from_source` 去重。若脏页比例低，Snapshot2 在网络传输和存储上的收益会非常显著。

建议在文档中长期记录两个指标：

- `dirty_pages / total_pages`
- `pages_from_source / total_pages`

这能直观看到 Snapshot2 的真实收益。

## 6.15 读者实验：验证分段执行等价性

实验步骤：

1. 设置极低 `max_cycles`，触发中断并保存快照。
2. 恢复到新 VM，继续执行到完成。
3. 与高预算一次性执行结果做对拍（寄存器/内存摘要）。

该实验是验证快照机制最有说服力的证据。

# 第 4 章 解码、执行与 Trace：确定性边界内的性能工程

## 4.1 核心问题

解释器真的只能“慢速逐条执行”吗？

## 4.2 图 4-1：取指与解码快路径

```text
pc -> decode_bits
  if not near page end:
     execute_load32 + RVC check
  else:
     execute_load16 (+ optional second load16)

-> decode_raw (cache lookup)
-> optional decode_mop fusion
-> execute_instruction
```

## 4.3 代码证据

- `src/decoder.rs`：`decode_bits` 对页尾跨页场景做专门路径。
- `src/decoder.rs`：`instructions_cache` 避免重复解码热点地址。
- `src/decoder.rs`：`decode_mop` 将常见指令序列融合为宏操作。
- `src/machine/trace.rs`：Trace 缓存“基本块 + 处理函数指针”。

## 4.4 深度分析

`ckb-vm` 的优化策略非常克制：

- 不做不可解释的 speculative 优化
- 只做可审计的结构化优化

它不是 JIT，但通过 `TraceMachine` 获取了局部线程化执行收益；通过 MOP 降低调度与解码开销；通过 decode cache 减少热点路径重复工作。

## 4.5 案例：密码学大整数路径上的收益来源

大整数算法常出现固定算术模板（乘法、除法、进位链）。MOP 不是“换 ISA”，而是把“已知安全的指令组合”打包为同语义的复合动作，从而减少解释器开销。

## 4.6 术语表（本章）

- `RVC`：RISC-V 压缩指令集（16 位）。
- `MOP`：宏操作融合，把多条指令映射为一条复合操作。
- `Trace`：按基本块缓存的执行片段。

## 4.7 一针见血结论

在共识 VM 里，最好的性能优化不是最激进，而是最可证明。

## 4.8 反例分析：激进优化先行、语义验证后补

反例场景：先上复杂 JIT，再补一致性校验，常见后果：

- 优化命中路径与冷路径语义偏移。
- cache/trace 失效策略不完整，出现不可重现错误。

教训：共识执行器中，优化必须建立在可证明等价关系上。

## 4.9 架构评审清单（出版版）

- [ ] decode cache 的失效条件是否完整（reset/版本切换/写代码页）。
- [ ] MOP 融合是否有等价性测试与反例测试。
- [ ] Trace 命中与未命中路径是否严格同语义。
- [ ] slowpath 回退是否覆盖所有未优化 opcode。

## 4.10 参考实现清单（代码锚点）

- `src/decoder.rs`: `decode_bits`, `decode_raw`, `decode_mop`
- `src/machine/trace.rs`: `TraceMachine`, `run_with_decoder`
- `src/instructions/execute.rs`: `execute_instruction`, `execute`

## 4.11 术语索引交叉（参见附录 B 与附录 D）

- `RVC`
- `MOP`
- `Trace`
- `Fast Path`
- `Slow Path`


## 4.12 审稿人问题清单（出版评审）

1. 是否区分了解码优化与语义优化，避免概念混淆？
2. MOP/Trace 的收益是否建立在等价性前提上？
3. 是否解释了 slowpath 回退对正确性的意义？
4. 是否覆盖了页尾取指等边界路径？
5. 本章是否提供了可复用的性能评审问题？
6. 结论是否避免夸大为“解释器等同 JIT”？

## 4.13 解码缓存键设计：为什么不是直接 `pc % N`

`decode_raw` 的缓存键使用了混合位选择策略，目标是同时兼顾：

- 局部顺序代码（函数体内部）
- 远跳转代码（库函数、分支目标）

如果只用低位，热点函数命中高但远跳转退化严重；如果只用高位，局部热点退化。当前策略是折中工程选择。

## 4.14 MOP 等价性验证建议

每条融合规则都应有三类测试：

1. 语义等价：融合前后寄存器/内存完全一致
2. 边界等价：零寄存器、溢出、符号边界一致
3. 长度等价：`instruction_length` 与 PC 前进一致

只有三类都通过，MOP 才是“优化”而不是“语义变更”。

## 4.15 Trace 失效策略的审计点

建议重点检查：

- reset 后 trace 是否清空
- version 切换后旧 trace 是否不可复用
- 代码页被写时是否存在陈旧 trace 风险

共识 VM 里，trace 失效策略错误的风险远大于 trace 命中率下降。

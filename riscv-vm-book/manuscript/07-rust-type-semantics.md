# 第 7 章 Rust 类型系统：把 ISA 语义固定在编译期

## 7.1 核心问题

为什么 Rust 在这里是“语义工具”，不是“语法偏好”？

## 7.2 图 7-1：语义约束下沉到 trait

```text
Instruction handlers
   -> Register trait methods
      -> u32 / u64 concrete semantics

(no hidden cast / no UB shortcut)
```

> 延伸阅读（批次二）：
> - [图 7-1 长文](../standalone-articles/batch-02/07-register-trait-semantics.md)
> - [图 7-1 审计模板](../standalone-articles/audit-templates/07-register-trait-semantics-audit-template.md)
> - [对应实验手册](../standalone-articles/labs/batch-02-labs.md)

## 7.3 代码证据

`src/instructions/register.rs` 的 `Register` trait 明确要求实现：

- 溢出加减乘除与余数
- signed/unsigned 比较
- 扩展位操作（B 扩展相关）
- `sign_extend` / `zero_extend`

`src/instructions/utils.rs` 的 `update_register` 统一处理 x0 不可写不变量。

## 7.4 深度分析

在共识系统里，最危险的错误不是崩溃，而是“不同节点得到不同结果”。Rust 的价值在于把大量语义边界变为编译期接口契约，并通过 `Result<_, Error>` 把失败路径显式化。

这并不自动等于“无 bug”，但显著降低了“隐式未定义行为”进入共识层的概率。

## 7.5 案例：除零与有符号溢出

RISC-V 对除零、最小负数除以 -1 有严格规定。`Register` 的 `overflowing_div_*` 系列将这些规则固化，不依赖平台 CPU 的默认行为，从源头减少跨平台偏差。

## 7.6 术语表（本章）

- `Semantic Contract`：语义契约。
- `UB`：Undefined Behavior，未定义行为。
- `Zero Register`：RISC-V x0，恒为 0。

## 7.7 一针见血结论

Rust 在共识 VM 的核心收益是“把语义边界前移到类型系统”。

## 7.8 反例分析：依赖宿主整数默认行为

反例场景：在指令实现中直接使用宿主语言隐式转换与未约束溢出行为：

- 边界输入在不同编译器/平台可能产生差异。
- 语义分散在代码细节里，难以系统验证。

教训：ISA 边界语义必须集中到统一抽象层（如 `Register` trait）。

## 7.9 架构评审清单（出版版）

- [ ] 除零、溢出、符号扩展是否由统一接口定义。
- [ ] x0 等架构不变量是否有单点实现。
- [ ] 错误是否通过结构化类型而非字符串传播。
- [ ] 32/64 位路径是否共享同一语义模型。

## 7.10 参考实现清单（代码锚点）

- `src/instructions/register.rs`: `Register` trait 与 `u32/u64` 语义实现
- `src/instructions/utils.rs`: `update_register`（x0 不变量）
- `src/error.rs`: 结构化错误模型

## 7.11 术语索引交叉（参见附录 B 与附录 D）

- `Determinism`
- `Semantic Drift`
- `Zero Register`
- `Consensus Safety`


## 7.12 审稿人问题清单（出版评审）

1. `Register` trait 是否被阐明为语义契约而非抽象技巧？
2. 除零/溢出/符号扩展的边界语义是否可代码验证？
3. 是否避免把 Rust 优势泛化为“天然无 bug”？
4. x0 不变量的单点实现是否解释清楚？
5. 错误模型显式化是否与共识安全建立联系？
6. 本章结论是否支持跨平台一致性评审？

## 7.13 语义接口设计原则（可复用到其他 VM）

`Register` trait 的设计可抽象为三条原则：

1. 把 ISA 边界行为显式函数化
2. 把平台相关行为隔离在实现层
3. 把默认行为写成不可变约束（如 x0）

这三条原则可直接迁移到其他执行器项目。

## 7.14 风险提示：trait 抽象并不自动免疫错误

即使有 trait，仍可能出现：

- 某个实现忘记保持边界语义
- 新增方法未被所有实现覆盖
- 优化路径绕过 trait 直接操作底层值

因此需要配套“trait 合约测试集”，不是只靠编译通过。

## 7.15 合约测试建议

建议为 `u32` 与 `u64` 分别构建同一批向量：

- 除零
- 有符号最小值溢出
- 位扩展边界
- 旋转与位计数

并验证跨位宽的语义对应关系。

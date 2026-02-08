# 批次三实验手册（图 9-1、10-1、11-1、A-1、C-1）

> 对应长文：批次三五篇图示拆解长文

## Lab 9（图 9-1）：ISA 与版本治理

### 目标

验证版本相关行为与历史兼容测试。

### 命令

```bash
cargo test --test test_versions -- --nocapture
cargo test --test test_misc -- --nocapture
```

### 预期

- 不同版本语义测试稳定通过。
- ISA/版本边界问题能被测试覆盖。

## Lab 10（图 10-1）：密码学扩展路径

### 目标

验证 B/MOP 等扩展在密码学相关程序上可用。

### 命令

```bash
cargo test --test test_mop -- --nocapture
cargo test --test test_b_extension -- --nocapture
```

### 预期

- MOP 与 B 扩展主要测试通过。
- 可用于后续计费校准对照。

## Lab 11（图 11-1）：收益-成本矩阵的回归视角

### 目标

用回归测试近似验证“优化不破坏语义”。

### 命令

```bash
cargo test --all -- --nocapture
```

### 预期

- 全测试集通过。
- 若有失败，优先定位“后端差分或版本边界”问题。

## Lab A1（图 A-1）：密码学执行栈闭环采样

### 目标

形成“测试 -> 指令热点 -> 计费观察”的闭环记录。

### 命令

```bash
cargo test --test test_mop -- --nocapture
cargo test --test test_simple test_simple_cycles -- --nocapture
```

### 记录模板

- 测试用例：
- 后端：
- 观察到的热点行为：
- cycles 变化：
- 结论：

## Lab C1（图 C-1）：扩展引入治理演练

### 目标

模拟“功能变更后发布门禁”流程：

1. 运行核心测试
2. 运行后端相关测试
3. 填写审计模板

### 命令

```bash
cargo test --test test_versions -- --nocapture
cargo test --features asm --test test_asm -- --nocapture
```

### 配套文档

- 审计模板：`附录 F`
- 改稿清单：`附录 G`


# 批次二实验手册（图 5-1 到 8-1）

> 对应长文：批次二四篇图示拆解长文

## Lab 5（图 5-1）：ecall 与宿主边界

### 目标

验证 syscall 处理路径和未处理路径错误行为。

### 命令

```bash
cargo run --example ckb_vm_runner -- --mode interpreter64 tests/programs/simple64
cargo test --test test_error -- --nocapture
```

### 预期

- 程序能通过 ecall 正常退出。
- 错误路径仍由结构化错误承接。

## Lab 6（图 6-1）：快照恢复一致性

### 目标

验证 snapshot/snapshot2 的恢复链路在不同后端可用。

### 命令

```bash
cargo test --test test_resume -- --nocapture
cargo test --test test_resume2 -- --nocapture
```

### 预期

- interpreter -> asm / asm -> interpreter 场景通过。
- 快照后继续执行结果保持一致。

## Lab 7（图 7-1）：Register 语义边界

### 目标

通过指令集合测试覆盖整数、位操作与边界行为。

### 命令

```bash
cargo test --test test_b_extension -- --nocapture
cargo test --test test_a_extension -- --nocapture
cargo test --test test_simple -- --nocapture
```

### 预期

- 扩展指令行为稳定。
- 边界测试（如 overflow/invalid bits）保持通过。

## Lab 8（图 8-1）：Rust/ASM 混合路径一致性

### 目标

验证 asm 后端与解释器后端在核心测试集上行为一致。

### 命令

```bash
cargo test --features asm --test test_asm -- --nocapture
cargo test --features asm --test test_simple -- --nocapture
cargo test --features asm --test test_versions -- --nocapture
```

### 预期

- asm 相关测试通过。
- 不同后端在同测试语义下无显著偏差。

## 扩展任务

- 选取 `tests/programs/mop_wide_multiply`，分别以 `interpreter64` 和 `asm64` 跑并记录输出。


# 批次一实验手册（图 1-1 到 4-1）

> 对应长文：批次一四篇图示拆解长文

## Lab 1（图 1-1）：确定性与计费边界

### 目标

验证“同输入同输出”和“max_cycles 边界触发”的基本行为。

### 命令

```bash
cargo test --test test_simple test_simple_cycles -- --nocapture
cargo test --test test_simple test_simple_max_cycles_reached -- --nocapture
```

### 预期

- 前者通过并能体现 cycles 统计逻辑。
- 后者触发 `CyclesExceeded` 相关行为（以测试断言为准）。

## Lab 2（图 2-1）：生命周期与 pause/resume

### 目标

验证运行循环可被中断并稳定恢复。

### 命令

```bash
cargo test --test test_signal_pause -- --nocapture
```

### 预期

- `test_asm_pause` / `test_int_pause` 通过。
- pause 语义在解释器和 asm 路径都可观测。

## Lab 3（图 3-1）：装载与权限边界

### 目标

验证版本与边界行为（argv/sp/边界读写）不会随意漂移。

### 命令

```bash
cargo test --test test_versions -- --nocapture
cargo test --test test_error -- --nocapture
```

### 预期

- 版本相关测试全部通过。
- 错误类型保持结构化可断言。

## Lab 4（图 4-1）：解码优化与 MOP 路径

### 目标

验证 MOP 相关测试在真实程序上可通过。

### 命令

```bash
cargo test --test test_mop -- --nocapture
```

### 预期

- wide mul/div、far jump、adc/add3 等测试通过。
- 可观察到融合路径在测试中被覆盖。

## 扩展任务

- 用 `ckb_vm_runner` 对同一程序分别跑 interpreter64 和 asm64，比较退出码与 cycles。


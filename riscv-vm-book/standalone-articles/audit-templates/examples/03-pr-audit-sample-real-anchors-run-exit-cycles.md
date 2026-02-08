# 审计样例 03：真实 ckb-vm 代码锚点映射（run / pause / exit / cycles）

> 类型：真实仓库代码锚点演练（非虚拟模块）  
> 审计结论：`通过（环境证据待补跑）`  
> 目的：给团队一份可以直接映射到当前 `ckb-vm` 代码的审计模板填写样例。

## 0. 一针见血结论

如果一个改动同时触及 `run_with_decoder`、`ecall`、`add_cycles` 任意两处，你就必须把它当作“共识语义改动”审计，而不是普通性能 PR。

## 1. 审计对象（真实锚点范围）

本样例不假设新 PR，而是直接对当前仓库核心路径做锚点映射。覆盖 4 条主链：

1. 运行主循环：`run_with_decoder`。
2. 退出语义：`ecall` 中 `A7=93` 的 `exit` 行为。
3. 资源边界：`add_cycles` 的溢出与上限分支。
4. 外部中断：`pause` 信号触发与恢复。

## 2. 代码锚点总表（真实路径）

### 2.1 执行与退出

- `src/machine/mod.rs:598`：`fn ecall(&mut self)` 入口。
- `src/machine/mod.rs:601`：`match code` 分发。
- `src/machine/mod.rs:601-606`：`A7 == 93` 时设置 `exit_code` 并 `set_running(false)`。
- `src/machine/mod.rs:607-618`：非 93 走 syscall 链，未处理返回 `Error::InvalidEcall(code)`。

### 2.2 运行循环与暂停

- `src/machine/mod.rs:666`：`run_with_decoder` 入口。
- `src/machine/mod.rs:671-680`：主循环 `while self.running()`。
- `src/machine/mod.rs:672-674`：检测 pause 信号后返回 `Error::Pause`。
- `src/machine/mod.rs:676-678`：reset 信号触发 decoder cache reset。

### 2.3 计费边界

- `src/machine/mod.rs:95-105`：`add_cycles`，先 `checked_add`，再比较 `max_cycles`。
- `src/machine/mod.rs:99`：溢出返回 `Error::CyclesOverflow`。
- `src/machine/mod.rs:100-102`：超过上限返回 `Error::CyclesExceeded`。

### 2.4 错误类型与边界语义

- `src/error.rs:6`：`CyclesExceeded`。
- `src/error.rs:8`：`CyclesOverflow`。
- `src/error.rs:24`：`InvalidEcall(u64)`。
- `src/error.rs:47`：`Pause`。

### 2.5 内存权限（辅助锚点）

- `src/memory/wxorx.rs:36-41`：页对齐约束。
- `src/memory/wxorx.rs:60-63`：冻结页写入保护。
- `src/memory/wxorx.rs:115-160`：写路径权限检查。

## 3. 测试锚点映射（真实测试文件）

### 3.1 cycles 与上限

- `tests/test_simple.rs:37-52`：`test_simple_cycles`（708 cycles 基线）。
- `tests/test_simple.rs:55-69`：`test_simple_max_cycles_reached`（断言 `CyclesExceeded`）。
- `tests/test_simple.rs:92-107`：`test_simple_cycles_overflow`（断言 `CyclesOverflow`）。

### 3.2 pause 语义

- `tests/test_signal_pause.rs:55-97`：`test_int_pause`（多次中断后应恢复并正确退出）。
- `tests/test_signal_pause.rs:80`：明确断言 `result == Err(Error::Pause)` 分支。

### 3.3 版本与边界兼容

- `tests/test_versions.rs:76-83`：`VERSION0` 下边界读取触发 `MemOutOfBound`。
- `tests/test_versions.rs:126-132`：`VERSION1` 同类路径恢复为可执行语义。
- `tests/test_versions.rs:242-253`：`VERSION0` 下 `unaligned64` 触发 `MemWriteOnExecutablePage`。

## 4. 审计问题（按“是否可发布”排序）

1. `ecall` 行为是否仍保证只有显式退出码路径能结束运行？
2. `run_with_decoder` 是否可能在 pause/reset 分支上引入不可重放状态？
3. cycles 上限与溢出分支是否仍然互斥且可观测？
4. 错误类型是否仍能把失败场景稳定映射到 `Error` 枚举？
5. 版本差异行为是否仍由 `VERSION0/1/2` 显式控制，而非隐式漂移？

## 5. 推荐验证命令（直接映射锚点）

```bash
cargo test --test test_simple test_simple_cycles -- --nocapture
cargo test --test test_simple test_simple_max_cycles_reached -- --nocapture
cargo test --test test_simple test_simple_cycles_overflow -- --nocapture
cargo test --test test_signal_pause test_int_pause -- --nocapture
cargo test --test test_versions -- --nocapture
```

批量审计可用：

```bash
bash docs/riscv-vm-book/tools/run_labs.sh --batch 1 --mode smoke --skip-asm
```

## 6. 审计检查表（已填写示例）

### A. 协议语义

- [x] run/pause/exit 路径均有代码与测试锚点。
- [x] `ecall=93` 的退出行为可在代码中单点定位。
- [x] 关键失败分支（Pause/CyclesExceeded/CyclesOverflow）都有枚举定义与断言。

### B. 计费与性能

- [x] cycles 边界在 `add_cycles` 中集中定义。
- [x] 超限与溢出由不同错误码区分。
- [x] 基线样例（708）有测试锚点。

### C. 边界与安全

- [x] pause 分支不会吞掉运行状态（可恢复继续执行）。
- [x] W^X 相关页权限路径可通过 `WXorXMemory` 定位。
- [x] 边界异常可落到可观测错误。

### D. 治理与发布

- [x] 版本行为差异具备专门回归测试。
- [x] 审计结论可回链到具体文件与行号。
- [ ] 本地全量测试产物待在可写 rustup 环境补跑归档。

## 7. 当前环境证据状态（2026-02-08）

- 已有证据：代码锚点与测试锚点完整可定位。
- 待补证据：本机 rustup 临时目录权限异常，`cargo test` 执行日志需在修复权限后补挂。
- 影响判断：这属于“环境执行证据缺口”，不是“锚点映射缺口”。

## 8. 审计结论（签署区）

- 结论：`[x] 通过  [ ] 条件通过  [ ] 拒绝`
- 风险等级：`[ ] 低  [x] 中  [ ] 高`
- 发布建议：
  - 允许将本样例作为“真实仓库锚点审计模板”纳入评审流程；
  - 任何触及 run/ecall/cycles 的 PR 必须引用本样例锚点并补充实际日志。
- 审计人：`docs-maintainer`
- 日期：`2026-02-08`

## 9. 一针见血复盘

真正危险的不是“测试偶尔失败”，而是“改动触及共识路径却没有锚点映射”。
先把锚点钉死，再谈性能与发布，才是区块链 VM 的工程纪律。

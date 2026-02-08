# 图示长文实验：通用准备

## 1. 环境准备

```bash
# 在项目根目录
cd /home/jay/Code/Rust/ckb-vm

# 先编译（可选带 asm）
cargo build
cargo build --features asm
```

## 2. 推荐基础检查

```bash
# 快速烟雾测试
cargo test --test test_simple
cargo test --test test_versions
```

## 3. 一键脚本（按批次自动执行并生成报告）

脚本位置：`docs/riscv-vm-book/tools/run_labs.sh`

深度说明：`docs/riscv-vm-book/standalone-articles/labs/runner-script.md`

```bash
# 仅跑批次一
bash docs/riscv-vm-book/tools/run_labs.sh --batch 1

# 跑全部批次（smoke 模式，跳过最重回归）
bash docs/riscv-vm-book/tools/run_labs.sh --batch all --mode smoke

# 跑全部批次并跳过 asm 指令
bash docs/riscv-vm-book/tools/run_labs.sh --batch all --skip-asm
```

输出位置（默认）：

- `docs/riscv-vm-book/reports/labs/<timestamp>/lab-run-report.md`
- `docs/riscv-vm-book/reports/labs/<timestamp>/lab-run-report.csv`
- `docs/riscv-vm-book/reports/labs/<timestamp>/logs/*.log`

## 4. 常用实验命令模板

```bash
# 运行单个测试文件
cargo test --test test_mop -- --nocapture

# 运行单个测试函数
cargo test --test test_signal_pause test_int_pause -- --nocapture

# 运行示例 runner（解释器）
cargo run --example ckb_vm_runner -- --mode interpreter64 tests/programs/simple64

# 运行示例 runner（asm，需要 --features asm）
cargo run --features asm --example ckb_vm_runner -- --mode asm64 tests/programs/simple64
```

## 5. 结果记录建议

每次实验最少记录：

- 命令行
- 输入程序
- 后端模式（interpreter/asm）
- 退出码
- cycles（若输出）
- 关键差异（若有）

## 6. 注意事项

- 若系统使用 `rustup` 并提示权限问题，先检查本机 rustup 目录写权限。
- Windows/macOS/Linux 的可用后端可能不同，以 `build.rs` 条件为准。
- 对拍实验必须保持同一程序、同一参数、同一 VM 版本。


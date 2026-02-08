# Rust + RISC-V 区块链虚拟机书稿

本目录包含三层产物，均已升级。

## 1) 完整章节版（出版版）

- 目录：`manuscript/`
- 入口：`manuscript/README.md`
- 状态：第 1-11 章已统一收口结构：
  - 一针见血结论
  - 反例分析
  - 架构评审清单
  - 参考实现清单（代码锚点）
  - 术语索引交叉
  - 审稿人问题清单（出版评审）

## 2) mdBook 可预览版本（发布目录已补齐）

- 目录：`mdbook/`
- 配置：`mdbook/book.toml`
- 索引：`mdbook/src/SUMMARY.md`
- 发布页：
  - `mdbook/src/publish/cover.md`
  - `mdbook/src/publish/version.md`
  - `mdbook/src/publish/changelog.md`
  - `mdbook/src/publish/reviewer-brief.md`

本地预览：

```bash
cd docs/riscv-vm-book/mdbook
mdbook serve
```

若未安装：

```bash
cargo install mdbook
```

## 3) 专题附录（增强）

- 密码学专题附录：`manuscript/A-crypto-workload-mapping.md`
- 密码学 PR 审计模板：`manuscript/F-crypto-implementation-audit-template.md`
- RISC-V 专题附录：`manuscript/C-riscv-isa-and-os-appendix.md`
- 术语总表（带锚点）：`manuscript/B-glossary.md`
- 术语交叉索引：`manuscript/D-term-cross-index.md`
- 出版规范与合规矩阵：`manuscript/E-publication-style-guide.md`
- 作者终版改稿清单：`manuscript/G-author-revision-checklist.md`

## 历史批次草稿（保留）

- `00-outline.md`
- `01-batch-execution-flow.md`
- `02-batch-rust-riscv.md`
- `03-batch-os-crypto-analysis.md`


# Rust + RISC-V 区块链虚拟机书稿

本目录包含五层产物，均已升级。

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
  - 深度扩展段落（`X.13+`）

## 2) 图示拆解长文系列（分批）

- 总目录：`standalone-articles/README.md`
- 路线图：`standalone-articles/ROADMAP.md`
- 已完成批次一（1-1 到 4-1）
- 已完成批次二（5-1 到 8-1）
- 已完成批次三（9-1、10-1、11-1、A-1、C-1）

详见：

- `standalone-articles/batch-01/`
- `standalone-articles/batch-02/`
- `standalone-articles/batch-03/`
- `standalone-articles/audit-templates/`（每篇图示长文对应审计模板）
- `standalone-articles/audit-templates/examples/`（审计样例：通过/拒绝/真实锚点）

## 3) 可复现实验手册（批次配套）

- `standalone-articles/labs/common-setup.md`
- `standalone-articles/labs/runner-script.md`
- `standalone-articles/labs/batch-01-labs.md`
- `standalone-articles/labs/batch-02-labs.md`
- `standalone-articles/labs/batch-03-labs.md`
- `tools/run_labs.sh`（批次执行脚本，自动生成 md/csv/log 报告）

## 4) 教学版讲义与练习题

- `teaching/00-course-map.md`
- `teaching/01-lecture-notes.md`
- `teaching/02-exercises.md`
- `teaching/03-answer-guide.md`
- `teaching/04-90min-instructor-script.md`
- `teaching/05-90min-slide-outline.md`
- `teaching/06-90min-live-demo-runbook.md`
- `teaching/07-90min-assessment-sheet.md`
- `teaching/08-90min-slide-verbatim-script.md`

## 5) mdBook 可预览版本（发布目录已补齐）

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


## 6) 质量检查与回归清单

- `quality/01-chapter-link-click-checklist.md`（第 1-11 章链接点击检查）
- `tools/check_chapter_links.sh`（自动检查章节链接是否指向 `articles/articles-audit/labs`）
- `make docs-check`（一键执行链接检查 + mdBook 构建）

## 专题附录（增强）

- 密码学专题附录：`manuscript/A-crypto-workload-mapping.md`
- 密码学 PR 审计模板：`manuscript/F-crypto-implementation-audit-template.md`
- secp256k1 端到端案例：`manuscript/H-end-to-end-case-study-secp256k1.md`
- 哈希/Merkle 端到端案例：`manuscript/I-end-to-end-case-study-hash-merkle.md`
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


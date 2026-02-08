# 章节链接点击检查清单（第 1-11 章）

## 一针见血目标

保证每一章都能从“主章”一跳进入对应的：

1. 图示长文（`articles/*`）
2. 审计模板（`articles-audit/*`）
3. 实验手册（`labs/*`）

避免再次出现 `standalone-articles/*` 直链导致的 mdBook 路由错误。

## 使用方式

1. 在 mdBook 页面内打开对应章节。
2. 点击章节内“延伸阅读”三个链接。
3. 勾选结果并记录异常。

建议在以下模式各执行一次：

- 本地 `mdbook serve`
- 发布产物 `mdbook build` 后的静态页面

## 章节级检查表

| 章节 | 主章入口 | 图示长文 | 审计模板 | 实验手册 |
|---|---|---|---|---|
| 第 1 章 | [01](../chapters/01-consensus-first.md) | [1-1](../articles/batch-01-01-constraint-hierarchy.md) | [1-1 审计](../articles-audit/01-constraint-hierarchy-audit-template.md) | [批次一实验](../labs/batch-01-labs.md) |
| 第 2 章 | [02](../chapters/02-run-to-exit.md) | [2-1](../articles/batch-01-02-run-lifecycle.md) | [2-1 审计](../articles-audit/02-run-lifecycle-audit-template.md) | [批次一实验](../labs/batch-01-labs.md) |
| 第 3 章 | [03](../chapters/03-elf-loader-memory.md) | [3-1](../articles/batch-01-03-elf-to-page-actions.md) | [3-1 审计](../articles-audit/03-elf-to-page-actions-audit-template.md) | [批次一实验](../labs/batch-01-labs.md) |
| 第 4 章 | [04](../chapters/04-decode-execute-trace.md) | [4-1](../articles/batch-01-04-decode-fastpath.md) | [4-1 审计](../articles-audit/04-decode-fastpath-audit-template.md) | [批次一实验](../labs/batch-01-labs.md) |
| 第 5 章 | [05](../chapters/05-syscall-boundary.md) | [5-1](../articles/batch-02-05-ecall-dispatch-boundary.md) | [5-1 审计](../articles-audit/05-ecall-dispatch-boundary-audit-template.md) | [批次二实验](../labs/batch-02-labs.md) |
| 第 6 章 | [06](../chapters/06-snapshot-resume.md) | [6-1](../articles/batch-02-06-snapshot-layering-economics.md) | [6-1 审计](../articles-audit/06-snapshot-layering-economics-audit-template.md) | [批次二实验](../labs/batch-02-labs.md) |
| 第 7 章 | [07](../chapters/07-rust-type-semantics.md) | [7-1](../articles/batch-02-07-register-trait-semantics.md) | [7-1 审计](../articles-audit/07-register-trait-semantics-audit-template.md) | [批次二实验](../labs/batch-02-labs.md) |
| 第 8 章 | [08](../chapters/08-rust-asm-hybrid.md) | [8-1](../articles/batch-02-08-rust-asm-control-plane.md) | [8-1 审计](../articles-audit/08-rust-asm-control-plane-audit-template.md) | [批次二实验](../labs/batch-02-labs.md) |
| 第 9 章 | [09](../chapters/09-riscv-governance.md) | [9-1](../articles/batch-03-09-isa-selection-impact-chain.md) | [9-1 审计](../articles-audit/09-isa-selection-impact-chain-audit-template.md) | [批次三实验](../labs/batch-03-labs.md) |
| 第 10 章 | [10](../chapters/10-isa-extensions-crypto.md) | [10-1](../articles/batch-03-10-crypto-extension-real-division.md) | [10-1 审计](../articles-audit/10-crypto-extension-real-division-audit-template.md) | [批次三实验](../labs/batch-03-labs.md) |
| 第 11 章 | [11](../chapters/11-architecture-judgment.md) | [11-1](../articles/batch-03-11-benefit-cost-hard-constraints.md) | [11-1 审计](../articles-audit/11-benefit-cost-hard-constraints-audit-template.md) | [批次三实验](../labs/batch-03-labs.md) |

## 勾选记录（可复制到评审单）

- [ ] 第 1 章三类链接可点击
- [ ] 第 2 章三类链接可点击
- [ ] 第 3 章三类链接可点击
- [ ] 第 4 章三类链接可点击
- [ ] 第 5 章三类链接可点击
- [ ] 第 6 章三类链接可点击
- [ ] 第 7 章三类链接可点击
- [ ] 第 8 章三类链接可点击
- [ ] 第 9 章三类链接可点击
- [ ] 第 10 章三类链接可点击
- [ ] 第 11 章三类链接可点击
- [ ] 全文无 `standalone-articles/*` 路由残留

## 自动化检查（脚本）

```bash
# 仅执行链接检查
bash docs/riscv-vm-book/tools/check_chapter_links.sh

# 一键执行链接检查 + mdBook 构建
make docs-check
```

该脚本会检查：

1. 第 1-11 章正文是否仍含错误路由 `standalone-articles/*`
2. 每章正文是否包含对应 `articles/articles-audit/labs` 链接
3. 每章 mdBook wrapper 是否包含对应 `articles/articles-audit` 链接

## 异常记录模板

- 章节：
- 链接类型（长文/审计/实验）：
- 现象（404/跳错页/锚点错位）：
- 复现路径：
- 修复提交：

# 图示长文审计模板总览

## 一针见血定位

每篇图示长文都给出独立审计模板，目的是把“阅读理解”升级为“可执行门禁”。
这些模板不是填表动作，而是发布决策前的证据清单。

## 使用方式

1. 先阅读对应图示长文，确认架构结论。
2. 再填写同编号审计模板，逐项挂载证据。
3. 在 PR 中附模板结论与报告路径（md/csv/log）。

## 模板索引

- `01-constraint-hierarchy-audit-template.md`（图 1-1）
- `02-run-lifecycle-audit-template.md`（图 2-1）
- `03-elf-to-page-actions-audit-template.md`（图 3-1）
- `04-decode-fastpath-audit-template.md`（图 4-1）
- `05-ecall-dispatch-boundary-audit-template.md`（图 5-1）
- `06-snapshot-layering-economics-audit-template.md`（图 6-1）
- `07-register-trait-semantics-audit-template.md`（图 7-1）
- `08-rust-asm-control-plane-audit-template.md`（图 8-1）
- `09-isa-selection-impact-chain-audit-template.md`（图 9-1）
- `10-crypto-extension-real-division-audit-template.md`（图 10-1）
- `11-benefit-cost-hard-constraints-audit-template.md`（图 11-1）
- `A1-crypto-execution-stack-closure-audit-template.md`（图 A-1）
- `C1-isa-to-protocol-governance-chain-audit-template.md`（图 C-1）

## 已填表示例

- `examples/README.md`
- `examples/01-pr-audit-sample-mop-secp256k1.md`
- `examples/02-pr-audit-sample-syscall-host-time.md`
- `examples/03-pr-audit-sample-real-anchors-run-exit-cycles.md`

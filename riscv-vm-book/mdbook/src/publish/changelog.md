# 更新日志

## v0.10.4 - 2026-02-08

### Added

- Makefile 新增文档质量目标：
  - `make docs-link-check`
  - `make docs-mdbook-build`
  - `make docs-check`
  - `make docs-serve`

### Changed

- 质量清单与 README 同步增加 `make docs-check` 一键命令。
- 文档回归流程从“脚本命令”升级为“Make 统一入口”。

## v0.10.3 - 2026-02-08

### Added

- 新增章节链接点击检查清单：`quality/01-chapter-link-click-checklist.md`。
- 新增自动检查脚本：`tools/check_chapter_links.sh`。
- mdBook 发布页新增“章节链接点击检查清单”入口。

### Changed

- 顶层 README 与 mdBook README 同步增加质量检查入口说明。

## v0.10.2 - 2026-02-08

### Added

- 第 1-4 章正文新增批次一链接（图示长文 + 审计模板 + 实验手册）。

### Changed

- mdBook 第 1-4 章页头新增批次一延伸阅读链接，形成与第 5-11 章一致的章节导航体验。
- 修正章节内链接目标：从 `standalone-articles/*` 统一改为 mdBook 路由 `articles/*` / `articles-audit/*` / `labs/*`。
- 修复 `manuscript/02-run-to-exit.md` 中的 NUL 字符（`foo\0bar\0` 文本化），避免被识别为二进制文件。

## v0.10.1 - 2026-02-08

### Added

- 新增真实仓库锚点审计样例：
  - `standalone-articles/audit-templates/examples/03-pr-audit-sample-real-anchors-run-exit-cycles.md`
- mdBook 新增“审计样例 03 真实锚点映射”入口。

### Changed

- 审计样例集从 2 份扩展到 3 份（通过 / 拒绝 / 真实锚点）。
- 导读页与 README 对审计样例描述升级为“通过/拒绝/真实锚点”。

## v0.10.0 - 2026-02-08

### Added

- 新增审计样例集：`standalone-articles/audit-templates/examples/`。
  - 样例 01：MOP + secp256k1 优化（有条件通过）。
  - 样例 02：host time syscall 扩展（拒绝通过）。
- mdBook 新增“审计样例总览 + 两份已填表示例”导航入口。
- 教学包新增“逐页口播稿”与审计样例联动使用路径。

### Changed

- 图示审计模板 README 增加样例索引与使用建议。
- 总 README、图示 README、导读页同步到“模板 + 样例 + 教学演练”结构。

## v0.9.0 - 2026-02-08

### Added

- 新增图示长文审计模板层：`standalone-articles/audit-templates/`，覆盖 13 篇图示长文（每篇一份模板）。
- mdBook 新增“图示审计模板总览 + 13 份模板”导航入口。
- 新增教学增强文档：`teaching/08-90min-slide-verbatim-script.md`（90 分钟逐页口播稿，可直接照读）。

### Changed

- 图示路线图批次四状态升级为“已完成”（实验脚本化、审计模板化、教学增强闭环）。
- 顶层 README、图示 README、教学 README、mdBook 索引全部同步到“读长文 -> 跑实验 -> 填模板 -> 上课交付”链路。

## v0.8.0 - 2026-02-08

### Added

- 新增实验脚本化执行手册：`standalone-articles/labs/runner-script.md`。
- 新增脚本化入口并接入文档导航：`tools/run_labs.sh` 与 mdBook `labs/runner-script.md`。
- 新增 90 分钟教学包：
  - `teaching/04-90min-instructor-script.md`
  - `teaching/05-90min-slide-outline.md`
  - `teaching/06-90min-live-demo-runbook.md`
  - `teaching/07-90min-assessment-sheet.md`
- mdBook 新增“实验脚本化执行”与“90 分钟教学包”导航入口。

### Changed

- 项目总目录、教学目录与 mdBook README 同步到“实验脚本化 + 课堂可交付”结构。
- 图示长文路线图批次四状态更新为“第一阶段已完成”。

## v0.7.0 - 2026-02-08

### Added

- 新增图示长文实验层（labs）：
  - 通用准备
  - 批次一实验手册
  - 批次二实验手册
  - 批次三实验手册
- 新增教学层（teaching）：
  - 课程地图
  - 教学讲义
  - 练习题
  - 参考答案与评分建议
- mdBook 新增实验与教学导航入口。

### Changed

- 项目总目录结构升级为“主文 + 图示长文 + 实验 + 教学 + 附录”。
- 导读页和 README 文档同步到新结构。

## v0.6.0 - 2026-02-08

### Added

- 图示拆解长文批次三（5 篇）并接入 mdBook：
  - 图 9-1、10-1、11-1
  - 图 A-1、C-1
- 新增 `standalone-articles/batch-03/` 目录与批次说明。
- mdBook 目录增加批次三长文入口。

### Changed

- 图示长文路线图更新为“批次一/二/三已完成”。
- 导读、README、索引页同步到批次三状态。

## v0.5.0 - 2026-02-08

### Added

- 新增 mdBook 发布页体系：
  - 封面页
  - 版本页
  - 更新日志页
  - 审稿人变更摘要页
- 11 个章节 wrapper 统一页眉页脚，形成一致出版展示。
- 新增附录 G（作者改稿检查清单）。
- 新增附录 F（密码学 PR 审计模板）并接入目录。

### Changed

- 第 1-11 章新增“审稿人问题清单（出版评审）”。
- 顶层 README、manuscript README、mdBook README 全部同步到新结构。

## v0.4.0 - 2026-02-08

### Added

- 主体第 1-11 章新增出版收口结构：
  - 反例分析
  - 架构评审清单
  - 参考实现清单
  - 术语交叉索引
- 新增附录 C（RISC-V 专题扩展版）
- 新增附录 D（术语交叉索引）
- 新增附录 E（出版规范与合规矩阵）

### Changed

- 术语总表升级为带锚点版本，支持章节交叉引用。
- 目录结构按“主线阅读 + 专题附录 + 审计辅助”重排。

## v0.3.0 - 2026-02-08

### Added

- 第 1-11 章完整稿（严肃专业版）
- 附录 A 密码学专题初版
- mdBook 基础可读结构

## v0.2.0 - 2026-02-08

### Added

- 分批扩展稿：执行主线、Rust/RISC-V 论证、架构评估

## v0.1.0 - 2026-02-08

### Added

- 初始大纲与章节规划

# 审计模板 5-1：ecall 分发边界

## 一针见血风险

syscall 面膨胀导致最小可信计算基失控。

## 关联阅读

- 图示长文：`standalone-articles/batch-02/05-ecall-dispatch-boundary.md`
- 对应章节：`manuscript/05-syscall-boundary.md`
- 关联审计模板：`manuscript/F-crypto-implementation-audit-template.md`

## 审计输入清单

- [ ] PR 链接与提交哈希
- [ ] 影响文件列表（含代码与文档）
- [ ] 影响后端范围（interpreter / asm / 其他）
- [ ] 基线版本与目标版本
- [ ] 报告产物路径（md/csv/log）

## 核心审计问题（必须回答）

1. 新增或变更 syscall 是否有明确白名单与拒绝策略？
2. 宿主能力是否出现隐式状态依赖或时序依赖？
3. 错误码、返回值、cycles 是否可在异常路径复核？

## 审计检查表

### A. 协议语义

- [ ] 同输入同初始状态下结果可重放
- [ ] 错误码与退出语义保持兼容
- [ ] 边界输入无未定义行为

### B. 计费与性能

- [ ] cycles 变化具备解释与样本支持
- [ ] 长尾输入行为已观测，不只看平均值
- [ ] smoke 与 full 结论边界明确

### C. 边界与安全

- [ ] 宿主接口与内存权限边界未扩张
- [ ] 新增路径具备失败可观测性（日志/错误码）
- [ ] 回滚路径可执行且有演练记录

### D. 治理与发布

- [ ] 版本兼容结论与证据一致
- [ ] 发布门禁、灰度策略、冻结条件已定义
- [ ] 责任人、观察窗口、复盘机制已指定

## 推荐验证命令

```bash
cargo test --test test_simple -- --nocapture
cargo test --test test_misc -- --nocapture
cargo run --example ckb_vm_runner -- --mode interpreter64 tests/programs/simple64
```

## 证据记录（填写区）

- 关键日志：
- 差分结果：
- 计费变化：
- 治理评估：

## 审计结论（签署区）

- 结论：`[ ] 通过  [ ] 条件通过  [ ] 拒绝`
- 风险等级：`[ ] 低  [ ] 中  [ ] 高`
- 发布建议：
- 回滚触发条件：
- 审计人：
- 日期：

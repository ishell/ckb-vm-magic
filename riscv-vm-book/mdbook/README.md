# mdBook 预览说明

## 内容结构

- 发布页：封面页、版本页、更新日志、审稿人摘要
- 主体章节：第 1-11 章（出版版）
- 附录 A：密码学专题
- 附录 F：密码学实现审计模板（PR 可直接使用）
- 附录 C：RISC-V 专题
- 附录 B：术语总表（带锚点）
- 附录 D：术语交叉索引
- 附录 E：出版规范与合规矩阵
- 附录 G：作者终版改稿清单

## 依赖安装

如果本机尚未安装 `mdbook`，先执行：

```bash
cargo install mdbook
```

## 本地预览

```bash
cd docs/riscv-vm-book/mdbook
mdbook serve
```


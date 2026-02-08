# 第 3 章 ELF 装载与内存权限：把外部程序变成受控状态

## 3.1 核心问题

为什么 VM 装载器是安全边界的一部分，而不仅是工具函数？

## 3.2 图 3-1：ELF 到页动作的转换

```text
ELF bytes
  -> parse_elf
      -> ProgramMetadata
          -> [LoadingAction...]
              (addr,size,flags,source,offset)
  -> load_binary_inner
      -> init_pages per action
      -> set PC = entry
```

> 延伸阅读（批次一）：
> - [图 3-1 长文](../standalone-articles/batch-01/03-elf-to-page-actions.md)
> - [图 3-1 审计模板](../standalone-articles/audit-templates/03-elf-to-page-actions-audit-template.md)
> - [对应实验手册](../standalone-articles/labs/batch-01-labs.md)

## 3.3 代码证据

`src/elf.rs` 的 `parse_elf` 明确生成 `ProgramMetadata`，不是直接把 ELF 结构散用在执行路径里。

`convert_flags` 实施两项硬拒绝：

- 段不可读，拒绝
- 段可写且可执行，拒绝

`src/memory/wxorx.rs` 的 `WXorXMemory` 在运行期继续强制权限：

- 取指必须落在 `FLAG_EXECUTABLE`
- 写入必须落在 `FLAG_WRITABLE`

## 3.4 深度分析

这是一种“操作系统式”装载模型：

- 映像装载阶段决定页级权限
- 执行阶段持续检查权限
- 违规立即终止

好处是把“代码注入”和“越权写入”从潜在漏洞变成确定错误。

## 3.5 案例：W^X 为什么对链上 VM 尤其关键

在链上环境，攻击者可反复提交精心构造输入。若 VM 允许同页可写可执行，攻击面会从“输入漏洞”升级为“执行模型漏洞”。`WXorXMemory` 把这条路堵死，代价是需要更严格的装载策略，但这是共识层必须承担的代价。

## 3.6 术语表（本章）

- `W^X`：页不可同时写且执行。
- `LoadingAction`：一次页初始化动作描述。
- `Entry Point`：程序入口 PC。

## 3.7 一针见血结论

安全的 VM 装载器不是“读文件”，而是“建立可验证地址空间契约”。

## 3.8 反例分析：先写后验的权限模型

反例场景：先把段写进内存，再在运行时“尽量检查权限”，会导致：

- 历史脏数据与权限信息耦合，难以证明不存在执行注入路径。
- 检查逻辑分散在指令实现中，容易遗漏边界页。

教训：权限应在装载期建模，在执行期强校验，且以页为单位统一处理。

## 3.9 架构评审清单（出版版）

- [ ] 是否拒绝可写且可执行段（W^X）。
- [ ] ELF `PT_LOAD` 的地址/长度/偏移是否有越界保护。
- [ ] 页对齐与跨页访问是否有一致语义。
- [ ] 栈初始化是否有版本兼容与对齐保证。

## 3.10 参考实现清单（代码锚点）

- `src/elf.rs`: `parse_elf`, `convert_flags`, `ProgramMetadata`
- `src/memory/wxorx.rs`: `WXorXMemory::init_pages`, `execute_load32`, `store_bytes`
- `src/machine/mod.rs`: `load_binary_inner`, `initialize_stack`

## 3.11 术语索引交叉（参见附录 B 与附录 D）

- `ELF`
- `W^X`
- `ProgramMetadata`
- `WXorXMemory`


## 3.12 审稿人问题清单（出版评审）

1. ELF 到 `ProgramMetadata` 的转换是否解释了可验证性价值？
2. W^X 约束是否被说明为装载期 + 运行期双重机制？
3. 是否覆盖了页对齐、越界、权限冲突三类边界错误？
4. 栈初始化的版本兼容语义是否解释充分？
5. 是否避免将“加载文件”误写成“单纯 I/O 操作”？
6. 本章是否给出可执行的装载审计清单？

## 3.13 标志位映射表：ELF 段权限到页权限

建议把映射关系固定为审计检查表：

- `R=1,W=0,X=1` -> 可执行冻结页
- `R=1,W=1,X=0` -> 可写页（旧版本允许冻结策略差异）
- `R=1,W=0,X=0` -> 冻结只读页
- `R=0,*` -> 直接拒绝
- `W=1,X=1` -> 直接拒绝

这张表能快速识别“权限提升”类回归风险。

## 3.14 攻击视角：装载器最容易出问题的三类边界

1. `offset + filesz` 溢出导致越界切片
2. 页面起始未对齐但被当作对齐页写入
3. `offset_from_addr > size` 导致外部数据定位错误

`ckb-vm` 在 `parse_elf` 与 `WXorXMemory::init_pages` 中对这些边界均有显式拒绝路径。

## 3.15 工程建议：装载阶段审计脚本最小集

- 脚本 1：扫描所有 `PT_LOAD` 是否满足 R/W/X 合法组合
- 脚本 2：验证 action 合并后地址区间不重叠异常
- 脚本 3：统计每类权限页数量，和历史基线对比

这些脚本不替代测试，但能提前发现“配置级事故”。

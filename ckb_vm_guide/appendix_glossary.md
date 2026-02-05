# 附录 A：术语表 (Glossary)

> 中英对照技术术语速查

---

## A

| 英文 | 中文 | 解释 |
|------|------|------|
| **ABI (Application Binary Interface)** | 应用二进制接口 | 定义函数调用、参数传递、寄存器使用等规范 |
| **ADD (Addition)** | 加法指令 | RISC-V 基础算术指令，格式：`add rd, rs1, rs2` |
| **ADC (Add with Carry)** | 带进位加法 | CKB-VM 的融合指令，用于多精度运算 |
| **ASM (Assembly)** | 汇编 / 汇编模式 | CKB-VM 的高性能执行模式 |
| **AUIPC (Add Upper Immediate to PC)** | PC 加立即数 | 用于计算相对地址，格式：`auipc rd, imm` |

## B

| 英文 | 中文 | 解释 |
|------|------|------|
| **Branch Prediction** | 分支预测 | CPU 技术，猜测条件跳转的方向 |
| **BSS (Block Started by Symbol)** | 未初始化数据段 | ELF 文件中的段，存放未初始化的全局变量 |
| **Byte** | 字节 | 8 位二进制数据单元 |

## C

| 英文 | 中文 | 解释 |
|------|------|------|
| **Cache** | 缓存 | 快速存储器，用于加速频繁访问的数据 |
| **Call Stack** | 调用栈 | 存储函数调用链的栈结构 |
| **Cell** | 单元 | CKB 区块链的基本数据结构（类似 UTXO） |
| **CKB (Common Knowledge Base)** | 通用知识库 | Nervos 区块链的第一层 |
| **Cycles** | 周期数 | CKB-VM 的资源计量单位 |

## D

| 英文 | 中文 | 解释 |
|------|------|------|
| **Decoder** | 解码器 | 将二进制机器码转换为可执行指令 |
| **Deterministic** | 确定性的 | 相同输入产生相同输出 |

## E

| 英文 | 中文 | 解释 |
|------|------|------|
| **ECALL (Environment Call)** | 系统调用 | RISC-V 指令，触发系统调用 |
| **ELF (Executable and Linkable Format)** | 可执行和可链接格式 | Linux 标准可执行文件格式 |
| **Entry Point** | 入口地址 | 程序开始执行的地址 |

## F

| 英文 | 中文 | 解释 |
|------|------|------|
| **Fused Instruction** | 融合指令 | 多条指令合并为一条的优化技术 |
| **Frame Pointer** | 帧指针 | 指向当前栈帧的寄存器（s0） |

## G

| 英文 | 中文 | 解释 |
|------|------|------|
| **Gas** | 燃料费 | 以太坊的资源计费单位（类似 CKB 的 Cycles） |
| **GDB (GNU Debugger)** | GNU 调试器 | 强大的程序调试工具 |

## H

| 英文 | 中文 | 解释 |
|------|------|------|
| **Hash** | 哈希 / 散列 | 将任意长度数据映射为固定长度的算法 |
| **Heap** | 堆 | 动态内存分配区域 |

## I

| 英文 | 中文 | 解释 |
|------|------|------|
| **IMC** | RISC-V 指令集组合 | I (基础整数) + M (乘除法) + C (压缩指令) |
| **Immediate** | 立即数 | 指令中直接编码的常量 |
| **Instruction** | 指令 | CPU 可执行的基本操作 |
| **ISA (Instruction Set Architecture)** | 指令集架构 | 定义 CPU 支持的指令集 |

## J

| 英文 | 中文 | 解释 |
|------|------|------|
| **JAL (Jump and Link)** | 跳转并链接 | 函数调用指令，保存返回地址 |
| **JALR (Jump and Link Register)** | 寄存器跳转并链接 | 间接跳转指令 |

## L

| 英文 | 中文 | 解释 |
|------|------|------|
| **Lock Script** | 锁定脚本 | CKB 中验证 Cell 解锁权限的脚本 |
| **Load** | 加载指令 | 从内存读取数据到寄存器 |

## M

| 英文 | 中文 | 解释 |
|------|------|------|
| **Macro-Op Fusion** | 宏操作融合 | 将多条指令融合为一条的优化技术 |
| **Memory** | 内存 | 存储数据和指令的硬件 |
| **Monomorphization** | 单态化 | Rust 编译器为每个具体类型生成独立代码 |

## O

| 英文 | 中文 | 解释 |
|------|------|------|
| **Opcode** | 操作码 | 指令的唯一标识符 |
| **Overflow** | 溢出 | 运算结果超出数据类型范围 |

## P

| 英文 | 中文 | 解释 |
|------|------|------|
| **PC (Program Counter)** | 程序计数器 | 指向下一条指令地址的寄存器 |
| **Pipeline** | 流水线 | CPU 技术，并行处理多条指令 |

## R

| 英文 | 中文 | 解释 |
|------|------|------|
| **Register** | 寄存器 | CPU 内部的高速存储单元 |
| **RISC-V** | 第五代精简指令集 | 开源的指令集架构 |
| **RVC (RISC-V Compressed)** | RISC-V 压缩指令 | 16 位的压缩指令扩展 |

## S

| 英文 | 中文 | 解释 |
|------|------|------|
| **Sandbox** | 沙盒 | 隔离的执行环境 |
| **secp256k1** | 椭圆曲线算法 | 比特币和以太坊使用的签名算法 |
| **Stack** | 栈 | 后进先出的数据结构，用于函数调用 |
| **Store** | 存储指令 | 将寄存器数据写入内存 |
| **Syscall (System Call)** | 系统调用 | 请求操作系统服务的接口 |

## T

| 英文 | 中文 | 解释 |
|------|------|------|
| **Trait** | 特征 | Rust 的接口定义机制 |
| **Type Script** | 类型脚本 | CKB 中验证 Cell 状态转换的脚本 |

## U

| 英文 | 中文 | 解释 |
|------|------|------|
| **UDT (User Defined Token)** | 用户自定义代币 | CKB 上的代币标准 |
| **UTXO** | 未花费交易输出 | 比特币的交易模型 |

## V

| 英文 | 中文 | 解释 |
|------|------|------|
| **Virtual Machine** | 虚拟机 | 软件模拟的计算机环境 |
| **VRF (Verifiable Random Function)** | 可验证随机函数 | 生成可验证的随机数 |

## W

| 英文 | 中文 | 解释 |
|------|------|------|
| **WASM (WebAssembly)** | Web 汇编 | 浏览器中的虚拟机指令集 |
| **WXorX (Write XOR Execute)** | 写异或执行 | 内存保护机制，页面要么可写要么可执行 |

## Z

| 英文 | 中文 | 解释 |
|------|------|------|
| **Zero-Cost Abstraction** | 零成本抽象 | 抽象无运行时开销 |

---

## 🔤 按字母分类索引

### 指令相关
- ADD, ADC, AUIPC, ECALL, JAL, JALR, LOAD, STORE

### 架构相关
- ABI, ISA, PC, Register, RISC-V, RVC

### 内存相关
- Cache, Heap, Memory, Stack, WXorX

### 优化技术
- Branch Prediction, Macro-Op Fusion, Monomorphization, Pipeline, Zero-Cost Abstraction

### CKB 特有
- Cell, CKB, Cycles, Lock Script, Type Script, UDT

### 文件格式
- BSS, ELF, Entry Point

### 密码学
- Hash, secp256k1, VRF

---

**返回目录** → [README](README.md)

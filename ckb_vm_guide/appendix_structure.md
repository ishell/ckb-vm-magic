# 附录 B：代码结构导航

> CKB-VM 源码目录结构和关键文件说明

---

## 📁 项目根目录结构

```
ckb-vm/
├── src/                    # 核心源代码
├── definitions/            # 指令和寄存器定义
├── examples/               # 示例程序
├── benches/                # 性能基准测试
├── tests/                  # 单元测试和集成测试
├── docs/                   # 文档（本文档系列）
├── Cargo.toml              # Rust 项目配置
└── README.md               # 项目说明
```

---

## 🗂️ src/ 核心源码

### 主要模块

```
src/
├── lib.rs                  # 库入口，导出公共 API
├── error.rs                # 错误类型定义
├── bits.rs                 # 位操作工具函数
├── cost_model.rs           # Cycles 计费模型
├── decoder.rs              # 指令解码器 ⭐
├── debugger.rs             # 调试器接口
├── elf.rs                  # ELF 文件解析器 ⭐
├── snapshot.rs             # 虚拟机状态快照
├── snapshot2.rs            # 快照 v2 版本
│
├── instructions/           # 指令实现 ⭐
│   ├── mod.rs
│   ├── common.rs           # 通用指令工具
│   ├── register.rs         # Register trait 定义
│   ├── execute.rs          # 指令执行入口 ⭐
│   ├── i.rs                # 基础指令集（I）
│   ├── m.rs                # 乘除法扩展（M）
│   ├── a.rs                # 原子操作扩展（A）
│   ├── b.rs                # 位操作扩展（B）
│   ├── rvc.rs              # 压缩指令（C）
│   ├── ast.rs              # 抽象语法树
│   ├── tagged.rs           # 带标签的指令
│   └── utils.rs            # 工具函数
│
├── machine/                # 虚拟机核心 ⭐
│   ├── mod.rs              # Machine trait 定义
│   ├── trace.rs            # 执行追踪
│   └── asm/                # ASM 模式（高性能）
│       ├── mod.rs
│       └── traces.rs
│
├── memory/                 # 内存管理 ⭐
│   ├── mod.rs              # Memory trait 定义
│   ├── flat.rs             # FlatMemory 实现
│   ├── sparse.rs           # SparseMemory 实现
│   └── wxorx.rs            # WXorXMemory 实现
│
└── syscalls/               # 系统调用
    └── mod.rs              # Syscall trait 定义
```

---

## 🔍 关键文件详解

### 1. lib.rs - 库入口

**路径**：`src/lib.rs`

**作用**：
- 导出公共 API
- 定义常量（ISA 标志、版本号）
- 重新导出核心类型

**关键代码**：

```rust
// ISA 标志位
pub const ISA_IMC: u8 = 0b0001_0001;  // I + M + C
pub const ISA_A: u8 = 0b0000_0100;    // Atomic
pub const ISA_B: u8 = 0b0001_0000;    // Bit manipulation
pub const ISA_MOP: u8 = 0b1000_0000;  // Macro-Op Fusion

// 虚拟机版本
pub use machine::{VERSION0, VERSION1, VERSION2};

// 核心类型
pub use decoder::DefaultDecoder;
pub use machine::{DefaultCoreMachine, DefaultMachine, Machine};
pub use memory::{Memory, FlatMemory, SparseMemory, WXorXMemory};
```

**使用示例**：

```rust
use ckb_vm::{
    DefaultCoreMachine,
    DefaultMachineBuilder,
    WXorXMemory,
    ISA_IMC,
    VERSION2,
};
```

---

### 2. decoder.rs - 指令解码器

**路径**：`src/decoder.rs`

**作用**：
- 将二进制机器码解码为 Instruction
- 实现指令缓存
- 实现 Macro-Op Fusion

**核心结构**：

```rust
pub struct DefaultDecoder {
    factories: Vec<InstructionFactory>,  // 指令工厂
    mop: bool,                           // Macro-Op Fusion 开关
    version: u32,                        // VM 版本
    instructions_cache: [(u64, u64); INSTRUCTION_CACHE_SIZE],
}
```

**关键函数**：

| 函数 | 作用 |
|------|------|
| `new()` | 创建解码器，注册指令工厂 |
| `decode()` | 主解码入口 |
| `decode_raw()` | 基础解码（含缓存） |
| `decode_mop()` | Macro-Op Fusion 解码 |
| `decode_bits()` | 从内存读取指令二进制 |

**相关文件**：
- `src/instructions/*.rs` - 各指令集的 factory 函数

---

### 3. elf.rs - ELF 解析器

**路径**：`src/elf.rs`

**作用**：
- 解析 ELF 文件格式
- 提取程序入口和段信息
- 生成 ProgramMetadata

**核心类型**：

```rust
pub struct ProgramMetadata {
    pub entry: u64,                  // 入口地址
    pub actions: Vec<LoadingAction>, // 加载动作
}

pub struct LoadingAction {
    pub addr: u64,       // 加载地址
    pub size: u64,       // 大小
    pub flags: u8,       // 权限标志
    pub source: Range<u64>,  // 源数据范围
    pub offset_from_addr: u64,
}
```

**关键函数**：

```rust
pub fn parse_elf<R: Register>(
    program: &Bytes,
    version: u32,
) -> Result<ProgramMetadata, Error>
```

---

### 4. machine/mod.rs - 虚拟机核心

**路径**：`src/machine/mod.rs`

**作用**：
- 定义 Machine trait 层次结构
- 实现 DefaultMachine
- 执行循环和状态管理

**Trait 层次**：

```rust
pub trait CoreMachine {
    // 最小数据集：PC、寄存器、内存
}

pub trait Machine: CoreMachine {
    // 添加系统调用
    fn ecall(&mut self) -> Result<(), Error>;
    fn ebreak(&mut self) -> Result<(), Error>;
}

pub trait SupportMachine: CoreMachine {
    // 添加生命周期管理
    fn cycles(&self) -> u64;
    fn load_elf(...) -> Result<u64, Error>;
}
```

**DefaultMachine**：

```rust
pub struct DefaultMachine<Inner, Decoder> {
    inner: Inner,
    syscalls: Vec<Box<dyn Syscalls<Inner>>>,
    instruction_cycle_func: Box<InstructionCycleFunc>,
    debugger: Option<Box<dyn Debugger<Inner>>>,
    exit_code: i8,
    // ...
}
```

---

### 5. instructions/execute.rs - 指令执行

**路径**：`src/instructions/execute.rs`

**作用**：
- 指令执行的统一入口
- 根据 opcode 分发到具体实现

**核心函数**：

```rust
pub fn execute<Mac: Machine>(
    instruction: Instruction,
    machine: &mut Mac,
) -> Result<(), Error> {
    let opcode = extract_opcode(instruction);

    match opcode {
        OP_ADD => i::execute_add(instruction, machine),
        OP_MUL => m::execute_mul(instruction, machine),
        OP_LW => i::execute_lw(instruction, machine),
        OP_ECALL => machine.ecall(),
        // ...
    }
}
```

---

### 6. memory/wxorx.rs - 内存保护

**路径**：`src/memory/wxorx.rs`

**作用**：
- 实现 WXorX 内存保护
- 在底层内存基础上添加权限检查

**核心结构**：

```rust
pub struct WXorXMemory<M> {
    inner: M,           // 底层内存实现
    flags: Vec<u8>,     // 权限位图（每页一个字节）
}
```

**关键检查**：

```rust
fn store32(&mut self, addr: &Self::REG, value: &Self::REG) -> Result<(), Error> {
    let page = addr.to_u64() / RISCV_PAGESIZE as u64;

    // WXorX 检查
    if (self.flags[page as usize] & FLAG_EXECUTABLE) != 0 {
        return Err(Error::MemWriteOnExecutablePage(page));
    }

    self.inner.store32(addr, value)
}
```

---

## 🧪 tests/ 测试代码

```
tests/
├── test_asm.rs             # ASM 模式测试
├── test_basic.rs           # 基础功能测试
├── test_chaos.rs           # 混沌测试（边界情况）
├── test_decoder.rs         # 解码器测试
├── test_simple64.rs        # 64 位虚拟机测试
└── test_*.rs               # 其他专项测试
```

**运行测试**：

```bash
# 运行所有测试
cargo test

# 运行特定测试
cargo test test_basic

# 显示详细输出
cargo test -- --nocapture
```

---

## 📊 benches/ 性能基准

```
benches/
├── bench_asm.rs            # ASM 模式基准
└── bench_trace.rs          # Trace 模式基准
```

**运行基准测试**：

```bash
cargo bench
```

---

## 📝 definitions/ 定义文件

**路径**：`definitions/`

**作用**：
- 定义 RISC-V 指令操作码
- 定义寄存器编号和 ABI 名称
- 这些定义被 `src/` 引用

**关键文件**：

```
definitions/src/
├── instructions.rs         # 指令 opcode 定义
└── registers.rs            # 寄存器编号和名称
```

**示例**：

```rust
// instructions.rs
pub const OP_ADD: u32 = 0x33;
pub const OP_SUB: u32 = 0x33;
pub const OP_MUL: u32 = 0x33;

// registers.rs
pub const ZERO: usize = 0;  // x0
pub const RA: usize = 1;    // x1 (return address)
pub const SP: usize = 2;    // x2 (stack pointer)
pub const A0: usize = 10;   // x10 (argument 0)
```

---

## 🔍 快速查找指南

### 想了解某个功能，去哪里找？

| 功能 | 文件路径 |
|------|---------|
| **指令解码** | `src/decoder.rs` |
| **指令执行** | `src/instructions/execute.rs` |
| **ADD 指令实现** | `src/instructions/i.rs` |
| **MUL 指令实现** | `src/instructions/m.rs` |
| **ELF 加载** | `src/elf.rs` |
| **内存管理** | `src/memory/mod.rs` |
| **WXorX 保护** | `src/memory/wxorx.rs` |
| **虚拟机主循环** | `src/machine/mod.rs` → `run_with_decoder()` |
| **Cycles 计费** | `src/cost_model.rs` |
| **系统调用** | `src/syscalls/mod.rs` |
| **错误类型** | `src/error.rs` |

---

## 📖 阅读源码建议顺序

### 初学者路径

1. **先看定义**
   - `definitions/src/instructions.rs`
   - `definitions/src/registers.rs`

2. **理解数据结构**
   - `src/instructions/register.rs` (Register trait)
   - `src/memory/mod.rs` (Memory trait)
   - `src/machine/mod.rs` (Machine trait)

3. **追踪执行流程**
   - `src/elf.rs` → `parse_elf()`
   - `src/machine/mod.rs` → `load_program()`
   - `src/machine/mod.rs` → `run_with_decoder()`
   - `src/decoder.rs` → `decode()`
   - `src/instructions/execute.rs` → `execute()`

4. **深入具体实现**
   - `src/instructions/i.rs` (基础指令)
   - `src/memory/wxorx.rs` (内存保护)

### 专家路径

1. **性能优化**
   - `src/decoder.rs` → Macro-Op Fusion
   - `src/machine/asm/` → ASM 模式

2. **安全机制**
   - `src/memory/wxorx.rs`
   - `src/machine/mod.rs` → `add_cycles()`

3. **版本兼容性**
   - 搜索 `self.version() >= VERSION1`

---

## 🔗 相关链接

- **GitHub 仓库**：https://github.com/nervosnetwork/ckb-vm
- **在线文档**：https://docs.rs/ckb-vm
- **RISC-V 规范**：https://riscv.org/technical/specifications/

---

**返回目录** → [README](README.md)

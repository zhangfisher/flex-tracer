# Zig 服务器 VSCode 调试指南

## 环境配置

### 1. 安装必需的 VSCode 扩展

1. 打开 VSCode 扩展面板 (Ctrl+Shift+X)
2. 安装以下扩展：
   - **Zig Language** (Zig 语言支持)
   - **C/C++ Extension** (调试支持)

### 2. 选择调试方法

#### 方法 A：使用 LLDB（推荐给 LLVM 用户）
1. 安装 LLVM（包含 LLDB 调试器）
2. 将 `lldb.exe` 添加到系统 PATH
3. 使用 "Debug Zig Server" 配置

#### 方法 B：使用 GDB（备选方案）
1. 安装 Windows 版 GDB
2. 将 GDB 添加到系统 PATH
3. 使用 "Debug Zig Server (GDB)" 配置

#### 方法 C：使用 Zig 内置调试（最简单）
1. 构建调试版本：`zig build -Doptimize=Debug`
2. 直接运行并使用打印语句调试

### 3. 开始调试

1. 在 VSCode 中打开项目：`packages/server/`
2. 在代码中点击行号设置断点
3. 按 `F5` 或点击 "运行和调试"
4. 选择 "Debug Zig Server" 或 "Debug Zig Server (GDB)"

## 调试功能

### 基本控制
- **F5**: 启动/继续调试
- **F9**: 切换断点
- **F10**: 单步跳过
- **F11**: 单步进入
- **Shift+F11**: 单步跳出
- **Shift+F5**: 停止调试

### 调试面板
- **变量**: 查看局部变量及其值
- **监视**: 添加表达式进行求值
- **调用堆栈**: 查看函数调用层次
- **断点**: 管理所有断点

## 配置文件说明

### launch.json
包含调试配置：
- **lldb**: LLDB 调试器配置
- **cppdbg**: GDB 调试器配置

### tasks.json
包含构建任务：
- **zig-build-debug**: 构建调试版本
- **zig-build-release**: 构建优化版本
- **zig-build-run**: 构建并运行
- **zig-test**: 运行测试
- **zig-clean**: 清理构建文件

## 调试技巧

### 1. 控制台输出
调试器使用集成终端，所有控制台输出（包括中文文本）应该正确显示。

### 2. 断点技巧
- 在 main.zig 中设置断点来调试服务器初始化
- 在路由处理程序中设置断点来调试 HTTP 请求
- 使用条件断点处理特定场景

### 3. 变量检查
- 将鼠标悬停在变量上查看其值
- 将变量添加到监视面板进行持续监控
- 在变量面板中检查局部作用域变量

### 4. 常见问题

**问题**: 调试器无法启动
- **解决**: 首先确保使用 `zig build` 构建了项目

**问题**: 断点不工作
- **解决**: 确保使用 Debug 模式构建，包含调试符号

**问题**: 无法看到变量值
- **解决**: Release 构建中变量可能被优化掉；使用 Debug 构建

## 备选调试方法

### 1. 打印调试
在代码中添加调试打印：
```zig
std.debug.print("Debug: value = {d}\n", .{some_value});
```

### 2. Zig 内置测试
在文件中添加测试：
```zig
test "my test" {
    // 你的测试代码
}
```

运行方式：`zig build test`

### 3. HTTP 请求调试
使用浏览器开发者工具或 curl 检查 HTTP 响应：
```bash
curl -v http://localhost:3000/api/status
```

## 调试示例

1. **在 `main.zig` 第 42 行设置断点**（显示路由列表的位置）
2. **按 F5** 启动调试
3. **服务器在断点处停止**
4. **按 F10** 逐步执行初始化过程
5. **打开浏览器** 访问 http://localhost:3000
6. **观察** 服务器行为的逐步执行

## 构建模式

- **Debug**: 完整符号，无优化 (`zig build -Doptimize=Debug`)
- **ReleaseSafe**: 优化但保留安全检查 (`zig build -Doptimize=ReleaseSafe`)
- **ReleaseFast**: 最大优化 (`zig build -Doptimize=ReleaseFast`)
- **ReleaseSmall**: 大小优化 (`zig build -Doptimize=ReleaseSmall`)

调试时始终使用 **Debug** 模式以获得最佳体验。

## 快速开始

1. 确保已安装 Zig Language 扩展
2. 打开 `.vscode/launch.json` 文件
3. 按 F5 启动调试
4. 在代码中设置断点开始调试！

## 中文编码支持

已配置控制台 UTF-8 支持，中文输出在调试控制台中会正确显示，不会出现乱码。

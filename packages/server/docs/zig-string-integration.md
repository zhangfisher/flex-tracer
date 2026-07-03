# Zig-String 依赖集成说明

## 概述

FlexTracker 服务器已成功集成 [zig-string](https://github.com/JakubSzark/zig-string) 库，这是一个用于 Zig 语言的字符串处理库。

## 依赖信息

- **库名称**: zig-string
- **版本**: 0.10.0
- **作者**: JakubSzark
- **源地址**: https://github.com/JakubSzark/zig-string

## 集成步骤

### 1. 添加到 build.zig.zon

```zig
.dependencies = .{
    .zig_string = .{
        .url = "https://github.com/JakubSzark/zig-string/archive/refs/heads/master.tar.gz",
        .hash = "zig_string-0.10.0-6dpLWvWcAAAHZQHkJGZ1_-yP2cGhXV35rXxKQZ4vx-Dy",
    },
}
```

### 2. 在 build.zig 中配置模块

```zig
const zig_string = b.dependency("zig_string", .{
    .target = target,
    .optimize = optimize,
});

// 然后在可执行文件的模块导入中添加:
.{ .name = "string", .module = zig_string.module("string") }
```

### 3. 在代码中使用

```zig
const string = @import("string");

// 创建字符串
var my_string = string.String.init(allocator);
defer my_string.deinit();

// 操作字符串
try my_string.concat("Hello");
try my_string.concat(" World");

// 获取字符串内容
const content = my_string.str();
```

## 库功能特性

### 基本操作
- **init()**: 使用分配器初始化字符串
- **deinit()**: 释放字符串内存
- **concat()**: 追加字符串内容
- **str()**: 获取字符串内容（返回 []const u8）
- **len()**: 获取字符串长度（字符数）
- **capacity()**: 获取字符串容量

### 高级操作
- **insert()**: 在指定位置插入字符串
- **remove()**: 删除指定位置的字符
- **split()**: 按分隔符分割字符串
- **trim()**: 去除首尾空白字符
- **reverse()**: 反转字符串
- **toUppercase()**: 转换为大写
- **toLowercase()**: 转换为小写
- **find()**: 查找子字符串位置
- **count()**: 统计子字符串出现次数

## 当前状态

✅ **依赖已添加**: zig-string 已成功添加到项目依赖中
✅ **构建正常**: 项目可以正常编译和运行
✅ **模块可用**: "string" 模块已导入到可执行文件中
⚠️ **兼容性注意**: 该库可能需要 Zig 0.16.1+ 以获得完整功能支持

## 示例端点

服务器提供了一个演示端点来展示依赖集成状态：

**端点**: `GET /api/string-demo`

**响应示例**:
```json
{
  "message": "zig-string library dependency successfully added",
  "status": "available",
  "info": "The zig-string library by JakubSzark has been integrated",
  "usage": "Import with: const string = @import(\"string\");",
  "features": [
    "String manipulation functions",
    "Unicode character support",
    "Memory management with allocators",
    "Various string operations (split, trim, reverse, etc.)"
  ],
  "note": "Direct usage is available but may require Zig 0.16.1+ for full compatibility"
}
```

## 使用示例

### 基本字符串构建

```zig
const string = @import("string");

pub fn buildExample(allocator: std.mem.Allocator) ![]const u8 {
    var message = string.String.init(allocator);
    defer message.deinit();
    
    try message.concat("Hello, ");
    try message.concat("FlexTracker!");
    
    return message.str(); // 返回 "Hello, FlexTracker!"
}
```

### 字符串操作

```zig
var text = string.String.init(allocator);
defer text.deinit();

try text.concat("  Hello World  ");

// 去除空白
text.trim(" ");

// 转换为大写
text.toUppercase();

// 获取长度
const length = text.len(); // 字符数，不是字节数
```

## 注意事项

1. **内存管理**: 使用 `init()` 创建的字符串必须调用 `deinit()` 来释放内存
2. **分配器**: 字符串操作需要提供内存分配器
3. **UTF-8 支持**: 库支持 UTF-8 编码，`len()` 返回字符数而非字节数
4. **容量管理**: 库会自动管理字符串容量的扩展

## 依赖文件位置

下载的依赖文件位于:
```
packages/server/zig-pkg/zig_string-0.10.0-6dpLWvWcAAAHZQHkJGZ1_-yP2cGhXV35rXxKQZ4vx-Dy/
```

## 更新和维护

如需更新 zig-string 版本：

1. 修改 `build.zig.zon` 中的 URL 指向新版本
2. 运行 `zig build` 获取新的 hash 值
3. 更新 hash 字段
4. 重新构建项目

## 参考资料

- [zig-string GitHub 仓库](https://github.com/JakubSzark/zig-string)
- [zig-string 文档](https://github.com/JakubSzark/zig-string/blob/master/README.md)
- 示例路由: `src/routes/string_demo.zig`

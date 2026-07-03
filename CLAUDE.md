# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目架构

这是一个 monorepo 应用追踪项目，采用前后端分离架构：

- **`packages/client/`** - TypeScript 客户端，使用 Bun 运行时
- **`packages/server/`** - Zig HTTP 服务器，使用 httpz 框架
- **`public/`** - 静态资源（favicon、图片等）

### 技术栈

**客户端:**

- Bun (JavaScript 运行时)
- TypeScript (严格模式，ESNext 目标)
- 模块系统：ES Modules with `bundler` resolution

**服务器:**

- Zig 0.16.0+
- httpz 框架 (高性能 HTTP 服务器)
- 构建系统：Zig Build System

## 常用命令

### 客户端开发

```bash
# 进入客户端目录
cd packages/client

# 安装依赖
bun install

# 运行客户端
bun run index.ts

# TypeScript 类型检查（需要手动执行）
tsc --noEmit
```

### 服务器开发

```bash
# 进入服务器目录
cd packages/server

# 构建项目
zig build

# 运行服务器
zig build run

# 运行测试
zig build test

# 查看所有可用的构建命令
zig build --help
```

### 依赖管理

```bash
# 更新 Zig 依赖
cd packages/server
zig build --fetch

# 更新客户端依赖
cd packages/client
bun update
```

## 代码组织原则

### Zig 服务器

- **`src/root.zig`** - 模块入口，导出公共 API
- **`src/main.zig``** - 可执行文件入口点
- **`build.zig`** - 构建配置，定义模块和可执行目标
- **`build.zig.zon`** - 包元数据和依赖声明
- **`HTTP中间件`** - 保存在`pacakges/server/src/middlewares`
- **`工具函数`** - 保存在`pacakges/server/src/utils`
- **`日志输出`** - 使用`nexlog`

模块化设计：业务逻辑在 `root.zig` 模块中，CLI 入口在 `main.zig` 中分离。

### TypeScript 客户端

- **`index.ts`** - 应用入口点
- **`tsconfig.json`** - TypeScript 编译配置（严格模式）

目前客户端结构很简单，随着项目发展可能需要扩展目录结构。

## 开发注意事项

1. **Zig 内存管理**: Zig 使用手动内存管理，注意内存泄漏。所有 `alloc` 调用都需要相应的 `deinit`。
2. **类型安全**: 两个代码库都使用严格类型检查
3. **构建顺序**: 修改服务器代码后需要重新构建，Zig 的构建系统支持增量编译
4. **测试**: Zig 使用内置测试框架，TypeScript 目前未配置测试框架

## 项目状态

这是一个早期阶段的项目，代码库结构简单，为快速迭代设计。随着项目发展可能需要：

- 添加客户端测试框架
- 扩展服务器路由和中间件
- 添加前端框架（如 React/Vue）

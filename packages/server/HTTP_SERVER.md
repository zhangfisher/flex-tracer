# App Tracker HTTP 服务器

基于 Zig 0.16 和 httpz 框架的 HTTP 服务器示例。

## 配置状态

### ✅ httpz 框架配置

- **依赖配置**: `build.zig.zon` 中已正确配置
- **构建配置**: `build.zig` 中 httpz 模块已正确导入
- **包状态**: 完整的 httpz 包已下载到 `zig-pkg/httpz-0.0.0-PNVzrEnoCADpf8B42EMPO2WmIlvsQJ0dJ8oCWjnl6CIX/`
- **Zig 版本**: 0.16.0+ (已配置)
- **示例代码**: 包含 11 个官方示例，从基础到高级用法

## 快速开始

### 构建项目

```bash
cd packages/server
zig build
```

### 运行服务器

```bash
zig build run
```

服务器将在 `http://localhost:3000` 启动。

### 运行测试

```bash
zig build test
```

## API 端点

### 首页 - `GET /`

返回 HTML 页面，显示所有可用的 API 端点。

**示例**:
```bash
curl http://localhost:3000/
```

### Hello 端点 - `GET /hello?name=名字`

返回文本格式的问候消息，支持查询参数。

**示例**:
```bash
curl "http://localhost:3000/hello?name=张三"
# 响应: 你好，张三！
#       欢迎使用 App Tracker 服务器！
```

### 状态检查 - `GET /api/status`

返回服务器状态的 JSON 数据。

**示例**:
```bash
curl http://localhost:3000/api/status
# 响应: {"status":"running","server":"app-tracker","framework":"httpz","version":"0.0.1"}
```

### JSON Hello - `GET /api/hello/:name`

返回 JSON 格式的问候消息，使用路径参数。

**示例**:
```bash
curl http://localhost:3000/api/hello/李四
# 响应: {"message":"你好！","name":"李四","greeting":"欢迎使用 App Tracker"}
```

### 回显端点 - `POST /api/echo`

回显接收到的 POST 数据。

**示例**:
```bash
curl -X POST -d "测试数据" http://localhost:3000/api/echo
# 响应: {"received":"测试数据","length":4,"method":"POST","path":"/api/echo"}
```

## 代码结构

### 主要文件

- **`src/main.zig`**: HTTP 服务器主程序，包含所有路由处理器
- **`src/http_server.zig`**: 独立的 HTTP 服务器模块（备用）
- **`src/root.zig`**: 模块入口，导出公共 API
- **`build.zig`**: 构建配置文件
- **`build.zig.zon`**: 包元数据和依赖声明

### 路由处理器

- `indexHandler`: 首页处理器
- `helloHandler`: Hello 端点处理器（查询参数）
- `statusHandler`: 状态检查处理器（JSON）
- `jsonHelloHandler`: JSON Hello 处理器（路径参数）
- `echoHandler`: 回显端点处理器（POST）

## 技术特性

### httpz 框架特性

- **高性能**: 基于 Zig 的零成本抽象
- **类型安全**: 完全类型安全的路由和参数处理
- **中间件支持**: 支持自定义中间件（本示例使用简单处理器）
- **JSON 支持**: 内置 JSON 序列化支持
- **查询参数**: 简单的查询参数解析
- **路径参数**: RESTful 风格的路径参数

### Zig 0.16 特性

- **Juicy Main**: 使用 `std.process.Init` 作为 main 参数
- **std.Io**: 统一的 I/O 接口
- **内存管理**: 手动内存管理，使用 arena 分配器
- **错误处理**: 使用错误联合类型进行错误处理

## 开发说明

### 内存管理

Zig 使用手动内存管理，所有 `alloc` 调用都需要相应的 `deinit`：

```zig
var server = try httpz.Server(void).init(...);
defer server.deinit();
defer server.stop();
```

### 类型安全

所有类型都在编译时检查，确保类型安全：

```zig
const query = try req.query();
const name = query.get("name") orelse "陌生人";
```

### 错误处理

使用 `try` 关键字处理可能的错误：

```zig
const body = req.body() orelse "";
try res.json(.{ .data = body }, .{});
```

## 下一步

### 建议的扩展

1. **数据库集成**: 添加数据库支持（如 SQLite、PostgreSQL）
2. **中间件**: 添加日志、认证、CORS 等中间件
3. **静态文件服务**: 添加静态文件服务功能
4. **WebSocket 支持**: 实现实时通信
5. **API 文档**: 添加 OpenAPI/Swagger 文档
6. **测试**: 添加单元测试和集成测试
7. **配置管理**: 添加配置文件支持
8. **日志系统**: 实现结构化日志

### 参考资源

- [httpz GitHub 仓库](https://github.com/karlseguin/http.zig)
- [Zig 0.16.0 发布说明](https://ziglang.org/download/0.16.0/release-notes.html)
- [Zig 标准库文档](https://ziglang.org/documentation/0.16.0/)

## 许可证

本项目遵循相应的开源许可证。

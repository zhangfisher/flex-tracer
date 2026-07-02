# 中间件系统说明

## 📁 文件结构

```
src/
├── middlewares/
│   ├── middlewares.zig         # 中间件管理模块
│   ├── response_time.zig      # 响应时间记录中间件
│   ├── logger.zig             # 日志记录中间件
│   └── cors.zig               # CORS 跨域中间件
└── routes/
    └── routes.zig             # 路由注册（可选择性应用中间件）
```

## 🎯 设计原则

### 单一职责原则 (SRP)
每个中间件文件只负责一个特定功能：
- `response_time.zig` → 记录请求响应时间
- `logger.zig` → 记录详细的请求日志
- `cors.zig` → 处理跨域资源共享

### 开闭原则 (OCP)
- 易于添加新的中间件
- 现有中间件可独立修改和扩展
- 支持中间件组合和链式调用

## 🔧 已实现的中间件

### 1. ResponseTime 中间件

**文件**: `middlewares/response_time.zig`

**功能**:
- 记录每个 HTTP 请求的处理时间
- 支持简洁模式和详细模式
- 自动计算微秒级响应时间

**配置选项**:
```zig
pub const Config = struct {
    io: Io,                    // I/O 实例
    detailed: bool = false,    // 是否显示详细信息
};
```

**输出格式**:
- **简洁模式**: `⚡ GET      /                            - 200 -    1.23ms`
- **详细模式**: `📊 [Request] GET        | /                           | Status: 200 | Time:   1234µs | Content-Type: HTML`

**使用示例**:
```zig
const ResponseTime = @import("middlewares/response_time.zig").ResponseTime;
const response_time_middleware = try server.middleware(ResponseTime, .{
    .io = init.io,
    .detailed = false,
});
```

### 2. Logger 中间件

**文件**: `middlewares/logger.zig`

**功能**:
- 记录详细的 HTTP 请求日志
- 支持查询参数和请求体记录
- 记录响应状态和处理时间

**配置选项**:
```zig
pub const Config = struct {
    io: Io,                    // I/O 实例
    log_body: bool = false,   // 是否记录请求体
};
```

**输出格式**:
```
📝 [Request] GET /api/status
   Query: debug=true
   Body: {"test": "data"}...
   Response: 200 (452µs)
```

**使用示例**:
```zig
const Logger = @import("middlewares/logger.zig").Logger;
const logger_middleware = try server.middleware(Logger, .{
    .io = init.io,
    .log_body = true,
});
```

### 3. CORS 中间件

**文件**: `middlewares/cors.zig`

**功能**:
- 处理跨域资源共享
- 支持 OPTIONS 预检请求
- 配置允许的来源、方法和头部

**配置选项**:
```zig
pub const Config = struct {
    allowed_origins: []const []const u8 = &.{.{"*"}},
    allowed_methods: []const []const u8 = &.{ "GET", "POST", "PUT", "DELETE", "OPTIONS" },
    allowed_headers: []const []const u8 = &.{ "Content-Type", "Authorization" },
    allow_credentials: bool = false,
    max_age: u32 = 86400,
};
```

**使用示例**:
```zig
const Cors = @import("middlewares/cors.zig").Cors;
const cors_middleware = try server.middleware(Cors, .{
    .allowed_origins = &.{ "https://example.com", "https://app.example.com" },
    .allowed_methods = &.{ "GET", "POST" },
    .allow_credentials = true,
});
```

## 🚀 中间件使用流程

### 1. 创建中间件实例

在 `main.zig` 中创建中间件实例：

```zig
const ResponseTime = @import("middlewares/response_time.zig").ResponseTime;
const response_time_middleware = try server.middleware(ResponseTime, .{
    .io = init.io,
    .detailed = false,
});
```

### 2. 应用中间件到路由器

将中间件应用到路由器，使其对所有路由生效：

```zig
const router = try server.router(.{});
router.middlewares = &.{response_time_middleware};
```

### 3. 注册路由

正常注册路由，中间件会自动应用：

```zig
try routes.registerRoutes(router);
```

## 🎨 高级用法

### 多中间件组合

可以同时使用多个中间件：

```zig
// 创建多个中间件实例
const response_time = try server.middleware(ResponseTime, .{ .io = init.io });
const logger = try server.middleware(Logger, .{ .io = init.io, .log_body = true });
const cors = try server.middleware(Cors, .{ .io = init.io });

// 按顺序应用中间件
router.middlewares = &.{ response_time, logger, cors };
```

### 选择性应用中间件

为特定路由配置不同的中间件：

```zig
// 全局中间件
router.middlewares = &.{response_time};

// 特定路由覆盖中间件配置
router.get("/public", publicHandler, .{
    .middlewares = &.{cors},  // 只使用 CORS 中间件
    .middleware_strategy = .replace,
});

// 禁用中间件的路由
router.get("/health", healthHandler, .{
    .middlewares = &.{},
    .middleware_strategy = .replace,
});
```

## 📝 创建自定义中间件

### 基本结构

每个中间件需要遵循以下结构：

```zig
const std = @import("std");
const httpz = @import("httpz");

pub const MyMiddleware = @This();

// 1. 定义配置结构
pub const Config = struct {
    io: std.Io,
    // 自定义配置选项
    option1: bool = false,
    option2: u32 = 100,
};

// 2. 定义中间件状态
field1: SomeType,
field2: AnotherType,

// 3. 初始化函数
pub fn init(config: Config) !MyMiddleware {
    return .{
        .field1 = initializeFrom(config),
        .field2 = initializeFrom(config),
    };
}

// 4. 执行函数（必需）
pub fn execute(self: *const MyMiddleware, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // 前置处理
    try self.beforeRequest(req);

    defer {
        // 后置处理
        self.afterResponse(res);
    }

    // 调用下一个处理器
    return executor.next();
}

// 辅助方法
fn beforeRequest(self: *const MyMiddleware, req: *httpz.Request) !void {
    // 请求前处理逻辑
}

fn afterResponse(self: *const MyMiddleware, res: *httpz.Response) void {
    // 响应后处理逻辑
}
```

### 示例：认证中间件

```zig
const std = @import("std");
const httpz = @import("httpz");

pub const Auth = @This();

secret_key: []const u8,

pub const Config = struct {
    secret_key: []const u8,
};

pub fn init(config: Config) !Auth {
    return .{
        .secret_key = config.secret_key,
    };
}

pub fn execute(self: *const Auth, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // 验证 JWT token
    const auth_header = req.headers.get("Authorization") orelse {
        res.status = 401;
        res.body = "Missing Authorization header";
        return;
    };

    if (!self.validateToken(auth_header)) {
        res.status = 403;
        res.body = "Invalid token";
        return;
    }

    // 认证成功，继续处理
    return executor.next();
}

fn validateToken(self: *const Auth, token: []const u8) bool {
    // JWT 验证逻辑
    return true;
}
```

## 🔍 中间件执行流程

```
请求 → 中间件1 → 中间件2 → 中间件3 → 路由处理器 → 响应
       ↓         ↓         ↓         ↓
     前置处理   前置处理   前置处理   处理请求
       ↑         ↑         ↑         ↑
     后置处理   后置处理   后置处理   返回响应
```

## ⚡ 性能考虑

### 中间件开销

- **ResponseTime**: 微秒级开销（仅时间测量）
- **Logger**: 取决于日志量和 I/O 操作
- **CORS**: 添加 HTTP 头的极小开销
- **自定义中间件**: 取决于具体实现

### 优化建议

1. **按需启用**: 只为需要的路由应用中间件
2. **异步日志**: 将日志记录移到独立线程
3. **内存管理**: 使用 arena 分配器减少内存碎片
4. **条件执行**: 在中间件内部添加条件判断

## 🛠️ 调试技巧

### 启用详细日志

```zig
const response_time_middleware = try server.middleware(ResponseTime, .{
    .io = init.io,
    .detailed = true,  // 启用详细模式
});
```

### 禁用特定中间件

```zig
router.get("/bypass", bypassHandler, .{
    .middlewares = &.{},
    .middleware_strategy = .replace,
});
```

### 中间件执行顺序

中间件按照 `router.middlewares` 数组中的顺序执行：

```zig
// 执行顺序：logger → response_time → cors
router.middlewares = &.{ logger, response_time, cors };
```

## 📚 最佳实践

### 1. 命名规范
- 中间件类型: PascalCase (`ResponseTime`)
- 文件名: 小写下划线 (`response_time.zig`)
- 配置结构: `Config`
- 执行方法: `execute`

### 2. 错误处理
```zig
pub fn execute(self: *const MyMiddleware, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // 使用 try 传播错误
    const data = try self.someOperation();

    // 提前返回可以中断请求链
    if (!self.isValid(req)) {
        res.status = 400;
        return; // 不调用 executor.next()
    }

    return executor.next();
}
```

### 3. 资源清理
```zig
pub fn execute(self: *const MyMiddleware, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    const resource = try self.acquireResource();
    defer self.releaseResource(resource);

    // 处理逻辑
    return executor.next();
}
```

### 4. 线程安全
httpz 中间件可能在多线程环境中执行，确保线程安全：
```zig
pub fn execute(self: *MyMiddleware, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // 使用锁保护共享状态
    self.mutex.lock();
    defer self.mutex.unlock();

    return executor.next();
}
```

## 🎯 扩展建议

### 计划中的中间件

1. **RateLimiter** - 请求频率限制
2. **Compressor** - 响应压缩（gzip/brotli）
3. **Cache** - HTTP 缓存控制
4. **Security** - 安全头设置
5. **Metrics** - Prometheus 指标收集

### 贡献指南

创建新中间件时：
1. 在 `src/middlewares/` 下创建新文件
2. 遵循标准中间件结构
3. 添加完整的文档注释
4. 更新 `middlewares.zig` 中的导出列表
5. 添加使用示例和测试

这个中间件系统为 httpz 服务器提供了强大的扩展能力！🚀

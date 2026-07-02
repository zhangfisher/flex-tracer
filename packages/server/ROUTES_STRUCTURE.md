# 路由模块化结构说明

## 📁 文件结构

```
src/
├── main.zig                    # 服务器主入口
├── root.zig                    # 模块入口
└── routes/                     # 路由处理函数目录
    ├── routes.zig             # 路由注册和导出
    ├── index.zig              # 首页处理器
    ├── hello.zig              # Hello 端点处理器
    ├── status.zig             # 状态检查处理器
    ├── json_hello.zig         # JSON Hello 处理器
    └── echo.zig               # 回显端点处理器
```

## 🎯 设计原则

### 单一职责原则 (SRP)
每个文件只负责一个路由处理函数，职责清晰：
- `index.zig` → 处理首页路由
- `hello.zig` → 处理问候端点
- `status.zig` → 处理状态检查
- `json_hello.zig` → 处理 JSON 问候
- `echo.zig` → 处理数据回显

### 开闭原则 (OCP)
- **开**: 可以轻松添加新的路由文件（如 `user.zig`, `auth.zig`）
- **闭**: 修改现有路由不影响其他路由
- **扩展**: 在 `routes.zig` 中注册新路由即可

### DRY 原则
- 消除重复代码：所有路由共享相同的导入模式
- 统一注册方式：通过 `registerRoutes` 函数统一管理

## 📝 文件说明

### routes.zig - 路由管理中心
**职责**：
- 导入所有路由处理函数
- 提供统一的注册接口 `registerRoutes`
- 提供路由信息列表 `getRouteList`

**优势**：
- 集中管理所有路由
- 便于添加中间件或路由前缀
- 支持动态路由注册

### 各个路由文件
每个文件都遵循相同的模式：
```zig
const std = @import("std");
const httpz = @import("httpz");

/// 处理器描述
pub fn handlerName(req: *httpz.Request, res: *httpz.Response) !void {
    // 处理逻辑
}
```

## 🔄 使用流程

### 1. 添加新路由
```bash
# 在 src/routes/ 下创建新文件
touch src/routes/new_route.zig
```

### 2. 实现路由处理器
```zig
// src/routes/new_route.zig
const httpz = @import("httpz");

pub fn newRouteHandler(req: *httpz.Request, res: *httpz.Response) !void {
    res.body = "New route response";
}
```

### 3. 注册路由
```zig
// src/routes/routes.zig
const new_route = @import("new_route.zig");

pub fn registerRoutes(router: anytype) !void {
    // 添加新路由
    router.get("/new", new_route.newRouteHandler, .{});
}
```

### 4. 更新路由信息（可选）
```zig
pub fn getRouteList() []const RouteInfo {
    return &[_]RouteInfo{
        // ... 现有路由
        .{ .method = "GET", .path = "/new", .description = "新路由" },
    };
}
```

## 🎨 扩展示例

### 添加路由前缀
```zig
// routes.zig
pub fn registerApiRoutes(router: anytype) !void {
    const api_router = router.prefix("/api/v1");
    api_router.get("/users", users.listHandler, .{});
    api_router.post("/users", users.createHandler, .{});
}
```

### 添加中间件
```zig
// routes.zig
pub fn registerRoutes(router: anytype) !void {
    // 全局中间件
    router.middleware(authMiddleware);

    // 路由注册
    router.get("/", index.indexHandler, .{});
    router.get("/admin", admin.adminHandler, .{});
}
```

### 按功能分组
```
src/routes/
├── api/
│   ├── users.zig
│   ├── posts.zig
│   └── comments.zig
├── auth/
│   ├── login.zig
│   └── register.zig
└── routes.zig
```

## ✅ 优势总结

### 可维护性
- ✅ 职责清晰，每个文件功能单一
- ✅ 易于定位和修改特定路由
- ✅ 减少代码冲突

### 可扩展性
- ✅ 新增路由只需添加文件和注册
- ✅ 支持路由分组和嵌套
- ✅ 便于集成中间件

### 可测试性
- ✅ 每个路由可独立测试
- ✅ 便于模拟和隔离测试
- ✅ 支持测试覆盖率统计

### 团队协作
- ✅ 多人并行开发不同路由
- ✅ 减少代码合并冲突
- ✅ 清晰的代码审查边界

## 📊 性能影响

### 编译时优化
- ✅ Zig 在编译时内联路由函数
- ✅ 零运行时开销的模块化
- ✅ 编译器自动优化路由注册

### 运行时性能
- ✅ 无性能损失
- ✅ 路由查找仍是 O(1) 哈希表
- ✅ 内存分配模式保持不变

## 🛠️ 最佳实践

### 命名规范
- 文件名: 小写下划线 (`user_profile.zig`)
- 处理函数: 描述性名称 (`getUserProfileHandler`)
- 路由路径: RESTful 风格 (`/api/users/:id`)

### 错误处理
```zig
pub fn handler(req: *httpz.Request, res: *httpz.Response) !void {
    // 使用 try 传播错误
    const data = try someOperation();

    // 使用 orelse 提供默认值
    const name = req.param("name") orelse "guest";
}
```

### 内存管理
```zig
pub fn handler(req: *httpz.Request, res: *httpz.Response) !void {
    // 使用 res.arena（自动清理）
    const formatted = try std.fmt.allocPrint(res.arena, "Hello {s}", .{"World"});

    // 避免手动内存管理
    res.body = formatted;
}
```

这种模块化结构为项目的长期发展奠定了坚实基础！🚀

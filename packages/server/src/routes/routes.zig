const httpz = @import("httpz");

// 导入各个路由处理函数
const index = @import("index.zig");
const hello = @import("hello.zig");
const status = @import("status.zig");
const json_hello = @import("json_hello.zig");
const echo = @import("echo.zig");

/// 注册所有路由到路由器
/// 这个版本不接受中间件参数，中间件应该在 main.zig 中设置
pub fn registerRoutes(router: anytype) !void {
    // 注册路由处理函数
    // 支持的方法: get, post, put, delete, head, trace, options, all
    router.get("/", index.indexHandler, .{});
    router.get("/hello", hello.helloHandler, .{});
    router.get("/api/status", status.statusHandler, .{});
    router.get("/api/hello/:name", json_hello.jsonHelloHandler, .{});
    router.post("/api/echo", echo.echoHandler, .{});
}

/// 获取所有可用的路由信息（用于文档生成）
pub const RouteInfo = struct {
    method: []const u8,
    path: []const u8,
    description: []const u8,
};

pub fn getRouteList() []const RouteInfo {
    return &[_]RouteInfo{
        .{ .method = "GET", .path = "/", .description = "Home page (route list)" },
        .{ .method = "GET", .path = "/hello", .description = "Hello endpoint (query params)" },
        .{ .method = "GET", .path = "/api/status", .description = "Status check (JSON)" },
        .{ .method = "GET", .path = "/api/hello/:name", .description = "JSON Hello (path params)" },
        .{ .method = "POST", .path = "/api/echo", .description = "Echo endpoint (POST data)" },
    };
}

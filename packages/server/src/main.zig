const std = @import("std");
const httpz = @import("httpz");
const routes = @import("routes/routes.zig");

const PORT = 3000;

// 简单的 HTTP 服务器示例
// 演示 httpz 框架的基本用法和中间件集成

pub fn main(init: std.process.Init) !void {
    // 初始化控制台编码为 UTF-8（解决中文乱码问题）
    const console = @import("utils/console.zig");
    console.initConsole();

    const allocator = init.gpa;

    // 初始化 HTTP 服务器
    var server = try httpz.Server(void).init(init.io, allocator, .{
        .address = .localhost(PORT),
        .request = .{
            // 配置最大表单字段数（用于表单数据处理）
            .max_form_count = 20,
        },
    }, {});
    defer server.deinit();

    // 确保优雅关闭，完成现有的请求
    defer server.stop();

    // 创建响应时间中间件实例
    const ResponseTimeMiddleware = @import("middlewares/response_time.zig").ResponseTime;
    const response_time_middleware = try server.middleware(ResponseTimeMiddleware, .{
        .io = init.io,
        .detailed = false, // 使用简洁模式
    });

    // 创建路由器
    const router = try server.router(.{});

    // 应用中间件到所有路由
    router.middlewares = &.{response_time_middleware};

    // 注册所有路由
    try routes.registerRoutes(router);

    std.debug.print("🚀 HTTP server started at http://localhost:{d}/\n", .{PORT});
    std.debug.print("🔧 Enabled middlewares:\n", .{});
    std.debug.print("   ⚡ ResponseTime - Log request response time\n", .{});

    const route_list = routes.getRouteList();
    std.debug.print("📝 Available routes:\n", .{});
    for (route_list) |route| {
        std.debug.print("   {s:4} {s:30} - {s}\n", .{ route.method, route.path, route.description });
    }

    std.debug.print("\n📊 Request logs will be displayed below:\n", .{});

    // 启动服务器（阻塞调用）
    try server.listen();
}

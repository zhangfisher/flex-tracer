// Middleware management module
// Unified management and export of all middleware

const std = @import("std");
const httpz = @import("httpz");

// Import individual middleware
const response_time = @import("response_time.zig");
const logger = @import("logger.zig");
const cors = @import("cors.zig");

/// Middleware information
pub const MiddlewareInfo = struct {
    name: []const u8,
    description: []const u8,
    enabled: bool,
};

/// Get all available middleware information
pub fn getMiddlewareList() []const MiddlewareInfo {
    return &[_]MiddlewareInfo{
        .{ .name = "ResponseTime", .description = "Log response time for each request", .enabled = true },
        .{ .name = "Logger", .description = "Log detailed request information", .enabled = false },
        .{ .name = "Cors", .description = "Handle Cross-Origin Resource Sharing", .enabled = false },
    };
}

/// Export middleware types
pub const ResponseTime = response_time.ResponseTime;
pub const Logger = logger.Logger;
pub const Cors = cors.Cors;

/// Export middleware configuration types
pub const ResponseTimeConfig = response_time.Config;
pub const LoggerConfig = logger.Config;
pub const CorsConfig = cors.Config;

/// Middleware Manager - 统一管理所有中间件的初始化
pub const MiddlewareManager = struct {
    allocator: std.mem.Allocator,
    io: std.Io,

    /// 初始化管理器
    pub fn init(allocator: std.mem.Allocator, io: std.Io) !MiddlewareManager {
        return .{
            .allocator = allocator,
            .io = io,
        };
    }

    /// 清理管理器
    pub fn deinit(self: *MiddlewareManager) void {
        _ = self;
    }

    /// 初始化并返回所有中间件实例
    /// 返回一个包含单个中间件的数组
    pub fn initMiddlewares(self: *MiddlewareManager, server: *httpz.Server(void)) !struct { middleware: httpz.Middleware(void) } {
        // 创建响应时间中间件实例
        const response_time_middleware = try server.middleware(ResponseTime, .{
            .io = self.io,
            .detailed = false, // 使用简洁模式
        });

        // 返回包含中间件实例的结构体
        return .{ .middleware = response_time_middleware };
    }

    /// 获取已启用的中间件信息
    pub fn getEnabledMiddlewares() []const MiddlewareInfo {
        return &[_]MiddlewareInfo{
            .{ .name = "ResponseTime", .description = "Log request response time", .enabled = true },
        };
    }
};

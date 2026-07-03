//! 日志模块 - 提供 nexlog 初始化和全局 logger 对象
const std = @import("std");
const nexlog = @import("nexlog");

/// 全局 logger 实例
var global_logger: ?*nexlog.Logger = null;
var logger_allocator: ?std.mem.Allocator = null;

/// 日志级别枚举
pub const LogLevel = nexlog.LogLevel;

/// 日志配置
pub const LogConfig = nexlog.LogConfig;

/// 初始化全局 logger
pub fn init(allocator: std.mem.Allocator, config: LogConfig) !void {
    if (global_logger != null) {
        return; // 已经初始化过了
    }

    logger_allocator = allocator;
    global_logger = try nexlog.Logger.init(allocator, config);
}

/// 反初始化全局 logger
pub fn deinit() void {
    if (global_logger) |logger| {
        logger.deinit();
        if (logger_allocator) |alloc| {
            alloc.destroy(logger);
        }
        global_logger = null;
        logger_allocator = null;
    }
}

/// 获取全局 logger
pub fn get() ?*nexlog.Logger {
    return global_logger;
}

/// 检查 logger 是否已初始化
pub fn isInitialized() bool {
    return global_logger != null;
}

// 便捷日志函数

/// 记录 debug 级别日志
pub fn debug(comptime msg: []const u8, args: anytype) void {
    if (global_logger) |logger| {
        logger.log(.debug, msg, args, null) catch {};
    }
}

/// 记录 info 级别日志
pub fn info(comptime msg: []const u8, args: anytype) void {
    if (global_logger) |logger| {
        logger.log(.info, msg, args, null) catch {};
    }
}

/// 记录 warn 级别日志
pub fn warn(comptime msg: []const u8, args: anytype) void {
    if (global_logger) |logger| {
        logger.log(.warn, msg, args, null) catch {};
    }
}

/// 记录 error 级别日志
pub fn err(comptime msg: []const u8, args: anytype) void {
    if (global_logger) |logger| {
        logger.log(.err, msg, args, null) catch {};
    }
}

/// 记录 fatal 级别日志
pub fn fatal(comptime msg: []const u8, args: anytype) void {
    if (global_logger) |logger| {
        logger.log(.fatal, msg, args, null) catch {};
    }
}

/// 创建默认配置
pub fn createDefaultConfig() LogConfig {
    return LogConfig{
        .min_level = .info,
        .enable_console = true,
        .enable_colors = true,
        .enable_file_logging = false,
        .enable_metadata = true,
    };
}

/// 创建带文件日志的配置
pub fn createFileConfig(file_path: []const u8, min_level: LogLevel) LogConfig {
    return LogConfig{
        .min_level = min_level,
        .enable_console = true,
        .enable_colors = true,
        .enable_file_logging = true,
        .file_path = file_path,
        .max_file_size = 10 * 1024 * 1024, // 10MB
        .enable_rotation = true,
        .max_rotated_files = 5,
        .enable_metadata = true,
    };
}

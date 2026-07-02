// Middleware management module
// Unified management and export of all middleware

const std = @import("std");

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

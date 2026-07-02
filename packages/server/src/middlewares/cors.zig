// CORS middleware
// Handle Cross-Origin Resource Sharing

const std = @import("std");
const httpz = @import("httpz");

pub const Cors = @This();

/// Allowed origins
allowed_origins: []const []const u8,
/// Allowed methods
allowed_methods: []const []const u8,
/// Allowed headers
allowed_headers: []const []const u8,
/// Allow credentials
allow_credentials: bool,
/// Preflight cache time (seconds)
max_age: u32,

/// Middleware configuration
pub const Config = struct {
    allowed_origins: []const []const u8 = &.{.{"*"}},
    allowed_methods: []const []const u8 = &.{ "GET", "POST", "PUT", "DELETE", "OPTIONS" },
    allowed_headers: []const []const u8 = &.{ "Content-Type", "Authorization" },
    allow_credentials: bool = false,
    max_age: u32 = 86400, // 24 hours
};

/// Initialize middleware
pub fn init(config: Config) !Cors {
    return .{
        .allowed_origins = config.allowed_origins,
        .allowed_methods = config.allowed_methods,
        .allowed_headers = config.allowed_headers,
        .allow_credentials = config.allow_credentials,
        .max_age = config.max_age,
    };
}

/// Execute middleware
pub fn execute(self: *const Cors, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // Handle preflight request
    if (req.method == .OPTIONS) {
        // Set CORS headers
        res.headers.set("Access-Control-Allow-Origin", "*");

        const methods = try std.mem.join(self.allocator, ", ", self.allowed_methods);
        defer self.allocator.free(methods);
        res.headers.set("Access-Control-Allow-Methods", methods);

        const headers = try std.mem.join(self.allocator, ", ", self.allowed_headers);
        defer self.allocator.free(headers);
        res.headers.set("Access-Control-Allow-Headers", headers);

        if (self.allow_credentials) {
            res.headers.set("Access-Control-Allow-Credentials", "true");
        }

        res.headers.set("Access-Control-Max-Age", try std.fmt.allocPrint(self.allocator, "{d}", .{self.max_age}));

        // Preflight request doesn't need further processing
        res.status = 204;
        return;
    }

    // For actual requests, set headers first then continue processing
    res.headers.set("Access-Control-Allow-Origin", "*");
    if (self.allow_credentials) {
        res.headers.set("Access-Control-Allow-Credentials", "true");
    }

    return executor.next();
}

/// Get allocator (for string concatenation)
fn allocator(_: *const Cors) std.mem.Allocator {
    // Need to get allocator from somewhere
    // Due to httpz middleware structure, we may need to redesign this
    return std.heap.page_allocator; // Temporary solution
}

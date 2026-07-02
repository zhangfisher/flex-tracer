// Logging middleware
// Log detailed information for all HTTP requests

const std = @import("std");
const httpz = @import("httpz");

const Io = std.Io;

pub const Logger = @This();

io: Io,
log_body: bool,

/// Middleware configuration
pub const Config = struct {
    io: Io,
    log_body: bool = false, // Log request body
};

/// Initialize middleware
pub fn init(config: Config) !Logger {
    return .{
        .io = config.io,
        .log_body = config.log_body,
    };
}

/// Execute middleware
pub fn execute(self: *const Logger, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    const start = Io.Timestamp.now(self.io, .awake);

    defer {
        const elapsed = start.untilNow(self.io, .awake);

        // Log request information
        std.log.info("📝 [Request] {s} {s}", .{ @tagName(req.method), req.url.path });

        // Log query parameters (if any)
        if (req.url.query.len > 0) {
            std.log.info("   Query: {s}", .{req.url.query});
        }

        // Log request body (if configured)
        if (self.log_body) {
            if (req.body()) |body| {
                if (body.len > 0) {
                    const preview = if (body.len > 100) body[0..100] else body;
                    std.log.info("   Body: {s}...", .{preview});
                }
            }
        }

        // Log response status
        std.log.info("   Response: {d} ({d}µs)", .{ res.status, elapsed.toMicroseconds() });
    }

    return executor.next();
}

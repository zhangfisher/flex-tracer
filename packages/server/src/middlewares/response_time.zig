// Response time logging middleware
// Log processing time and basic info for each HTTP request

const std = @import("std");
const httpz = @import("httpz");

const Io = std.Io;

pub const ResponseTime = @This();

io: Io,
detailed: bool,

/// Middleware configuration
pub const Config = struct {
    io: Io,
    detailed: bool = false, // Show detailed information
};

/// Initialize middleware
pub fn init(config: Config) !ResponseTime {
    return .{
        .io = config.io,
        .detailed = config.detailed,
    };
}

/// Execute middleware
pub fn execute(self: *const ResponseTime, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // Record start time
    const start = Io.Timestamp.now(self.io, .awake);

    defer {
        // Calculate processing time
        const elapsed = start.untilNow(self.io, .awake);

        if (self.detailed) {
            // Detailed mode: show more information
            const content_type_str = if (res.content_type) |ct| @tagName(ct) else "null";
            std.log.info("📊 [Request] {s:12} | {s:30} | Status: {d:3} | Time: {d:6}µs | Content-Type: {s}",
                .{ @tagName(req.method), req.url.path, res.status, elapsed.toMicroseconds(), content_type_str }
            );
        } else {
            // Simple mode: show key information only
            const elapsed_ms = @as(f64, @floatFromInt(elapsed.toMicroseconds())) / 1000.0;
            std.log.info("⚡ {s:12} {s:30} - {d:3} - {d:6.2}ms",
                .{ @tagName(req.method), req.url.path, res.status, elapsed_ms }
            );
        }
    }

    // Call next handler
    return executor.next();
}

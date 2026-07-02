const std = @import("std");
const httpz = @import("httpz");

/// Status handler - returns JSON status
pub fn statusHandler(_: *httpz.Request, res: *httpz.Response) !void {
    // Set response type to JSON
    res.content_type = httpz.ContentType.JSON;

    // Use res.json method to serialize JSON object
    // Note: In Zig 0.16, timestamps need to be obtained via std.Io.Clock
    // For simplicity, timestamp field is removed in this example
    try res.json(.{
        .status = "running",
        .server = "app-tracker",
        .framework = "httpz",
        .version = "0.0.1",
    }, .{});
}

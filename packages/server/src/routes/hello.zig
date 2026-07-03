const std = @import("std");
const httpz = @import("httpz");

/// Hello handler - demonstrates query parameter handling
pub fn helloHandler(req: *httpz.Request, res: *httpz.Response) !void {
    // Parse query parameters
    const query = try req.query();
    const name = query.get("name") orelse "stranger";

    // Set response type to plain text
    res.content_type = httpz.ContentType.TEXT;

    // Use arena allocator to create response (auto cleanup after request)
    res.body = try std.fmt.allocPrint(res.arena, "Hello, {s}!\nWelcome to FlexTracker server!", .{name});
}

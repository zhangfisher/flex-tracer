const std = @import("std");
const httpz = @import("httpz");

/// Echo handler - demonstrates POST request handling
pub fn echoHandler(req: *httpz.Request, res: *httpz.Response) !void {
    // Get request body
    const body = req.body() orelse "";

    // Set response type to JSON
    res.content_type = httpz.ContentType.JSON;

    // Echo back received data
    try res.json(.{
        .received = body,
        .length = body.len,
        .method = @tagName(req.method),
        .path = req.url.path,
    }, .{});
}

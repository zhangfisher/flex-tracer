const std = @import("std");
const httpz = @import("httpz");

/// JSON Hello handler - demonstrates path parameter handling
pub fn jsonHelloHandler(req: *httpz.Request, res: *httpz.Response) !void {
    // Get name from path parameter
    const name = req.param("name") orelse "stranger";

    // Set response type to JSON
    res.content_type = httpz.ContentType.JSON;

    // Return JSON response
    try res.json(.{
        .message = "Hello!",
        .name = name,
        .greeting = "Welcome to FlexTracker",
    }, .{});
}

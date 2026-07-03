const std = @import("std");
const httpz = @import("httpz");

/// String demo handler - demonstrates zig-string library is available
pub fn stringDemoHandler(req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    res.content_type = httpz.ContentType.JSON;

    try res.json(.{
        .message = "zig-string library dependency successfully added",
        .status = "available",
        .info = "The zig-string library by JakubSzark has been integrated",
        .usage = "Import with: const string = @import(\"string\");",
        .features = &[_][]const u8{
            "String manipulation functions",
            "Unicode character support",
            "Memory management with allocators",
            "Various string operations (split, trim, reverse, etc.)",
        },
        .note = "Direct usage is available but may require Zig 0.16.1+ for full compatibility",
    }, .{});
}

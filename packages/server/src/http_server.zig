const std = @import("std");
const httpz = @import("httpz");

const PORT = 3000;
const Allocator = std.mem.Allocator;

// Simple HTTP server example
// Demonstrates basic usage of httpz framework

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    // Initialize HTTP server
    // Use void handler type, this is the simplest approach
    var server = try httpz.Server(void).init(init.io, allocator, .{
        .address = .localhost(PORT),
        .request = .{
            // Configure maximum form field count (for form data processing)
            .max_form_count = 20,
        },
    }, {});
    defer server.deinit();

    // Ensure graceful shutdown, complete existing requests
    defer server.stop();

    // Create router
    var router = try server.router(.{});

    // Register route handlers
    // Supported methods: get, post, put, delete, head, trace, options, all
    router.get("/", indexHandler, .{});
    router.get("/hello", helloHandler, .{});
    router.get("/api/status", statusHandler, .{});
    router.get("/api/hello/:name", jsonHelloHandler, .{});
    router.post("/api/echo", echoHandler, .{});

    std.debug.print("🚀 HTTP server started at http://localhost:{d}/\n", .{PORT});
    std.debug.print("📝 Available routes:\n", .{});
    std.debug.print("   GET  /           - Home page (route list)\n", .{});
    std.debug.print("   GET  /hello      - Hello endpoint (query params)\n", .{});
    std.debug.print("   GET  /api/status - Status check (JSON)\n", .{});
    std.debug.print("   GET  /api/hello/:name - JSON Hello (path params)\n", .{});
    std.debug.print("   POST /api/echo   - Echo endpoint (POST data)\n", .{});

    // Start server (blocking call)
    try server.listen();
}

// Home page handler - displays all available routes
fn indexHandler(_: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = httpz.ContentType.HTML;
    res.body =
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\    <meta charset="UTF-8">
        \\    <title>FlexTracker API</title>
        \\    <style>
        \\        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
        \\        h1 { color: #333; }
        \\        .endpoint { background: #f4f4f4; padding: 10px; margin: 10px 0; border-radius: 5px; }
        \\        .method { display: inline-block; background: #007bff; color: white; padding: 2px 8px; border-radius: 3px; margin-right: 10px; }
        \\        code { background: #e9ecef; padding: 2px 6px; border-radius: 3px; }
        \\    </style>
        \\</head>
        \\ <body>
        \\    <h1>🚀 FlexTracker API Server</h1>
        \\    <p>Welcome to HTTP server built with httpz framework!</p>
        \\
        \\    <h2>Available API Endpoints:</h2>
        \\
        \\    <div class="endpoint">
        \\        <span class="method">GET</span>
        \\        <code>/</code> - Current page
        \\    </div>
        \\
        \\    <div class="endpoint">
        \\        <span class="method">GET</span>
        \\        <code>/hello?name=YourName</code> - Greeting endpoint (query params)
        \\    </div>
        \\
        \\    <div class="endpoint">
        \\        <span class="method">GET</span>
        \\        <code>/api/status</code> - Server status (JSON)
        \\    </div>
        \\
        \\    <div class="endpoint">
        \\        <span class="method">GET</span>
        \\        <code>/api/hello/:name</code> - JSON greeting (path params)
        \\    </div>
        \\
        \\    <div class="endpoint">
        \\        <span class="method">POST</span>
        \\        <code>/api/echo</code> - Echo POST data
        \\    </div>
        \\
        \\    <hr>
        \\    <p><small>Powered by httpz framework</small></p>
        \\</body>
        \\</html>
    ;
}

// Hello handler - demonstrates query parameter handling
fn helloHandler(req: *httpz.Request, res: *httpz.Response) !void {
    // Parse query parameters
    const query = try req.query();
    const name = query.get("name") orelse "stranger";

    // Set response type to plain text
    res.content_type = httpz.ContentType.TEXT;

    // Use arena allocator to create response (auto cleanup after request)
    res.body = try std.fmt.allocPrint(res.arena, "Hello, {s}!\nWelcome to FlexTracker server!", .{name});
}

// Status handler - returns JSON status
fn statusHandler(_: *httpz.Request, res: *httpz.Response) !void {
    // Set response type to JSON
    res.content_type = httpz.ContentType.JSON;

    // Use res.json method to serialize JSON object
    try res.json(.{
        .status = "running",
        .server = "flextracker",
        .framework = "httpz",
        .version = "0.0.1",
        .timestamp = std.time.timestamp(),
    }, .{});
}

// JSON Hello handler - demonstrates path parameter handling
fn jsonHelloHandler(req: *httpz.Request, res: *httpz.Response) !void {
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

// Echo handler - demonstrates POST request handling
fn echoHandler(req: *httpz.Request, res: *httpz.Response) !void {
    // Get request body
    const body = try req.body();

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

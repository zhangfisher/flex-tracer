const std = @import("std");
const httpz = @import("httpz");

/// Home page handler - displays all available routes
pub fn indexHandler(_: *httpz.Request, res: *httpz.Response) !void {
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

// Windows console encoding setup utility
// Solves Chinese output garbled text issues

const std = @import("std");
const builtin = @import("builtin");

// Import Windows API via @cImport
const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", {});
    @cInclude("windows.h");
});

/// Set Windows console encoding to UTF-8
/// This is crucial for proper display of Chinese and other Unicode characters
///
/// Cross-platform compatibility:
/// - Windows: Sets console to UTF-8 encoding (solves Chinese garbled text)
/// - Linux/macOS: Does nothing (terminals default to UTF-8)
pub fn setConsoleToUtf8() void {
    // Only execute on Windows
    if (builtin.os.tag == .windows) {
        // UTF-8 code page: 65001
        const CP_UTF8 = 65001;

        // Call Windows API to set console encoding
        _ = c.SetConsoleOutputCP(CP_UTF8);
        _ = c.SetConsoleCP(CP_UTF8);
    }
    // Linux and macOS terminals default to UTF-8, no special handling needed
}

/// Initialize console (call at program startup)
/// Ensures Chinese and Unicode characters display correctly
pub fn initConsole() void {
    setConsoleToUtf8();
}

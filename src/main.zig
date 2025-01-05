const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Base64 = @import("Base64.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const base64 = Base64.init();
    const out = try base64.encode(allocator, "Hi");
    defer allocator.free(out);

    const out1 = try base64.decode(allocator, out);
    defer allocator.free(out1);

    try stdout.print("{s}\n", .{out1});
}

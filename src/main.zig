const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Base64 = @import("Base64.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // const file = try std.fs.openFileAbsolute("/home/rawa/Dropbox/scrum.pdf", .{});
    // defer file.close();
    // const bytes = try file.readToEndAlloc(allocator, 5 * 1024 * 1024 * 1024);
    // defer allocator.free(bytes);

    const base64 = Base64.init(allocator);
    const in = try base64.encode("Hi");
    defer allocator.free(in);

    const out = try base64.decode(in);
    defer allocator.free(out);

    try stdout.print("encoded: {s}\ndecoded: {s}\n", .{ in, out });
}

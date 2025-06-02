const std = @import("std");
const lib = @import("zigg");

const stdout = std.io.getStdOut().writer();
const Base64 = lib.Base64;

pub fn main() !void {
    var mutex = std.Thread.Mutex{};

    const t1 = try std.Thread.spawn(.{}, struct {
        pub fn proc(mt: *std.Thread.Mutex) void {
            for (0..11) |i| {
                mt.lock();
                stdout.print("thread: 1 - print: {d}\n", .{i}) catch unreachable;
                mt.unlock();
            }
        }
    }.proc, .{&mutex});

    const t2 = try std.Thread.spawn(.{}, struct {
        pub fn proc(mt: *std.Thread.Mutex) void {
            for (0..11) |i| {
                mt.lock();
                stdout.print("thread: 2 - print: {d}\n", .{i}) catch unreachable;
                mt.unlock();
            }
        }
    }.proc, .{&mutex});

    const t3 = try std.Thread.spawn(.{}, struct {
        pub fn proc(mt: *std.Thread.Mutex) void {
            for (0..11) |i| {
                mt.lock();
                stdout.print("thread: 3 - print: {d}\n", .{i}) catch unreachable;
                mt.unlock();
            }
        }
    }.proc, .{&mutex});

    t1.join();
    t2.join();
    t3.join();

    try base64fn();
}

pub fn base64fn() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // const file = try std.fs.openFileAbsolute("/home/rawa/Dropbox/scrum.pdf", .{});
    // defer file.close();
    //
    // const bytes = try file.readToEndAlloc(allocator, 5 * 1024 * 1024 * 1024);
    // defer allocator.free(bytes);

    const base64 = Base64.init();

    const in = try base64.encode(allocator, "Hi");
    const out = try base64.decode(allocator, in);

    defer {
        allocator.free(out);
        allocator.free(in);
    }

    try stdout.print("encoded: {s}\ndecoded: {s}\n", .{ in, out });
}

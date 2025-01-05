const std = @import("std");
const allocator = std.testing.allocator;
const dsa = @import("collections.zig");
const inf = @import("interfaces.zig");
const expect = std.testing.expect;
const assert = std.testing.expectEqual;
const print = std.debug.print;
const Base64 = @import("Base64.zig");

test "bubble sort" {
    var arr = [_]u32{ 35, 22, 9, 12, 65, 54 };

    dsa.bubbleSort(@TypeOf(arr[0]), &arr);

    // print("arr: {any}\n", .{arr});

    try expect(dsa.sorted(@TypeOf(arr[0]), &arr));
}

test "quick sort" {
    var arr = [_]u8{ 35, 22, 9, 12, 65, 54 };

    dsa.quickSort(@TypeOf(arr[0]), &arr, 0, arr.len - 1);

    // print("arr: {any}\n", .{arr});

    try expect(dsa.sorted(@TypeOf(arr[0]), &arr));
}

test "stack" {
    const val: u32 = 1;
    var stack = dsa.Stack(@TypeOf(val)).init(allocator);
    defer stack.deinit();

    try stack.push(val);
    try stack.push(val + 1);
    _ = stack.pop();
    try stack.push(val + 2);
    try stack.push(val + 3);
    _ = stack.pop();

    try assert(3, stack.peek());
}

test "interface" {
    const T = []const u8;
    var foo = inf.Foo(T).init("halo foo");
    var bar = inf.Bar(T).init("halo bar");

    var foo_handler = foo.handler();
    var bar_handler = bar.handler();

    foo_handler.handle();
    bar_handler.handle();
}

test "queue" {
    var queue = dsa.Queue(u32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    _ = queue.dequeue();
    try queue.enqueue(3);
    try queue.enqueue(4);
    _ = queue.dequeue();

    try assert(3, queue.first());
    try assert(4, queue.last());
}

test "tree" {
    const T = u8;
    var tree = dsa.BSTree(T).init(allocator);
    defer tree.deinit();

    try tree.insert(5);
    try tree.insert(2);
    try tree.insert(3);
    try tree.insert(8);
    try tree.insert(6);

    const pre = try tree.preOrderSearch();
    defer pre.deinit();

    const in = try tree.inOrderSearch();
    defer in.deinit();

    const post = try tree.postOrderSearch();
    defer post.deinit();

    try expect(std.mem.eql(T, &[_]T{ 5, 2, 3, 8, 6 }, pre.items));
    try expect(std.mem.eql(T, &[_]T{ 2, 3, 5, 6, 8 }, in.items));
    try expect(std.mem.eql(T, &[_]T{ 3, 2, 6, 8, 5 }, post.items));

    const bfs1 = try tree.breathFirstSearch(6);
    const bfs2 = try tree.breathFirstSearch(2);
    const bfs3 = try tree.breathFirstSearch(10);

    try expect(bfs1);
    try expect(bfs2);
    try expect(!bfs3);
}

test "base64 encode" {
    const base64 = Base64.init();
    const out = try base64.encode(allocator, "Hi");
    defer allocator.free(out);

    try expect(std.mem.eql(u8, "SGk=", out));
}

test "base64 decode" {
    const base64 = Base64.init();
    const out = try base64.decode(allocator, "SGk=");
    defer allocator.free(out);

    try expect(std.mem.eql(u8, "Hi", out));
}

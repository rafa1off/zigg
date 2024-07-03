const std = @import("std");
const allocator = std.testing.allocator;
const dsa = @import("collections.zig");
const inf = @import("interfaces.zig");
const expect = std.testing.expect;
const assert = std.testing.expectEqual;
const print = std.debug.print;

test "bubble sort" {
    var arr = [_]u32{ 35, 22, 9, 12, 65, 54 };

    dsa.bubble_sort(@TypeOf(arr[0]), &arr);

    // print("arr: {any}\n", .{arr});

    try expect(dsa.is_sorted(@TypeOf(arr[0]), &arr));
}

test "quick sort" {
    var arr = [_]u8{ 35, 22, 9, 12, 65, 54 };

    dsa.quick_sort(@TypeOf(arr[0]), &arr, 0, arr.len - 1);

    // print("arr: {any}\n", .{arr});

    try expect(dsa.is_sorted(@TypeOf(arr[0]), &arr));
}

test "stack" {
    const val: u32 = 1;
    var stack = dsa.Stack(@TypeOf(val)).init(allocator);
    defer stack.deinit();

    try stack.push(val);
    try stack.push(val + 1);
    _ = stack.pop();
    try stack.push(val + 2);
    _ = stack.pop();

    try assert(1, stack.peek());
}

test "interface" {
    const foo = inf.Foo([]const u8).init("halo");

    foo.handler().handle();
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
    var tree = dsa.BSTree(u32).init(allocator);
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

    std.debug.print("\n", .{});
    std.debug.print("arr: {any}\n", .{pre.items});
    std.debug.print("arr: {any}\n", .{in.items});
    std.debug.print("arr: {any}\n", .{post.items});

    const bfs1 = try tree.bfs(6);
    const bfs2 = try tree.bfs(2);
    const bfs3 = try tree.bfs(7);

    try expect(bfs1);
    try expect(bfs2);
    try expect(!bfs3);
}

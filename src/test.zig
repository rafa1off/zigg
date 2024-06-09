const dsa = @import("collections.zig");
const expect = @import("std").testing.expect;
const assert = @import("std").testing.expectEqual;
const print = @import("std").debug.print;
const allocator = @import("std").testing.allocator;

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
    const val: u32 = 11;
    const val2 = val + 1;
    var stack = dsa.Stack(@TypeOf(val)).init(allocator);
    defer stack.deinit();

    const node = dsa.Node(@TypeOf(val)).init(val);
    const node2 = dsa.Node(@TypeOf(val)).init(val2);

    try stack.append(node);
    try stack.append(node2);
    if (stack.pop()) |_| {
        try assert(11, stack.peek());
        return;
    }

    try assert(null, stack.peek());
}

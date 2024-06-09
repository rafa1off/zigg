const dsa = @import("collections.zig");
const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

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

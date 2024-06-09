const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const Arena = @import("std").heap.ArenaAllocator;

pub fn bubble_sort(comptime T: type, arr: []T) void {
    for (0..arr.len - 1) |i| {
        for (0..arr.len - 1 - i) |j| {
            if (arr[j] > arr[j + 1]) {
                const tmp = arr[j + 1];
                arr[j + 1] = arr[j];
                arr[j] = tmp;
            }
        }
    }
}

pub fn is_sorted(comptime T: type, arr: []T) bool {
    for (0..arr.len - 1) |i| {
        if (arr[i] > arr[i + 1]) {
            return false;
        }
    }

    return true;
}

pub fn quick_sort(comptime T: type, arr: []T, lo: usize, hi: usize) void {
    if (lo >= hi) {
        return;
    }

    const pvtIdx = partition(T, arr, lo, hi);

    quick_sort(T, arr, lo, pvtIdx - 1);
    quick_sort(T, arr, pvtIdx + 1, hi);
}

fn partition(comptime T: type, arr: []T, lo: usize, hi: usize) usize {
    const pvt = arr[hi];
    var idx: isize = @bitCast(lo);
    idx -= 1;

    for (lo..hi) |i| {
        if (arr[i] < pvt) {
            idx += 1;
            const tmp = arr[i];
            arr[i] = arr[@bitCast(idx)];
            arr[@bitCast(idx)] = tmp;
        }
    }

    idx += 1;
    arr[hi] = arr[@bitCast(idx)];
    arr[@bitCast(idx)] = pvt;

    return @bitCast(idx);
}

pub fn Node(comptime T: type) type {
    return struct {
        val: T,
        next: ?*Self,
        prev: ?*Self,

        const Self = @This();

        pub fn init(val: T) Self {
            return .{
                .val = val,
                .next = null,
                .prev = null,
            };
        }
    };
}

pub fn Stack(comptime T: type) type {
    return struct {
        len: usize,
        top: ?*Node(T),
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            const arena = std.heap.ArenaAllocator.init(allocator);

            return .{
                .len = 0,
                .top = null,
                .arena = arena,
            };
        }

        pub fn append(self: *Self, item: Node(T)) !void {
            const alloc = self.arena.allocator();

            const node = try alloc.create(@TypeOf(item));
            node.* = item;

            self.len += 1;

            if (self.top) |_| {
                node.*.prev = self.top;
                self.top = node;

                return;
            }

            self.top = node;
        }

        pub fn pop(self: *Self) ?Node(T) {
            if (self.top) |_| {
                const alloc = self.arena.allocator();

                const node = self.top.?;

                self.top = node.*.prev;
                self.len -= 1;
                defer alloc.destroy(node);

                return node.*;
            }

            return null;
        }

        pub fn peek(self: Self) ?T {
            if (self.top) |top| {
                return top.*.val;
            }

            return null;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

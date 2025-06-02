const std = @import("std");
const Allocator = std.mem.Allocator;
const Arena = std.heap.ArenaAllocator;
const Vec = std.ArrayList;

pub fn bubbleSort(T: type, arr: []T) void {
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

pub fn sorted(T: type, arr: []T) bool {
    for (0..arr.len - 1) |i| {
        if (arr[i] > arr[i + 1]) {
            return false;
        }
    }

    return true;
}

pub fn quickSort(T: type, arr: []T, lo: usize, hi: usize) void {
    if (lo >= hi) {
        return;
    }
    // lo -= 1;

    const pvt_idx = partition(T, arr, lo, hi);

    quickSort(T, arr, lo, pvt_idx - 1);
    quickSort(T, arr, pvt_idx + 1, hi);
}

fn partition(T: type, arr: []T, lo: usize, hi: usize) usize {
    const pvt = arr[hi];
    var i: isize = @bitCast(lo);
    i -= 1;

    for (lo..hi) |j| {
        if (arr[j] < pvt) {
            i += 1;
            const tmp = arr[j];
            arr[j] = arr[@bitCast(i)];
            arr[@bitCast(i)] = tmp;
        }
    }

    i += 1;
    arr[hi] = arr[@bitCast(i)];
    arr[@bitCast(i)] = pvt;

    return @bitCast(i);
}

pub fn ListNode(comptime T: type) type {
    return struct {
        val: T,
        next: ?*Self = null,
        prev: ?*Self = null,

        const Self = @This();

        pub fn init(val: T) Self {
            return .{
                .val = val,
            };
        }
    };
}

pub fn Stack(comptime T: type) type {
    return struct {
        len: usize = 0,
        top: ?*ListNode(T) = null,
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .arena = std.heap.ArenaAllocator.init(allocator),
            };
        }

        pub fn push(self: *Self, val: T) !void {
            const aa = self.arena.allocator();

            const node = try aa.create(ListNode(T));
            node.* = ListNode(T).init(val);

            self.len += 1;

            if (self.top) |prev| {
                node.*.prev = prev;
                self.top = node;
            } else {
                self.top = node;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.top) |node| {
                const aa = self.arena.allocator();

                self.top = node.*.prev;
                self.len -= 1;
                defer aa.destroy(node);

                return node.val;
            } else return null;
        }

        pub fn peek(self: Self) ?T {
            if (self.top) |top| return top.*.val else return null;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

pub fn Queue(comptime T: type) type {
    return struct {
        len: usize = 0,
        head: ?*ListNode(T) = null,
        tail: ?*ListNode(T) = null,
        arena: Arena,

        const Self = @This();

        pub fn init(alloc: Allocator) Self {
            return .{
                .arena = std.heap.ArenaAllocator.init(alloc),
            };
        }

        pub fn enqueue(self: *Self, val: T) !void {
            const allocator = self.arena.allocator();

            const node = try allocator.create(ListNode(T));
            node.* = ListNode(T).init(val);

            self.len += 1;

            if (self.head == null) {
                self.head = node;
                self.tail = node;

                self.head.?.next = self.tail;
                self.tail.?.prev = self.head;

                return;
            }

            self.tail.?.next = node;
            node.prev = self.tail;
            self.tail = node;
            self.tail.?.next = null;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.head == null or self.tail == null) {
                if (self.len > 0) {
                    self.len -= 1;
                }

                return null;
            }

            self.len -= 1;

            const node = self.head.?;
            defer self.arena.allocator().destroy(node);

            self.head = node.next;

            return node.*.val;
        }

        pub fn first(self: Self) ?T {
            return (self.head orelse return null).val;
        }

        pub fn last(self: Self) ?T {
            return (self.tail orelse return null).val;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

pub fn BinaryTreeNode(comptime T: type) type {
    return struct {
        val: T,
        right: ?*Self = null,
        left: ?*Self = null,

        const Self = @This();

        pub fn init(val: T) Self {
            return .{
                .val = val,
            };
        }

        pub fn insertLeft(self: *Self, node: *Self) void {
            if (self.left) |left| {
                if (node.val <= left.val) {
                    left.insertLeft(node);
                } else {
                    left.insertRight(node);
                }
            } else self.left = node;
        }

        pub fn insertRight(self: *Self, node: *Self) void {
            if (self.right) |right| {
                if (node.val > right.val) {
                    right.insertRight(node);
                } else {
                    right.insertLeft(node);
                }
            } else self.right = node;
        }
    };
}

pub fn BSTree(comptime T: type) type {
    return struct {
        root: ?*BinaryTreeNode(T) = null,
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .arena = std.heap.ArenaAllocator.init(allocator),
            };
        }

        pub fn insert(self: *Self, val: T) !void {
            const alloc = self.arena.allocator();

            const node = try alloc.create(BinaryTreeNode(T));
            node.* = BinaryTreeNode(T).init(val);

            if (self.root) |root| {
                if (val <= root.val) {
                    root.insertLeft(node);
                } else {
                    root.insertRight(node);
                }

                return;
            } else self.root = node;
        }

        pub fn preOrderSearch(self: *Self) !Vec(T) {
            var arr = Vec(T).init(self.arena.allocator());

            try preWalk(T, self.root, &arr);

            return arr;
        }

        pub fn inOrderSearch(self: *Self) !Vec(T) {
            var arr = Vec(T).init(self.arena.allocator());

            try inWalk(T, self.root, &arr);

            return arr;
        }

        pub fn postOrderSearch(self: *Self) !Vec(T) {
            var arr = Vec(T).init(self.arena.allocator());

            try postWalk(T, self.root, &arr);

            return arr;
        }

        pub fn breathFirstSearch(self: *Self, val: T) !bool {
            if (self.root) |root| {
                var queue = Queue(*BinaryTreeNode(T)).init(self.arena.allocator());
                defer queue.deinit();

                try queue.enqueue(root);

                while (queue.len > 0) {
                    const node = queue.dequeue() orelse continue;

                    if (node.val == val) return true;

                    if (node.left) |lnode| try queue.enqueue(lnode);

                    if (node.right) |rnode| try queue.enqueue(rnode);
                }

                return false;
            } else return false;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

fn preWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) return;

    const node = curr.?;

    try path.append(node.val);
    try preWalk(T, node.left, path);
    try preWalk(T, node.right, path);
}

fn inWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) return;

    const node = curr.?;

    try inWalk(T, node.left, path);
    try path.append(node.val);
    try inWalk(T, node.right, path);
}

fn postWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) return;

    const node = curr.?;

    try postWalk(T, node.left, path);
    try postWalk(T, node.right, path);
    try path.append(node.val);
}

pub const String = struct {
    data: []u8 = undefined,
    len: usize = 0,
    cap: usize = 0,
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.data);
    }

    pub fn from(self: Self, str: []const u8) !Self {
        const tmp = try self.allocator.alloc(u8, str.len);
        @memcpy(tmp, str);

        return .{
            .data = tmp,
            .len = str.len,
            .cap = str.len,
            .allocator = self.allocator,
        };
    }

    pub fn withCapacity(self: Self, capacity: usize) !Self {
        return .{
            .data = try self.allocator.alloc(u8, capacity),
            .cap = capacity,
            .allocator = self.allocator,
        };
    }

    pub fn reverse(self: *Self) !void {
        if (self.len == 0) return error.NoData;

        const old = self.data;
        defer self.allocator.free(old);

        var rvrs = try self.allocator.alloc(u8, self.len);

        var j: usize = self.len - 1;
        for (self.data, 0..) |_, i| {
            rvrs[i] = self.data[j];

            if (j != 0) j -= 1;
        }

        self.data = rvrs;
    }

    pub fn set(self: *Self, str: []const u8) !void {
        if (self.cap == str.len) {
            @memcpy(self.data, str);
            return;
        }

        const tmp: []u8 = try self.allocator.realloc(self.data, str.len);
        @memcpy(tmp, str);

        self.len = str.len;
        self.cap = str.len;
        self.data = tmp;
    }
};

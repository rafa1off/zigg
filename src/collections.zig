const std = @import("std");
const Allocator = std.mem.Allocator;
const Arena = std.heap.ArenaAllocator;
const Vec = std.ArrayList;

pub fn bubbleSort(comptime T: type, arr: []T) void {
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

pub fn sorted(comptime T: type, arr: []T) bool {
    for (0..arr.len - 1) |i| {
        if (arr[i] > arr[i + 1]) {
            return false;
        }
    }

    return true;
}

pub fn quickSort(comptime T: type, arr: []T, lo: usize, hi: usize) void {
    if (lo >= hi) {
        return;
    }

    const pvt_idx = partition(T, arr, lo, hi);

    quickSort(T, arr, lo, pvt_idx - 1);
    quickSort(T, arr, pvt_idx + 1, hi);
}

fn partition(comptime T: type, arr: []T, lo: usize, hi: usize) usize {
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
        top: ?*ListNode(T),
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .len = 0,
                .top = null,
                .arena = std.heap.ArenaAllocator.init(allocator),
            };
        }

        pub fn push(self: *Self, val: T) !void {
            const alloc = self.arena.allocator();

            const node = try alloc.create(ListNode(T));
            node.* = ListNode(T).init(val);

            self.len += 1;

            if (self.top) |prev| {
                node.*.prev = prev;
                self.top = node;

                return;
            }

            self.top = node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.top) |node| {
                const alloc = self.arena.allocator();

                self.top = node.*.prev;
                self.len -= 1;
                defer alloc.destroy(node);

                return node.val;
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

pub fn Queue(comptime T: type) type {
    return struct {
        len: usize,
        head: ?*ListNode(T),
        tail: ?*ListNode(T),
        arena: Arena,

        const Self = @This();

        pub fn init(alloc: Allocator) Self {
            return .{
                .len = 0,
                .head = null,
                .tail = null,
                .arena = std.heap.ArenaAllocator.init(alloc),
            };
        }

        pub fn enqueue(self: *Self, val: T) !void {
            const alloc = self.arena.allocator();

            const node = try alloc.create(ListNode(T));
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
            if (self.head) |head| {
                return head.val;
            }

            return null;
        }

        pub fn last(self: Self) ?T {
            if (self.tail) |tail| {
                return tail.val;
            }

            return null;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

pub fn BinaryTreeNode(comptime T: type) type {
    return struct {
        val: T,
        right: ?*Self,
        left: ?*Self,

        const Self = @This();

        pub fn init(val: T) Self {
            return .{
                .val = val,
                .left = null,
                .right = null,
            };
        }

        pub fn insertLeft(self: *Self, node: *Self) void {
            if (self.left) |left| {
                if (node.val <= left.val) {
                    left.insertLeft(node);
                } else {
                    left.insertRight(node);
                }
            } else {
                self.left = node;
            }
        }

        pub fn insertRight(self: *Self, node: *Self) void {
            if (self.right) |right| {
                if (node.val > right.val) {
                    right.insertRight(node);
                } else {
                    right.insertLeft(node);
                }
            } else {
                self.right = node;
            }
        }
    };
}

pub fn BSTree(comptime T: type) type {
    return struct {
        root: ?*BinaryTreeNode(T),
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .root = null,
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
            }

            self.root = node;
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
            var queue = Queue(*BinaryTreeNode(T)).init(self.arena.allocator());
            defer queue.deinit();

            if (self.root) |root| {
                try queue.enqueue(root);
            } else {
                return false;
            }

            while (queue.len > 0) {
                const node = queue.dequeue() orelse continue;

                if (node.val == val) {
                    return true;
                }

                if (node.left) |lnode| {
                    try queue.enqueue(lnode);
                }

                if (node.right) |rnode| {
                    try queue.enqueue(rnode);
                }
            }

            return false;
        }

        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

fn preWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) {
        return;
    }

    try path.append(curr.?.val);

    try preWalk(T, curr.?.left, path);
    try preWalk(T, curr.?.right, path);
}

fn inWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) {
        return;
    }

    try inWalk(T, curr.?.left, path);

    try path.append(curr.?.val);

    try inWalk(T, curr.?.right, path);
}

fn postWalk(comptime T: type, curr: ?*BinaryTreeNode(T), path: *Vec(T)) !void {
    if (curr == null) {
        return;
    }

    try postWalk(T, curr.?.left, path);
    try postWalk(T, curr.?.right, path);

    try path.append(curr.?.val);
}

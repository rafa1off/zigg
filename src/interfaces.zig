const std = @import("std");

const Handler = struct {
    ptr: *anyopaque,
    handleFn: *const fn (ctx: *anyopaque) void,

    const Self = @This();

    pub fn handle(self: *Self) void {
        self.handleFn(self.ptr);
    }
};

pub fn Foo(comptime T: type) type {
    return struct {
        val: T,

        const Self = @This();

        pub fn init(str: T) Self {
            return .{
                .val = str,
            };
        }

        pub fn handler(self: *Self) Handler {
            return .{
                .ptr = self,
                .handleFn = &handle,
            };
        }

        fn handle(ptr: *anyopaque) void {
            const self: *Self = @ptrCast(@alignCast(ptr));

            if (@TypeOf(self.val) == []const u8) {
                std.debug.print("{s}\n", .{self.val});
                return;
            }

            std.debug.print("{any}\n", .{self.val});
        }
    };
}

pub fn Bar(comptime T: type) type {
    return struct {
        val: T,

        const Self = @This();

        pub fn init(str: T) Self {
            return .{
                .val = str,
            };
        }

        pub fn handler(self: *Self) Handler {
            return .{
                .ptr = self,
                .handleFn = &handle,
            };
        }

        fn handle(ptr: *anyopaque) void {
            const self: *Self = @ptrCast(@alignCast(ptr));

            if (@TypeOf(self.val) == []const u8) {
                std.debug.print("{s}\n", .{self.val});
                return;
            }

            std.debug.print("{any}\n", .{self.val});
        }
    };
}

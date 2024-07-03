const std = @import("std");

pub fn Handler(comptime Context: type) type {
    return struct {
        context: Context,
        handleFn: *const fn (context: type) void,

        const Self = @This();

        pub fn handle(self: Self) void {
            self.handleFn(self.context);
        }
    };
}

pub fn Foo(comptime T: type) type {
    return struct {
        val: T,

        const Self = @This();

        pub fn init(str: T) Self {
            return .{
                .val = str,
            };
        }

        pub fn handler(self: Self) Handler(T) {
            return .{ .context = self.val, .handleFn = &handle };
        }

        fn handle(self: Self) void {
            std.debug.print("{any}\n", .{self.val});
        }
    };
}

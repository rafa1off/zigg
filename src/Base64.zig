const std = @import("std");
const Allocator = std.mem.Allocator;
const Self = @This();

table: *const [64]u8,

pub fn init() Self {
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const lower = "abcdefghijklmnopqrstuvwxyz";
    const numbers_symb = "0123456789+/";

    return .{
        .table = upper ++ lower ++ numbers_symb,
    };
}

pub fn charAt(self: Self, index: usize) u8 {
    return self.table[index];
}

fn charIndex(self: Self, char: u8) u8 {
    if (char == '=') {
        return 64;
    }

    var idx: u8 = 0;
    for (0..63) |i| {
        if (self.charAt(i) == char) {
            idx = @intCast(i);
            break;
        }
    }

    return idx;
}

pub fn encode(self: Self, allocator: Allocator, input: []const u8) ![]u8 {
    if (input.len == 0) {
        return "";
    }

    const n_out = try calcEncodeLength(input);
    var out = try allocator.alloc(u8, n_out);
    var buf = [_]u8{ 0, 0, 0 };
    var count: usize = 0;
    var iout: usize = 0;

    for (input) |char| {
        buf[count] = char;
        count += 1;

        if (count == 3) {
            out[iout] = self.charAt(buf[0] >> 2);
            out[iout + 1] = self.charAt(((buf[0] & 0b00000011) << 4) + (buf[1] >> 4));
            out[iout + 2] = self.charAt(((buf[1] & 0b00001111) << 2) + (buf[2] >> 6));
            out[iout + 3] = self.charAt(buf[2] & 0b00111111);

            iout += 4;
            count = 0;
        }
    }

    if (count == 1) {
        out[iout] = self.charAt(buf[0] >> 2);
        out[iout + 1] = self.charAt((buf[0] & 0b00000011) << 4);
        out[iout + 2] = '=';
        out[iout + 3] = '=';
    }

    if (count == 2) {
        out[iout] = self.charAt(buf[0] >> 2);
        out[iout + 1] = self.charAt(((buf[0] & 0b00000011) << 4) + (buf[1] >> 4));
        out[iout + 2] = self.charAt((buf[1] & 0b00001111) << 2);
        out[iout + 3] = '=';
    }

    return out;
}

pub fn decode(self: Self, allocator: Allocator, input: []const u8) ![]u8 {
    if (input.len == 0) {
        return "";
    }

    const n_out = try calcDecodeLength(input);
    var out = try allocator.alloc(u8, n_out);
    var buf = [_]u8{ 0, 0, 0, 0 };
    var count: usize = 0;
    var iout: usize = 0;

    for (0..input.len) |i| {
        buf[count] = self.charIndex(input[i]);
        count += 1;

        if (count == 4) {
            out[iout] = (buf[0] << 2) + (buf[1] >> 4);

            if (buf[2] != 64) {
                out[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
            }

            if (buf[3] != 64) {
                out[iout + 2] = (buf[2] << 6) + buf[3];
            }

            iout += 3;
            count = 0;
        }
    }

    return out;
}

fn calcEncodeLength(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }

    const out = try std.math.divCeil(usize, input.len, 3);

    return out * 4;
}

fn calcDecodeLength(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    var out = try std.math.divFloor(usize, input.len, 4);

    out *= 3;

    const penult: usize = input.len - 2;
    for (input[penult..]) |i| {
        if (i == '=') {
            out -= 1;
        }
    }

    return out;
}

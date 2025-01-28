const std = @import("std");
const Allocator = std.mem.Allocator;
const Self = @This();

table: *const [64]u8,
allocator: Allocator,

pub fn init(allocator: Allocator) Self {
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const lower = "abcdefghijklmnopqrstuvwxyz";
    const numbers_symb = "0123456789+/";

    return .{
        .table = upper ++ lower ++ numbers_symb,
        .allocator = allocator,
    };
}

pub fn char_at(self: Self, index: usize) u8 {
    return self.table[index];
}

fn char_index(self: Self, char: u8) u8 {
    if (char == '=') {
        return 64;
    }

    var idx: u8 = 0;
    for (0..63) |i| {
        if (self.char_at(i) == char) {
            idx = @intCast(i);
            break;
        }
    }

    return idx;
}

pub fn encode(self: Self, input: []const u8) ![]u8 {
    if (input.len == 0) {
        return "";
    }

    const n_out = try calc_encode_length(input);
    var out = try self.allocator.alloc(u8, n_out);
    var buf = [3]u8{ 0, 0, 0 };
    var count: usize = 0;
    var iout: usize = 0;

    for (input, 0..) |_, i| {
        buf[count] = input[i];
        count += 1;

        if (count == 3) {
            out[iout] = self.char_at(buf[0] >> 2);
            out[iout + 1] = self.char_at(((buf[0] & 0b00000011) << 4) + (buf[1] >> 4));
            out[iout + 2] = self.char_at(((buf[1] & 0b00001111) << 2) + (buf[2] >> 6));
            out[iout + 3] = self.char_at(buf[2] & 0b00111111);

            iout += 4;
            count = 0;
        }
    }

    if (count == 1) {
        out[iout] = self.char_at(buf[0] >> 2);
        out[iout + 1] = self.char_at((buf[0] & 0b00000011) << 4);
        out[iout + 2] = '=';
        out[iout + 3] = '=';
    }

    if (count == 2) {
        out[iout] = self.char_at(buf[0] >> 2);
        out[iout + 1] = self.char_at(((buf[0] & 0b00000011) << 4) + (buf[1] >> 4));
        out[iout + 2] = self.char_at((buf[1] & 0b00001111) << 2);
        out[iout + 3] = '=';
    }

    return out;
}

pub fn decode(self: Self, input: []const u8) ![]u8 {
    if (input.len == 0) {
        return "";
    }

    const n_out = try calc_decode_length(input);
    var out = try self.allocator.alloc(u8, n_out);
    var buf = [4]u8{ 0, 0, 0, 0 };
    var count: usize = 0;
    var iout: usize = 0;

    for (0..input.len) |i| {
        buf[count] = self.char_index(input[i]);
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

fn calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }

    const out = try std.math.divCeil(usize, input.len, 3);

    return out * 4;
}

fn calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    var out = try std.math.divFloor(usize, input.len, 4);

    out *= 3;

    const second_last: usize = input.len - 2;
    for (input[second_last..]) |i| {
        if (i == '=') {
            out -= 1;
        }
    }

    return out;
}

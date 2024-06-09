const std = @import("std");
const Allocator = @import("std").mem.Allocator;

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

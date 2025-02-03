const std = @import("std");
const print = std.debug.print;

pub fn update(delta: u64) void {
    print("{d:3>}\n", .{delta});
}

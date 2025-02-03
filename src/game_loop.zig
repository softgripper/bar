const std = @import("std");
const print = std.debug.print;

pub fn update(delta: f64) void {
    print("{d:3>}\n", .{delta});
}

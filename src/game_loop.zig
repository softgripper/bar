const std = @import("std");
const print = std.debug.print;

const tick_rate = 1 * std.time.ns_per_s;
var period: u64 = tick_rate;

pub fn update(delta: u64) void {
    period += delta;
    if (period >= std.time.ns_per_s) {
        tick();
        period = 0;
    }
}

pub fn tick() void {
    print("tick\n", .{});
}

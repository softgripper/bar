const std = @import("std");
const print = std.debug.print;

pub fn update(delta: u64) void {
    print("{d:3>}\n", .{delta});
}

pub fn atomicTest() void {
    std.Thread.sleep(0.1 * std.time.ns_per_ms);
}

const b = @import("benchmark.zig");
const testing = std.testing;
test "game_loop test" {
    const allocator = testing.allocator;

    const result = try b.bench(
        .{
            .allocator = allocator,
            .iterations = 20000,
        },
        atomicTest,
        .{},
    );

    const json = try std.json.stringifyAlloc(
        allocator,
        result,
        .{ .whitespace = .indent_2 },
    );
    defer allocator.free(json);

    print("{s}\n", .{json});
}

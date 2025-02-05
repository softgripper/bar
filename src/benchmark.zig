const std = @import("std");
const time = std.time;

const nameOf = struct {
    fn Dummy(func: anytype) type {
        return struct {
            fn warpper() void {
                func();
            }
        };
    }

    pub fn Fn(func: anytype) []const u8 {
        const name = @typeName(Dummy(func));
        const start = (std.mem.indexOfScalar(u8, name, '\'') orelse unreachable) + 1;
        const end = std.mem.indexOfScalarPos(u8, name, start, '\'') orelse unreachable;
        return name[start..end];
    }
};

const print = std.debug.print;

pub fn bench(args: struct {
    allocator: std.mem.Allocator,
    iterations: u64 = 1,
    warmup_iterations: u64 = 0,
}, func: anytype, func_args: anytype) !void {
    print("bench:\n func {s}\n", .{nameOf.Fn(func)});

    // warmup
    var i: u64 = 0;
    if (args.warmup_iterations > 0) {
        print(" warmup iterations {d}\n", .{args.warmup_iterations});
        while (i < args.warmup_iterations) : (i += 1) {
            @call(.auto, func, func_args);
        }
    }

    var durations = try std.ArrayList(u64).initCapacity(args.allocator, args.iterations);
    defer durations.deinit();

    // bench
    print(" iterations {d}\n", .{args.iterations});
    i = 0;
    var timer = try time.Timer.start();
    while (i < args.iterations) : (i += 1) {
        timer.reset();
        @call(.auto, func, func_args);
        try durations.append(timer.read());
    }

    // stats
    var sum: u64 = 0;
    var min: u64 = std.math.maxInt(u64);
    var max: u64 = std.math.minInt(u64);

    for (durations.items) |dur| {
        sum += dur;
        min = @min(min, dur);
        max = @max(max, dur);
    }

    const avg = @as(f64, @floatFromInt(sum)) / @as(f64, @floatFromInt(args.iterations));

    // standard deviation
    var sq_sum: u64 = 0;
    for (durations.items) |dur| {
        const diff = @as(f64, @floatFromInt(dur));
        sq_sum += @as(u64, @intFromFloat(diff * diff));
    }

    const std_dev = @sqrt(@as(f64, @floatFromInt(sq_sum)) / @as(f64, @floatFromInt(args.iterations)));

    const result = .{
        .avg_ns = avg,
        .min_ns = min,
        .max_ns = max,
        .std_dev = std_dev,
    };
    print(
        \\----------------
        \\average:  {d: >6.2} ms
        \\min:      {d: >6.2} ms
        \\max:      {d: >6.2} ms
        \\std dev: ±{d: >6.2} ms
        \\
    , .{
        result.avg_ns / time.ns_per_ms,
        result.min_ns / time.ns_per_ms,
        result.max_ns / time.ns_per_ms,
        result.std_dev / time.ns_per_ms,
    });
}

pub fn benchTest() void {
    std.Thread.sleep(2 * time.ns_per_ms);
}

const testing = std.testing;
test "game_loop test" {
    const allocator = testing.allocator;

    try bench(
        .{
            .allocator = allocator,
            .warmup_iterations = 200,
            .iterations = 2000,
        },
        benchTest,
        .{},
    );
}

const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const ecs = @import("ecs");

const Allocator = std.mem.Allocator;
const print = std.debug.print;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

var quit = false;
var registry: ecs.Registry = undefined;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    registry = ecs.Registry.init(allocator);
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        print("Unable to initialize SDL: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    var window: ?*c.SDL_Window = null;
    var renderer: ?*c.SDL_Renderer = null;

    // https://github.com/ziglang/zig/issues/22494
    // const SDL_WINDOW_VULKAN: u64 = 0x0000000010000000;
    const SDL_WINDOW_RESIZABLE: u64 = 0x0000000000000020;

    if (!c.SDL_CreateWindowAndRenderer(
        "My Game window",
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        SDL_WINDOW_RESIZABLE,
        &window,
        &renderer,
    )) {
        print("Unable to create window and renderer: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }

    defer {
        if (window) |w| c.SDL_DestroyWindow(w);
        if (renderer) |r| c.SDL_DestroyRenderer(r);
    }

    _ = c.SDL_SetRenderVSync(renderer, c.SDL_RENDERER_VSYNC_ADAPTIVE);

    print("{any}\n", .{c.SDL_GetNumLogicalCPUCores()});

    const render_thread = try std.Thread.spawn(.{}, render, .{renderer});
    defer render_thread.join();

    const game_thread = try std.Thread.spawn(.{}, game, .{});
    defer game_thread.join();

    try event_loop();
}

const default_rect = c.SDL_FRect{
    .x = 0,
    .y = 0,
    .h = 100,
    .w = 100,
};

var rect = default_rect;

const time = std.time;

fn game() !void {
    print("game system\n", .{});

    const target_tickrate = 60;
    const target_ns = time.ns_per_s / target_tickrate;

    var timer = try std.time.Timer.start();

    while (!quit) {
        const start_ns = std.time.nanoTimestamp();

        const anim: f32 = @as(f32, @floatFromInt(timer.read() / time.ns_per_ms)) / time.ms_per_s;
        rect.w = default_rect.w * @sin(anim);
        rect.h = default_rect.h * @cos(anim);

        rect.x = (SCREEN_WIDTH - rect.w) / 2;
        rect.y = (SCREEN_HEIGHT - rect.h) / 2;

        const duration = std.time.nanoTimestamp() - start_ns;
        const sleep_duration = @as(u64, @intCast(target_ns - duration));
        std.Thread.sleep(sleep_duration);
    }
}

fn event_loop() !void {
    var event: c.SDL_Event = undefined;
    while (!quit) {
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => quit = true,
                c.SDL_EVENT_KEY_DOWN => {
                    const name = std.mem.span(c.SDL_GetKeyName(event.key.key));
                    if (std.mem.eql(u8, name, "Escape")) {
                        quit = true;
                    }
                },
                else => {},
            }
        }
        c.SDL_Delay(0);
    }
}

fn render(renderer: ?*c.SDL_Renderer) !void {
    print("render system\n", .{});

    const target_tickrate = 60;
    const target_ms = time.ms_per_s / target_tickrate;

    while (!quit) {
        _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 69, 42, 0, 0);
        _ = c.SDL_RenderFillRect(renderer, &rect);

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(target_ms);
    }
}

const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

const print = std.debug.print;

var quit = false;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    const render_thread = try std.Thread.spawn(.{}, render_loop, .{});
    defer render_thread.join();

    try game_loop();
}

const default_rect = c.SDL_FRect{
    .x = 0,
    .y = 0,
    .h = 100,
    .w = 100,
};

var rect = default_rect;

const time = std.time;

fn game_loop() !void {
    const target_fps = 60;
    const target_frame_time_ns = time.ns_per_s / target_fps;

    var timer = try std.time.Timer.start();

    while (!quit) {
        const start_ns = std.time.nanoTimestamp();

        const anim: f32 = @as(f32, @floatFromInt(timer.read() / time.ns_per_ms)) / time.ms_per_s;
        rect.w = default_rect.w * @sin(anim);
        rect.h = default_rect.h * @cos(anim);

        rect.x = (SCREEN_WIDTH - rect.w) / 2;
        rect.y = (SCREEN_HEIGHT - rect.h) / 2;

        const duration = std.time.nanoTimestamp() - start_ns;
        const sleep_duration = @as(u64, @intCast(target_frame_time_ns - duration));
        std.Thread.sleep(sleep_duration);
    }
}

fn render_loop() !void {
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

    while (!quit) {
        var event: c.SDL_Event = undefined;
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

        render(renderer);

        c.SDL_Delay(17);
    }
}

inline fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
    _ = c.SDL_RenderClear(renderer);

    _ = c.SDL_SetRenderDrawColor(renderer, 69, 42, 0, 0);
    _ = c.SDL_RenderFillRect(renderer, &rect);

    _ = c.SDL_RenderPresent(renderer);
}

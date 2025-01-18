const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const WIDTH = 640;
const HEIGHT = 480;

const print = std.debug.print;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    var window: ?*c.SDL_Window = null;
    var renderer: ?*c.SDL_Renderer = null;

    // https://github.com/ziglang/zig/issues/22494
    const SDL_WINDOW_VULKAN: u64 = 0x0000000010000000;

    if (!c.SDL_CreateWindowAndRenderer("My Game window", WIDTH, HEIGHT, SDL_WINDOW_VULKAN, &window, &renderer)) {
        c.SDL_Log("Unable to create window and renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    defer {
        if (window) |w| c.SDL_DestroyWindow(w);
        if (renderer) |r| c.SDL_DestroyRenderer(r);
    }

    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => quit = true,
                else => {},
            }
        }

        render(renderer);

        c.SDL_Delay(17);
    }
}

const default_rect = c.SDL_FRect{
    .x = 0,
    .y = 0,
    .h = 100,
    .w = 100,
};

var rect = default_rect;

fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
    _ = c.SDL_RenderClear(renderer);

    rect.w = default_rect.w * @sin(@as(f32, @floatFromInt(c.SDL_GetTicks())) / 500.0);
    rect.h = default_rect.h * @cos(@as(f32, @floatFromInt(c.SDL_GetTicks())) / 600.0);
    rect.x = (WIDTH - rect.w) / 2;
    rect.y = (HEIGHT - rect.h) / 2;

    _ = c.SDL_SetRenderDrawColor(renderer, 69, 42, 0, 0);
    _ = c.SDL_RenderFillRect(renderer, &rect);
    _ = c.SDL_RenderPresent(renderer);
}

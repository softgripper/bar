const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    var window: ?*c.SDL_Window = undefined;
    var renderer: ?*c.SDL_Renderer = undefined;

    // https://github.com/ziglang/zig/issues/22494
    // c.SDL_WINDOW_VULKAN
    const SDL_WINDOW_VULKAN = 0x0000000010000000;

    if (!c.SDL_CreateWindowAndRenderer("My Game window", 640, 480, SDL_WINDOW_VULKAN, &window, &renderer)) {
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

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
        _ = c.SDL_RenderPresent(renderer);
        _ = c.SDL_SetRenderVSync(renderer, c.SDL_RENDERER_VSYNC_ADAPTIVE);

        c.SDL_Delay(1);
    }
}

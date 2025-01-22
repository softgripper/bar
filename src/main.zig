const std = @import("std");
const c = @import("c.zig").c;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

const print = std.debug.print;

pub fn main() !void {
    var quit = false;

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.sdl_init;
    }
    defer c.SDL_Quit();

    if (!c.SDL_Vulkan_LoadLibrary(null)) {
        c.SDL_Log("Unable to load vulkan: %s", c.SDL_GetError());
        return error.sdl_vulkan_load_library;
    }
    defer c.SDL_Vulkan_UnloadLibrary();
    var window: ?*c.SDL_Window = null;
    var renderer: ?*c.SDL_Renderer = null;

    const app_name = "good luck threading";
    const SDL_WINDOW_RESIZABLE = 0x0000000000000020;
    const SDL_WINDOW_VULKAN = 0x0000000010000000;
    const SDL_WINDOW_HIDDEN = 0x0000000000000008;

    if (!c.SDL_CreateWindowAndRenderer(
        app_name,
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_VULKAN | SDL_WINDOW_HIDDEN,
        &window,
        &renderer,
    )) {
        c.SDL_Log("Unable to create window and renderer: %s", c.SDL_GetError());
        return error.sdl_window_and_renderer;
    }

    defer {
        if (window) |w| c.SDL_DestroyWindow(w);
        if (renderer) |r| c.SDL_DestroyRenderer(r);
    }

    if (!c.SDL_ShowWindow(window)) {
        c.SDL_Log("Unable to create window and renderer: %s", c.SDL_GetError());
        return error.sdl_show_window;
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

        _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 69, 42, 0, 0);
        _ = c.SDL_RenderFillRect(renderer, &c.SDL_FRect{
            .x = 0,
            .y = 0,
            .h = 100,
            .w = 100,
        });

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}

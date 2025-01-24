const std = @import("std");
const c = @import("c.zig").c;
const vk = @import("vulkan");
const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

const print = std.debug.print;

const Allocator = std.mem.Allocator;

/// To construct base, instance and device wrappers for vulkan-zig, you need to pass a list of 'apis' to it.
const apis: []const vk.ApiInfo = &.{
    // You can either add invidiual functions by manually creating an 'api'
    // Or you can add entire feature sets or extensions
    vk.features.version_1_0,
    vk.extensions.khr_surface,
    vk.extensions.khr_swapchain,
    vk.extensions.ext_debug_utils,
};

/// Next, pass the `apis` to the wrappers to create dispatch tables.
const BaseDispatch = vk.BaseWrapper(apis);
const InstanceDispatch = vk.InstanceWrapper(apis);
const DeviceDispatch = vk.DeviceWrapper(apis);

// Also create some proxying wrappers, which also have the respective handles
const Instance = vk.InstanceProxy(apis);
const Device = vk.DeviceProxy(apis);

const builtin = @import("builtin");

pub fn main() !void {
    var quit = false;

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.sdl_init;
    }
    defer c.SDL_Quit();

    const app_name = "waddafug";
    const SDL_WINDOW_RESIZABLE = 0x0000000000000020;
    const SDL_WINDOW_VULKAN = 0x0000000010000000;
    const SDL_WINDOW_HIDDEN = 0x0000000000000008;

    const window = c.SDL_CreateWindow(
        app_name,
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        SDL_WINDOW_HIDDEN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_VULKAN,
    ) orelse {
        c.SDL_Log("Unable to create window", c.SDL_GetError());
        return error.sdl_window;
    };
    defer c.SDL_DestroyWindow(window);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const gc = try GraphicsContext.init(allocator, app_name, window);
    defer gc.deinit();

    if (!c.SDL_ShowWindow(window)) {
        c.SDL_Log("Unable to show: %s", c.SDL_GetError());
        return error.sdl_show_window;
    }

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

        // _ = c.SDL_SetRenderDrawColor(renderer, 42, 69, 0, 0);
        // _ = c.SDL_RenderClear(renderer);

        // _ = c.SDL_SetRenderDrawColor(renderer, 69, 42, 0, 0);
        // _ = c.SDL_RenderFillRect(renderer, &c.SDL_FRect{
        //     .x = 0,
        //     .y = 0,
        //     .h = 100,
        //     .w = 100,
        // });

        // _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}

const std = @import("std");
const c = @import("c.zig").c;
const vk = @import("vulkan");

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

    const window = c.SDL_CreateWindow(app_name, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_HIDDEN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_VULKAN) orelse {
        c.SDL_Log("Unable to create window", c.SDL_GetError());
        return error.sdl_window;
    };
    defer c.SDL_DestroyWindow(window);

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const vk_proc: *const fn (instance: vk.Instance, procname: [*:0]const u8) vk.PfnVoidFunction = @ptrCast(c.SDL_Vulkan_GetVkGetInstanceProcAddr());

    var vkb = try BaseDispatch.load(vk_proc);

    var app_info = vk.ApplicationInfo{
        .p_application_name = app_name,
        .application_version = vk.makeApiVersion(0, 0, 0, 0),
        .p_engine_name = app_name,
        .engine_version = vk.makeApiVersion(0, 0, 0, 0),
        .api_version = vk.API_VERSION_1_0,
    };

    var extension_count: u32 = 0;
    const extension_names = c.SDL_Vulkan_GetInstanceExtensions(&extension_count);
    const extension_slice = extension_names[0..extension_count];

    print("Extensions {d}\n", .{extension_count});
    for (extension_slice) |name| {
        print("{s}\n", .{name});
    }

    var instance_create_info = vk.InstanceCreateInfo{
        .p_application_info = &app_info,
        .enabled_extension_count = extension_count,
        .pp_enabled_extension_names = @ptrCast(extension_names),
    };

    const ac: ?*const vk.AllocationCallbacks = null;
    const instance = try vkb.createInstance(&instance_create_info, ac);

    const vki = try allocator.create(InstanceDispatch);
    errdefer allocator.destroy(vki);

    _ = instance;

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

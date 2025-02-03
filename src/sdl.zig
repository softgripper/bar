const std = @import("std");
const c = @import("c.zig").c;
const vk = @import("vulkan");

extern fn SDL_Vulkan_CreateSurface(window: ?*c.SDL_Window, instance: vk.Instance, allocator: ?*const vk.AllocationCallbacks, surface: *const vk.SurfaceKHR) bool;

pub fn vk_proc_address() vk.PfnGetInstanceProcAddr {
    return @ptrCast(c.SDL_Vulkan_GetVkGetInstanceProcAddr());
}
pub const vk_get_instance_extensions = c.SDL_Vulkan_GetInstanceExtensions;

pub const Event = c.SDL_Event;
pub const pollEvent = c.SDL_PollEvent;
pub const EVENT_QUIT = c.SDL_EVENT_QUIT;
pub const EVENT_KEY_DOWN = c.SDL_EVENT_KEY_DOWN;
pub const getKeyName = c.SDL_GetKeyName;
pub const delay = c.SDL_Delay;

const SdlError = error{ Init, CreateWindow, ShowWindow, VkCreateSurface };

pub const InitFlag = enum(c_uint) {
    audio = c.SDL_INIT_AUDIO,
    video = c.SDL_INIT_VIDEO,
    joystick = c.SDL_INIT_JOYSTICK,
    haptic = c.SDL_INIT_HAPTIC,
    gamepad = c.SDL_INIT_GAMEPAD,
    events = c.SDL_INIT_EVENTS,
    sensor = c.SDL_INIT_SENSOR,
    camera = c.SDL_INIT_CAMERA,
};

pub fn init(comptime flags: []const InitFlag) SdlError!void {
    var init_flags: c.SDL_InitFlags = 0;
    for (flags) |flag| {
        init_flags |= @intFromEnum(flag);
    }
    if (!c.SDL_Init(init_flags)) {
        log("Unable to initialize SDL");
        return SdlError.Init;
    }
}

pub fn deinit() void {
    c.SDL_Quit();
}

pub const WindowFlag = enum(u64) {
    fullscreen = c.SDL_WINDOW_FULLSCREEN,
    opengl = c.SDL_WINDOW_OPENGL,
    occluded = c.SDL_WINDOW_OCCLUDED,
    hidden = c.SDL_WINDOW_HIDDEN,
    borderless = c.SDL_WINDOW_BORDERLESS,
    resizeable = c.SDL_WINDOW_RESIZABLE,
    minimized = c.SDL_WINDOW_MINIMIZED,
    maximized = c.SDL_WINDOW_MAXIMIZED,
    mouse_grabbed = c.SDL_WINDOW_MOUSE_GRABBED,
    input_focus = c.SDL_WINDOW_INPUT_FOCUS,
    mouse_focus = c.SDL_WINDOW_MOUSE_FOCUS,
    external = c.SDL_WINDOW_EXTERNAL,
    modal = c.SDL_WINDOW_MODAL,
    high_pixel_density = c.SDL_WINDOW_HIGH_PIXEL_DENSITY,
    mouse_capture = c.SDL_WINDOW_MOUSE_CAPTURE,
    mouse_relative_mode = c.SDL_WINDOW_MOUSE_RELATIVE_MODE,
    always_on_top = c.SDL_WINDOW_ALWAYS_ON_TOP,
    utility = c.SDL_WINDOW_UTILITY,
    tooltip = c.SDL_WINDOW_TOOLTIP,
    popup_menu = c.SDL_WINDOW_POPUP_MENU,
    keyboard_grabbed = c.SDL_WINDOW_KEYBOARD_GRABBED,
    vulkan = c.SDL_WINDOW_VULKAN,
    metal = c.SDL_WINDOW_METAL,
    transparent = c.SDL_WINDOW_TRANSPARENT,
    not_focusable = c.SDL_WINDOW_NOT_FOCUSABLE,
};

const CreateWindowArgs = struct {
    title: [*]const u8,
    width: c_int = 800,
    height: c_int = 600,
    flags: []const WindowFlag,
};

pub fn createWindow(args: *const CreateWindowArgs) SdlError!Window {
    var window_flags: c.SDL_WindowFlags = 0;
    for (args.flags) |flag| {
        window_flags |= @intFromEnum(flag);
    }

    const window: *c.SDL_Window = c.SDL_CreateWindow(
        args.title,
        args.width,
        args.height,
        window_flags,
    ) orelse {
        log("Unable to create window");
        return SdlError.CreateWindow;
    };

    return .{
        .handle = window,
    };
}

pub const Window = struct {
    handle: *c.SDL_Window,
    pub fn destroy(self: *const Window) void {
        c.SDL_DestroyWindow(self.handle);
    }

    pub fn show(self: *const Window) SdlError!void {
        if (!c.SDL_ShowWindow(self.handle)) {
            log("Unable to show window");
            return SdlError.ShowWindow;
        }
    }

    pub fn hasFlag(self: *const Window, flag: WindowFlag) bool {
        return (c.SDL_GetWindowFlags(self.handle) & @intFromEnum(flag) != 0);
    }

    pub fn size(self: *const Window) struct {
        w: c_int,
        h: c_int,
    } {
        var w: c_int = 0;
        var h: c_int = 0;
        _ = c.SDL_GetWindowSize(self.handle, &w, &h);
        return .{
            .w = w,
            .h = h,
        };
    }

    pub fn createVkSurface(self: *const Window, instance: vk.Instance) SdlError!vk.SurfaceKHR {
        var surface: vk.SurfaceKHR = undefined;
        if (!SDL_Vulkan_CreateSurface(self.handle, instance, null, &surface)) {
            log("Unable to create surface");
            return SdlError.VkCreateSurface;
        }

        // sleep for a nanosecond which seems to "fix" the surface creation in an optimized release (wtf)
        std.Thread.sleep(1);

        return surface;
    }
};

pub fn log(comptime msg: []const u8) void {
    c.SDL_Log(msg ++ ": %s", c.SDL_GetError());
}

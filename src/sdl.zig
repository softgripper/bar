const c = @import("c.zig").c;

const vk = @import("vulkan");

pub const Window = c.SDL_Window;

extern fn SDL_Vulkan_CreateSurface(window: ?*Window, instance: vk.Instance, allocator: ?*const vk.AllocationCallbacks, surface: *const vk.SurfaceKHR) bool;

pub const vk_create_surface = SDL_Vulkan_CreateSurface;
pub fn vk_proc_address() vk.PfnGetInstanceProcAddr {
    return @ptrCast(c.SDL_Vulkan_GetVkGetInstanceProcAddr());
}
pub const vk_get_instance_extensions = c.SDL_Vulkan_GetInstanceExtensions;

pub const log = c.SDL_Log;
pub const getError = c.SDL_GetError;
pub const init = c.SDL_Init;
pub const INIT_VIDEO = c.SDL_INIT_VIDEO;
pub const quit = c.SDL_Quit;
pub const createWindow = c.SDL_CreateWindow;
pub const WINDOW_HIDDEN = c.SDL_WINDOW_HIDDEN;
pub const WINDOW_RESIZABLE = c.SDL_WINDOW_RESIZABLE;
pub const WINDOW_VULKAN = c.SDL_WINDOW_VULKAN;
pub const WINDOW_MINIMIZED = c.SDL_WINDOW_MINIMIZED;
pub const destroyWindow = c.SDL_DestroyWindow;
pub const showWindow = c.SDL_ShowWindow;
pub const Event = c.SDL_Event;
pub const pollEvent = c.SDL_PollEvent;
pub const EVENT_QUIT = c.SDL_EVENT_QUIT;
pub const EVENT_KEY_DOWN = c.SDL_EVENT_KEY_DOWN;
pub const getKeyName = c.SDL_GetKeyName;
pub const getWindowFlags = c.SDL_GetWindowFlags;
pub const getWindowSize = c.SDL_GetWindowSize;
pub const delay = c.SDL_Delay;

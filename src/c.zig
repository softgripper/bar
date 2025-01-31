pub const c = @cImport({
    @cDefine("SDL_DISABLE_OLD_NAMES", {});
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @import("vulkan");

pub const SDL_Window = c.SDL_Window;
pub const SDL_Vulkan_GetInstanceExtensions = c.SDL_Vulkan_GetInstanceExtensions;
pub const SDL_Vulkan_GetVkGetInstanceProcAddr = c.SDL_Vulkan_GetVkGetInstanceProcAddr;
pub extern fn SDL_Vulkan_CreateSurface(window: ?*SDL_Window, instance: vk.Instance, allocator: ?*const vk.AllocationCallbacks, surface: *const vk.SurfaceKHR) bool;
pub const SDL_Log = c.SDL_Log;
pub const SDL_GetError = c.SDL_GetError;

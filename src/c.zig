pub const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @import("vulkan");

pub const SDL_Window = c.SDL_Window;
pub const SDL_Vulkan_GetInstanceExtensions = c.SDL_Vulkan_GetInstanceExtensions;
pub const SDL_Vulkan_GetVkGetInstanceProcAddr = c.SDL_Vulkan_GetVkGetInstanceProcAddr;
pub const SDL_Vulkan_CreateSurface: *const fn (
    window: ?*c.SDL_Window,
    instance: vk.Instance,
    allocator: ?*const vk.AllocationCallbacks,
    surface: *const vk.SurfaceKHR,
) bool = @ptrCast(&c.SDL_Vulkan_CreateSurface);
pub const SDL_Log = c.SDL_Log;
pub const SDL_GetError = c.SDL_GetError;

// pub extern fn glfwGetInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) vk.PfnVoidFunction;
// pub extern fn glfwGetPhysicalDevicePresentationSupport(instance: vk.Instance, pdev: vk.PhysicalDevice, queuefamily: u32) c_int;
// pub extern fn glfwCreateWindowSurface(instance: vk.Instance, window: *GLFWwindow, allocation_callbacks: ?*const vk.AllocationCallbacks, surface: *vk.SurfaceKHR) vk.Result;

// pub extern fn SDL_Vulkan_GetPresentationSupport(
//     instance: vk.Instance,
//     pdev: vk.PhysicalDevice,
//     queuefamily: u32,
// ) c_int;

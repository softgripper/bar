const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const print = std.debug.print;

const Dorf = struct {
    name: []const u8,
    pub fn greet(self: *const Dorf, other: Dorf) void {
        print("{s} greets {s}\n", .{ self.name, other.name });
    }
};

pub fn main() !void {
    // const p = Point{ .x = 0.1, .y = 0.2 };
    const ned = Dorf{ .name = "Ned" };
    const chief = Dorf{ .name = "Chief" };

    ned.greet(chief);
    chief.greet(ned);
    print("{d}", .{@sizeOf(Dorf)});

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 400, 140, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(10);
    }
}

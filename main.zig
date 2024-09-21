const std = @import("std");
const Processor = @import("processor.zig").Processor;
const Memory = @import("memory.zig").Memory;
const Clock = @import("clock.zig").Clock;

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("SDL2/SDL.h");
});

const SDL_errors = error{
    InitFailed,
    CreateWindowAndRendererFailed,
};

const DEBUG_CLOCK_SPEED = 600;

pub fn main() !void {
    std.debug.print("Hello World\n", .{});
    var processor: Processor = Processor{};
    processor.Init();
    var memory: Memory = Memory{};
    memory.Init();
    var clock: Clock = Clock{};
    try clock.Init(DEBUG_CLOCK_SPEED);

    var sdlReturn: c_int = c.SDL_Init(c.SDL_INIT_VIDEO);
    if (sdlReturn < 0) {
        return SDL_errors.InitFailed;
    }
    defer c.SDL_Quit();

    var window: ?*c.SDL_Window = undefined;
    var renderer: ?*c.SDL_Renderer = undefined;
    sdlReturn = c.SDL_CreateWindowAndRenderer(640, 320, c.SDL_WINDOW_SHOWN, &window, &renderer);
    if (sdlReturn < 0) {
        return SDL_errors.CreateWindowAndRendererFailed;
    }
    defer c.SDL_DestroyWindow(window);
    defer c.SDL_DestroyRenderer(renderer);
    c.SDL_SetWindowPosition(window, 0, 0);

    _ = c.SDL_RenderSetLogicalSize(renderer, 64, 32);
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = c.SDL_RenderClear(renderer);
    c.SDL_RenderPresent(renderer);

    var i: u32 = 0;
    //var totalTime: u64 = 0;
    var pointX: u6 = 63;
    var pointY: u5 = 31;
    //const renderFrameTime = 1_666_666;
    var timer = try std.time.Timer.start();
    clock.timer.reset();
    while (i < DEBUG_CLOCK_SPEED * 100) : (i += 1) {
        //timer.reset();
        const red: u8 = @intCast(@mod(std.time.nanoTimestamp(), 256));
        _ = c.SDL_SetRenderDrawColor(renderer, red, 0, 0, 255);
        pointX +%= 1;
        if (pointX == 0) {
            pointY +%= 1;
        }

        memory.data[0] = pointX;
        processor.V[3] = pointY;
        _ = c.SDL_RenderDrawPoint(renderer, pointX, pointY);
        c.SDL_RenderPresent(renderer);
        //std.debug.print("{d} {d} {d}\n", .{ @mod(std.time.nanoTimestamp(), 256), memory.data[0], processor.V[3] });
        //std.time.sleep(renderFrameTime -| timer.read() -| 100_000);
        //while (timer.read() < renderFrameTime) {}
        //totalTime += timer.read();
        clock.tick();
    }
    //std.debug.print("{d}\n", .{totalTime});
    std.debug.print("{d} {d} {d}\n", .{ timer.read(), clock.DEBUG_count, clock.DEBUG_countClock });
}

const std = @import("std");
const Processor = @import("processor.zig").Processor;
const Memory = @import("memory.zig").Memory;
const Clock = @import("clock.zig").Clock;
const Display = @import("display.zig").Display;

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("SDL2/SDL.h");
});

const DEBUG_CLOCK_SPEED = 600;

pub fn main() !void {
    std.debug.print("Hello World\n", .{});
    var processor: Processor = Processor{};
    processor.Init();
    var memory: Memory = Memory{};
    memory.Init();
    var clock: Clock = Clock{};
    try clock.Init(DEBUG_CLOCK_SPEED);
    var display: Display = Display{};
    try display.Init();
    defer display.Destroy();

    var i: u32 = 0;
    //var totalTime: u64 = 0;
    var pointX: u6 = 63;
    var pointY: u5 = 31;
    //const renderFrameTime = 1_666_666;
    var timer = try std.time.Timer.start();
    var isRunning: bool = true;
    var ev: c.SDL_Event = undefined;
    clock.timer.reset();
    while (i < DEBUG_CLOCK_SPEED * 10 and isRunning) : (i += 1) {
        while (c.SDL_PollEvent(&ev) != 0) {
            if (ev.type == c.SDL_QUIT) {
                isRunning = false;
            }
            if (ev.type == c.SDL_KEYUP) {
                switch (ev.key.keysym.sym) {
                    c.SDLK_ESCAPE => {
                        isRunning = false;
                    },
                    else => {},
                }
            }
        }
        //timer.reset();
        //const red: u8 = @intCast(@mod(std.time.nanoTimestamp(), 256));
        //_ = c.SDL_SetRenderDrawColor(renderer, red, 0, 0, 255);
        pointX +%= 1;
        if (pointX == 0) {
            pointY +%= 1;
        }

        memory.data[0] = pointX;
        processor.V[3] = pointY;
        display.toggleMemory(pointX, pointY);
        if (clock.tick60Hz) {
            display.showScreen();
        }
        //std.debug.print("{d} {d} {d}\n", .{ @mod(std.time.nanoTimestamp(), 256), memory.data[0], processor.V[3] });
        //std.time.sleep(renderFrameTime -| timer.read() -| 100_000);
        //while (timer.read() < renderFrameTime) {}
        //totalTime += timer.read();
        clock.tick();
    }
    //std.debug.print("{d}\n", .{totalTime});
    std.debug.print("{d} {d} {d}\n", .{ timer.read(), clock.DEBUG_count, clock.DEBUG_countClock });
}

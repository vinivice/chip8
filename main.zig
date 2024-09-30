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
    var memory: Memory = Memory{};
    memory.Init();
    try memory.loadRom();
    var clock: Clock = Clock{};
    try clock.Init(DEBUG_CLOCK_SPEED);
    var display: Display = Display{};
    try display.Init(&clock);
    defer display.Destroy();
    var processor: Processor = Processor{};
    processor.Init(&memory, &display, &clock);

    //********************DEBUG************************
    //var i: u32 = 0;
    //********************DEBUG************************

    var isRunning: bool = true;
    var ev: c.SDL_Event = undefined;
    clock.timer.reset();
    //while (i < DEBUG_CLOCK_SPEED * 10 and isRunning) : (i += 1) {
    while (isRunning) {
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
        processor.processInstruction();
        if (clock.tick60Hz) {
            display.showScreen();
        }
        clock.tick();
    }
}

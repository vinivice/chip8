const std = @import("std");
const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("SDL2/SDL.h");
});

const SDL_errors = error{
    InitFailed,
    CreateWindowAndRendererFailed,
};

pub const Display = struct {
    screen: [32][64]u1 = undefined,
    window: ?*c.SDL_Window = undefined,
    renderer: ?*c.SDL_Renderer = undefined,

    pub fn Init(this: *Display) !void {
        var sdlReturn: c_int = c.SDL_Init(c.SDL_INIT_VIDEO);

        if (sdlReturn < 0) {
            return SDL_errors.InitFailed;
        }

        sdlReturn = c.SDL_CreateWindowAndRenderer(640, 320, c.SDL_WINDOW_SHOWN, &(this.window), &(this.renderer));
        if (sdlReturn < 0) {
            return SDL_errors.CreateWindowAndRendererFailed;
        }
        c.SDL_SetWindowPosition(this.window, 0, 0);

        _ = c.SDL_RenderSetLogicalSize(this.renderer, 64, 32);
        _ = c.SDL_SetRenderDrawColor(this.renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(this.renderer);
        c.SDL_RenderPresent(this.renderer);
    }

    pub fn Destroy(this: *Display) void {
        defer c.SDL_Quit();
        defer c.SDL_DestroyWindow(this.window);
        defer c.SDL_DestroyRenderer(this.renderer);
    }

    pub fn toggleMemory(this: *Display, col: u6, row: u5) void {
        this.screen[row][col] = 1 - this.screen[row][col];
    }

    pub fn showScreen(this: *Display) void {
        _ = c.SDL_SetRenderDrawColor(this.renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(this.renderer);
        _ = c.SDL_SetRenderDrawColor(this.renderer, 255, 0, 0, 255);

        var row: u8 = 0;
        var col: u8 = 0;
        while (row < 32) : (row += 1) {
            while (col < 64) : (col += 1) {
                if (this.screen[row][col] == 1) {
                    _ = c.SDL_RenderDrawPoint(this.renderer, col, row);
                }
                //std.debug.print("{d}", .{this.screen[ @as(usize, @intCast(row)) ][ @as(usize, @intCast(col)) ]});
            }
            col = 0;
            //std.debug.print("\n", .{});
        }
        //std.debug.print("\n\n\n", .{});
        c.SDL_RenderPresent(this.renderer);
    }
};

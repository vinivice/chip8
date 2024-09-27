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

    pub fn togglePixel(this: *Display, col: u6, row: u5) void {
        this.screen[row][col] = this.screen[row][col] ^ 1;
    }

    pub fn clearScreen(this: *Display) void {
        var row: u8 = 0;
        var col: u8 = 0;
        while (row < 32) : (row += 1) {
            while (col < 64) : (col += 1) {
                this.screen[row][col] = 0;
            }
            col = 0;
        }
    }

    pub fn drawSprite(this: *Display, col: u8, row: u8, height: u4, sprite: []u8) bool {
        const trimmedCol: u8 = col % 0x40;
        const trimmedRow: u8 = row % 0x20;
        var _r: usize = 0;
        var _c: usize = 0;

        //DEBUG ***********
        //std.debug.print("{d} {d} {d}\n", .{ row, col, height });
        //var i: u8 = 0;
        //while (i < height) : (i += 1) {
        //    std.debug.print("{b}\n", .{sprite[i]});
        //}
        //std.debug.print("\n", .{});
        //DEBUG ***********

        var unset: bool = false;

        while (_r < height) : (_r += 1) {
            while (_c < 8) : (_c += 1) {
                const curRow = (trimmedRow + _r);
                const curCol = (trimmedCol + _c);
                if (curRow < 32 and curCol < 64) {
                    const pastPixel = this.screen[curRow][curCol];
                    this.screen[curRow][curCol] ^= @intCast(((sprite[_r] >> (7 - @as(u3, @intCast(_c)))) & 1));
                    if (pastPixel == 1 and this.screen[curRow][curCol] == 0) {
                        unset = true;
                    }
                }
            }
            _c = 0;
        }
        return unset;
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
            }
            col = 0;
        }
        c.SDL_RenderPresent(this.renderer);
    }
};

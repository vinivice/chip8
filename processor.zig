const std = @import("std");
const Display = @import("display.zig").Display;
const Memory = @import("memory.zig").Memory;
const Clock = @import("clock.zig").Clock;

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("SDL2/SDL.h");
});

pub const Processor = struct {
    //Memory referente
    memory: *Memory = undefined,
    //Display reference
    display: *Display = undefined,
    //Clock reference
    clock: *Clock = undefined,
    //16 Registers
    V: [16]u8 = undefined,
    //Address Register
    I: u12 = undefined,
    //Program counter register
    PC: u12 = 0x200,
    SP: u4 = 0,
    stack: [15]u12 = undefined,

    fn push(this: *Processor) void {
        if (this.SP == 0xf) {
            unreachable;
        }

        this.SP += 1;
        this.stack[this.SP] = this.PC;
    }

    fn pop(this: *Processor) void {
        if (this.SP == 0x0) {
            unreachable;
        }

        this.PC = this.stack[this.SP];
        this.SP -= 1;
    }

    pub fn Init(this: *Processor, m: *Memory, d: *Display, clock: *Clock) void {
        this.memory = m;
        this.display = d;
        this.clock = clock;

        var i: usize = 0;
        while (i < this.V.len) : (i += 1) {
            this.V[i] = 0;
        }
        while (i < this.stack.len) : (i += 1) {
            this.stack[i] = 0;
        }
        this.I = 0;
    }

    pub fn processInstruction(this: *Processor) void {
        const p0: u4 = @intCast((this.memory.data[this.PC] & 0xF0) >> 4);
        const p1: u4 = @intCast(this.memory.data[this.PC] & 0x0F);
        const p2: u4 = @intCast((this.memory.data[this.PC + 1] & 0xF0) >> 4);
        const p3: u4 = @intCast(this.memory.data[this.PC + 1] & 0x0F);

        this.PC += 2;
        const debug: bool = false;

        if (debug) {
            std.debug.print("Inst: {x:0>1} {x:0>1} {x:0>1} {x:0>1}\t", .{ p0, p1, p2, p3 });
        }

        switch (p0) {
            0x0 => {
                if (p1 == 0) {
                    if (p2 == 0xE and p3 == 0) {
                        this.display.clearScreen();
                        if (debug) {
                            std.debug.print("CLRSCR\n", .{});
                        }
                    } else if (p2 == 0xE and p3 == 0xE) {
                        this.pop();
                    } else {
                        std.debug.print("IN 0 {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                        unreachable;
                    }
                }
            },
            0x1 => {
                this.PC = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                if (debug) {
                    std.debug.print("pc == 0x{x}\n", .{this.pc});
                }
            },
            0x2 => {
                this.push();
                this.PC = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                if (debug) {
                    std.debug.print("pc == 0x{x}\n", .{this.pc});
                }
            },
            0x3 => {
                if (this.V[p1] == (@as(u8, @intCast(p2)) << 4) + p3) {
                    this.PC += 2;
                }

                if (debug) {
                    std.debug.print("if(Vx == NN)\n", .{this.pc});
                }
            },
            0x4 => {
                if (this.V[p1] != (@as(u8, @intCast(p2)) << 4) + p3) {
                    this.PC += 2;
                }

                if (debug) {
                    std.debug.print("if(Vx != NN)\n", .{this.pc});
                }
            },
            0x5 => {
                if (this.V[p1] == this.V[p2]) {
                    this.PC += 2;
                }

                if (debug) {
                    std.debug.print("if(Vx == VY)\n", .{this.pc});
                }
            },
            0x6 => {
                this.V[p1] = (@as(u8, @intCast(p2)) << 4) + p3;
                if (debug) {
                    std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                }
            },
            0x7 => {
                this.V[p1] +%= (@as(u8, @intCast(p2)) << 4) + p3;
                if (debug) {
                    std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                }
            },
            0x8 => {
                switch (p3) {
                    0x0 => {
                        this.V[p1] = this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} == V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x1 => {
                        this.V[p1] |= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} |= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x2 => {
                        this.V[p1] &= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} &= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x3 => {
                        this.V[p1] ^= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} ^= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x4 => {
                        const sumAndOverflow = @addWithOverflow(this.V[p1], this.V[p2]);
                        this.V[p1] = sumAndOverflow[0];
                        this.V[0xf] = sumAndOverflow[1];
                        if (debug) {
                            std.debug.print("V{X} += V{Y} with carry\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x5 => {
                        const diffAndOverflow = @subWithOverflow(this.V[p1], this.V[p2]);
                        this.V[p1] = diffAndOverflow[0];
                        this.V[0xf] = diffAndOverflow[1] ^ 1;
                        if (debug) {
                            std.debug.print("V{X} -= V{Y} with carry\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x6 => {
                        const temp = this.V[p1] & 1;
                        this.V[p1] >>= 1;
                        this.V[0xf] = temp;
                        if (debug) {
                            std.debug.print("V{X} >>= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x7 => {
                        const diffAndOverflow = @subWithOverflow(this.V[p2], this.V[p1]);
                        this.V[p1] = diffAndOverflow[0];
                        this.V[0xf] = diffAndOverflow[1] ^ 1;
                        if (debug) {
                            std.debug.print("V{X} = V{Y} - V{X}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0xE => {
                        const temp = (this.V[p1] & 0b10000000) >> 7;
                        this.V[p1] <<= 1;
                        this.V[0xf] = temp;
                        if (debug) {
                            std.debug.print("V{X} <<= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    else => {
                        std.debug.print("IN 8 {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                        unreachable;
                    },
                }
            },
            0x9 => {
                if (this.V[p1] != this.V[p2]) {
                    this.PC += 2;
                }

                if (debug) {
                    std.debug.print("if(Vx != VY)\n", .{this.pc});
                }
            },
            0xA => {
                this.I = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                if (debug) {
                    std.debug.print("I == 0x{x}\n", .{this.I});
                }
            },
            0xB => {
                const address = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                this.PC = this.V[0x0] + address;
                if (debug) {
                    std.debug.print("I == 0x{x}\n", .{this.I});
                }
            },
            0xD => {
                if (this.display.drawSprite(this.V[p1], this.V[p2], p3, this.memory.data[this.I..])) {
                    this.V[0xf] = 1;
                    if (debug) {
                        std.debug.print("UNSET ", .{});
                    }
                }
                if (debug) {
                    std.debug.print("DRAW\n", .{});
                }
            },
            0xE => {
                c.SDL_PumpEvents();
                //TODO REFACTOR AND PUT INTO FUNCTIONS
                const keyboardState: [*]const u8 = c.SDL_GetKeyboardState(null);
                var keysPressed: [16]bool = undefined;
                keysPressed[0x0] = keyboardState[c.SDL_SCANCODE_X] == 1;
                keysPressed[0x1] = keyboardState[c.SDL_SCANCODE_1] == 1;
                keysPressed[0x2] = keyboardState[c.SDL_SCANCODE_2] == 1;
                keysPressed[0x3] = keyboardState[c.SDL_SCANCODE_3] == 1;
                keysPressed[0x4] = keyboardState[c.SDL_SCANCODE_Q] == 1;
                keysPressed[0x5] = keyboardState[c.SDL_SCANCODE_W] == 1;
                keysPressed[0x6] = keyboardState[c.SDL_SCANCODE_E] == 1;
                keysPressed[0x7] = keyboardState[c.SDL_SCANCODE_A] == 1;
                keysPressed[0x8] = keyboardState[c.SDL_SCANCODE_S] == 1;
                keysPressed[0x9] = keyboardState[c.SDL_SCANCODE_D] == 1;
                keysPressed[0xa] = keyboardState[c.SDL_SCANCODE_Z] == 1;
                keysPressed[0xb] = keyboardState[c.SDL_SCANCODE_C] == 1;
                keysPressed[0xc] = keyboardState[c.SDL_SCANCODE_4] == 1;
                keysPressed[0xd] = keyboardState[c.SDL_SCANCODE_R] == 1;
                keysPressed[0xe] = keyboardState[c.SDL_SCANCODE_F] == 1;
                keysPressed[0xf] = keyboardState[c.SDL_SCANCODE_V] == 1;
                if (p2 == 0x9 and p3 == 0xE) {
                    //std.debug.print("{any}\n", .{keysPressed});
                    if (keysPressed[this.V[p1]]) {
                        this.PC += 2;
                    }
                } else if (p2 == 0xA and p3 == 0x1) {
                    if (!keysPressed[this.V[p1]]) {
                        this.PC += 2;
                    }
                } else {
                    std.debug.print("in e {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                    unreachable;
                }
            },
            0xF => {
                switch (p2) {
                    0x0 => {
                        switch (p3) {
                            0x7 => {
                                this.V[p1] = this.clock.delayTimer;
                            },
                            0xA => {
                                var ev: c.SDL_Event = undefined;
                                var waitingKeyPress: bool = true;
                                while (waitingKeyPress) {
                                    _ = c.SDL_WaitEvent(&ev);
                                    if (ev.type == c.SDL_KEYDOWN) {
                                        switch (ev.key.keysym.sym) {
                                            c.SDLK_x => {
                                                this.V[p1] = 0x0;
                                            },
                                            c.SDLK_1 => {
                                                this.V[p1] = 0x1;
                                            },
                                            c.SDLK_2 => {
                                                this.V[p1] = 0x2;
                                            },
                                            c.SDLK_3 => {
                                                this.V[p1] = 0x3;
                                            },
                                            c.SDLK_q => {
                                                this.V[p1] = 0x4;
                                            },
                                            c.SDLK_w => {
                                                this.V[p1] = 0x5;
                                            },
                                            c.SDLK_e => {
                                                this.V[p1] = 0x6;
                                            },
                                            c.SDLK_a => {
                                                this.V[p1] = 0x7;
                                            },
                                            c.SDLK_s => {
                                                this.V[p1] = 0x8;
                                            },
                                            c.SDLK_d => {
                                                this.V[p1] = 0x9;
                                            },
                                            c.SDLK_z => {
                                                this.V[p1] = 0xa;
                                            },
                                            c.SDLK_c => {
                                                this.V[p1] = 0xb;
                                            },
                                            c.SDLK_4 => {
                                                this.V[p1] = 0xc;
                                            },
                                            c.SDLK_r => {
                                                this.V[p1] = 0xd;
                                            },
                                            c.SDLK_f => {
                                                this.V[p1] = 0xe;
                                            },
                                            c.SDLK_v => {
                                                this.V[p1] = 0xf;
                                            },
                                            else => {
                                                continue;
                                            },
                                        }
                                        waitingKeyPress = false;
                                    }
                                }
                            },
                            else => {
                                std.debug.print("in fx0 {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                                unreachable;
                            },
                        }
                    },
                    0x1 => {
                        switch (p3) {
                            0x5 => {
                                this.clock.delayTimer = this.V[p1];
                            },
                            0xE => {
                                this.I += this.V[p1];
                            },
                            else => {
                                std.debug.print("in fx1 {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                                unreachable;
                            },
                        }
                    },
                    0x3 => {
                        const hundreds = this.V[p1] / 100;
                        const tens = (this.V[p1] % 100) / 10;
                        const ones = (this.V[p1] % 10);

                        this.memory.data[this.I] = hundreds;
                        this.memory.data[this.I + 1] = tens;
                        this.memory.data[this.I + 2] = ones;
                    },
                    0x5 => {
                        var i: u4 = 0;
                        while (i <= p1) : (i += 1) {
                            this.memory.data[this.I + i] = this.V[i];
                        }
                    },
                    0x6 => {
                        var i: u4 = 0;
                        while (i <= p1) : (i += 1) {
                            this.V[i] = this.memory.data[this.I + i];
                        }
                    },
                    else => {
                        std.debug.print("IN F {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                        unreachable;
                    },
                }
            },
            else => {
                std.debug.print("IN ELSE {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
                unreachable;
            },
        }
    }
};

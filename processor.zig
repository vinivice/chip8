const std = @import("std");
const Display = @import("display.zig").Display;
const Memory = @import("memory.zig").Memory;

pub const Processor = struct {
    //Memory referente
    memory: *Memory = undefined,
    //Display reference
    display: *Display = undefined,
    //16 Registers
    V: [16]u8 = undefined,
    //Address Register
    I: u12 = undefined,
    //Program counter register
    PC: u12 = 0x200,

    pub fn Init(this: *Processor, m: *Memory, d: *Display) void {
        this.memory = m;
        this.display = d;

        var i: usize = 0;
        while (i < this.V.len) : (i += 1) {
            this.V[i] = 0;
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
                    }
                }
            },
            0x1 => {
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
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x1 => {
                        this.V[p1] |= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x2 => {
                        this.V[p1] &= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x3 => {
                        this.V[p1] ^= this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x4 => {
                        this.V[p1] +%= this.V[p2];
                        //TODO OVERFLOW
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x5 => {
                        this.V[p1] -%= this.V[p2];
                        //TODO UNDERFLOW
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x6 => {
                        this.V[0xf] = this.V[p1] & 1;
                        this.V[p1] >>= 1;
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0x7 => {
                        this.V[p1] = this.V[p2] -% this.V[p1];
                        //TODO UNDERFLOW
                        this.V[p1] = this.V[p2];
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    0xE => {
                        this.V[0xf] = (this.V[p1] & 0b10000000) >> 7;
                        this.V[p1] <<= 1;
                        if (debug) {
                            std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
                        }
                    },
                    else => unreachable,
                }
            },
            0xA => {
                this.I = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
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

            else => {},
        }
    }
};

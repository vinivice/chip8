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

    pub fn Init(this: *Processor, m: *Memory, d: *Display) void {
        this.memory = m;
        this.display = d;

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
                        this.V[0xf] = this.V[p1] & 1;
                        this.V[p1] >>= 1;
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
                        this.V[0xf] = (this.V[p1] & 0b10000000) >> 7;
                        this.V[p1] <<= 1;
                        if (debug) {
                            std.debug.print("V{X} <<= V{Y}\n", .{ p1, this.V[p1] });
                        }
                    },
                    else => unreachable,
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
            0xF => {
                switch (p2) {
                    0x1 => {
                        switch (p3) {
                            0xE => {
                                this.I += this.V[p1];
                            },
                            else => {
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
                        std.debug.print("F ELSE\n", .{});
                    },
                }
            },
            else => {
                std.debug.print("IN ELSE {x} {x} {x} {x}\n", .{ p0, p1, p2, p3 });
            },
        }
    }
};

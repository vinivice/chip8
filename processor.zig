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

        std.debug.print("Inst: {x:0>1} {x:0>1} {x:0>1} {x:0>1}\t", .{ p0, p1, p2, p3 });

        switch (p0) {
            0x0 => {
                if (p1 == 0) {
                    if (p2 == 0xE and p3 == 0) {
                        this.display.clearScreen();
                        std.debug.print("CLRSCR\n", .{});
                    }
                }
            },
            0x1 => {
                this.PC = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                std.debug.print("PC == 0x{x}\n", .{this.PC});
            },
            0x6 => {
                this.V[p1] = (@as(u8, @intCast(p2)) << 4) + p3;
                std.debug.print("V{X} == 0x{x}\n", .{ p1, this.V[p1] });
            },
            0xA => {
                this.I = (@as(u12, @intCast(p1)) << 8) + (@as(u12, @intCast(p2)) << 4) + p3;
                std.debug.print("I == 0x{x}\n", .{this.I});
            },
            0xD => {
                if (this.display.drawSprite(this.V[p1], this.V[p2], p3, this.memory.data[this.I..])) {
                    this.V[0xf] = 1;
                    std.debug.print("UNSET ", .{});
                }
                std.debug.print("DRAW\n", .{});
            },

            else => {},
        }
    }
};

const std = @import("std");
pub const Memory = struct {
    data: [4096]u8 = undefined,

    pub fn Init(this: *Memory) void {
        var i: usize = 0;
        while (i < this.data.len) : (i += 1) {
            this.data[i] = 0;
        }
    }

    pub fn loadRom(this: *Memory) !void {
        var file = try std.fs.cwd().openFile("ROMs/1-chip8-logo.ch8", .{});
        defer file.close();
        const nBytes = try file.readAll(this.data[512..]);
        std.debug.print("Read {d}\n", .{nBytes});

        var i: u32 = 0;
        while (i < 4096) : (i += 1) {
            if (i % 16 == 0) {
                std.debug.print("0x{x:0>3}\t", .{i});
            }
            std.debug.print("{x:0>2} ", .{this.data[i]});
            if (i % 16 == 15) {
                std.debug.print("\n", .{});
            }
        }
    }
};

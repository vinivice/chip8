const std = @import("std");
pub const Memory = struct {
    data: [4096]u8 = undefined,

    pub fn Init(this: *Memory) void {
        //var i: usize = 0;
        //while (i < this.data.len) : (i += 1) {
        //    this.data[i] = 0;
        //}
        //this.data = [_]u8{0} ** 4096;
        this.data = [_]u8{
            0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
            0x20, 0x60, 0x20, 0x20, 0x70, // 1
            0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
            0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
            0x90, 0x90, 0xF0, 0x10, 0x10, // 4
            0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
            0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
            0xF0, 0x10, 0x20, 0x40, 0x40, // 7
            0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
            0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
            0xF0, 0x90, 0xF0, 0x90, 0x90, // A
            0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
            0xF0, 0x80, 0x80, 0x80, 0xF0, // C
            0xE0, 0x90, 0x90, 0x90, 0xE0, // D
            0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
            0xF0, 0x80, 0xF0, 0x80, 0x80, // F
        } ++ [_]u8{0} ** 4016;
        std.debug.print("{s}\n", .{std.fmt.fmtSliceHexLower(&this.data)});
    }

    pub fn loadRom(this: *Memory) !void {
        var args = std.process.args();
        std.debug.print("ARGS: ", .{});
        //while (args.next()) |arg| {
        //    std.debug.print("{s} ", .{arg});
        //}
        _ = args.skip();
        const rom = args.next();
        std.debug.print("{s}\n", .{rom.?});
        //var file = try std.fs.cwd().openFile("ROMs/2-ibm-logo.ch8", .{});
        var file = try std.fs.cwd().openFile(rom.?, .{});

        defer file.close();
        _ = try file.readAll(this.data[512..]);
        //std.debug.print("Read {d}\n", .{nBytes});

        //var i: u32 = 0;
        //while (i < 4096) : (i += 1) {
        //    if (i % 16 == 0) {
        //        std.debug.print("0x{x:0>3}\t", .{i});
        //    }
        //    std.debug.print("{x:0>2} ", .{this.data[i]});
        //    if (i % 16 == 15) {
        //        std.debug.print("\n", .{});
        //    }
        //}
    }
};

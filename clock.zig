const std = @import("std");
pub const Clock = struct {
    clockFrequency: u64 = 1,
    timer: std.time.Timer = undefined,
    delayTimer: u32 = 0,
    soundTimer: u32 = 0,
    ElapsedTimeFor60Hz: u64 = 0,
    DEBUG_count: u64 = 0,
    DEBUG_countClock: u64 = 0,

    pub fn Init(this: *Clock, frequency: u64) !void {
        this.clockFrequency = frequency;
        this.timer = try std.time.Timer.start();
    }

    pub fn changeFrequency(this: *Clock, frequency: u64) void {
        this.clockFrequency = frequency;
    }

    pub fn tick(this: *Clock) void {
        const clockTime = 1_000_000_000 / this.clockFrequency;
        if (this.ElapsedTimeFor60Hz > 16_666_666) {
            std.debug.print("{d} ", .{this.ElapsedTimeFor60Hz});
            //this.ElapsedTimeFor60Hz -|= 16_666_666;
            this.ElapsedTimeFor60Hz = 0;
            std.debug.print("{d} {d}\n", .{ this.ElapsedTimeFor60Hz, this.DEBUG_countClock });
            this.delayTimer -|= 1;
            this.soundTimer -|= 1;
            this.DEBUG_count += 1;
        }
        this.DEBUG_countClock += 1;
        std.time.sleep(clockTime -| this.timer.read() -| 100_000);
        while (this.timer.read() < clockTime) {}
        this.ElapsedTimeFor60Hz += this.timer.read();
        this.timer.reset();
    }
};

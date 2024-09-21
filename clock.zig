const std = @import("std");
pub const Clock = struct {
    clockFrequency: u64 = 1,
    timer: std.time.Timer = undefined,
    delayTimer: u8 = 0,
    soundTimer: u8 = 0,
    ElapsedTimeFor60Hz: u64 = 0,
    tick60Hz: bool = false,
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
        this.tick60Hz = false;
        if (this.ElapsedTimeFor60Hz > 16_666_666) {
            this.ElapsedTimeFor60Hz = 0;
            this.delayTimer -|= 1;
            this.soundTimer -|= 1;
            this.DEBUG_count += 1;
            this.tick60Hz = true;
        }
        this.DEBUG_countClock += 1;
        std.time.sleep(clockTime -| this.timer.read() -| 100_000);
        while (this.timer.read() < clockTime) {}
        this.ElapsedTimeFor60Hz += this.timer.read();
        this.timer.reset();
    }
};

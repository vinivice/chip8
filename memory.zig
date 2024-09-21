pub const Memory = struct {
    data: [4096]u8 = undefined,

    pub fn Init(this: *Memory) void {
        var i: usize = 0;
        while (i < this.data.len) : (i += 1) {
            this.data[i] = 0;
        }
    }
};

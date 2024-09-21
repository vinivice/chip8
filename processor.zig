pub const Processor = struct {
    //16 Registers
    V: [16]u8 = undefined,
    //Address Register
    I: u12 = undefined,

    pub fn Init(this: *Processor) void {
        var i: usize = 0;
        while (i < this.V.len) : (i += 1) {
            this.V[i] = 0;
        }
        this.I = 0;
    }
};

const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "particle_simulator",
        .root_source_file = b.path("main.zig"),
        .target = b.host,
        .optimize = optimize,
    });

    //exe.linkSystemLibrary("c++");
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC();

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application.");

    run_step.dependOn(&run_exe.step);

    b.installArtifact(exe);
}

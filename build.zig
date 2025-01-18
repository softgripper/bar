const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "bar",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sdl3_path = "thirdparty/sdl3";
    exe.linkLibC();
    exe.addLibraryPath(b.path(sdl3_path ++ "/lib"));
    exe.addIncludePath(b.path(sdl3_path ++ "/include"));
    exe.addObjectFile(b.path(sdl3_path ++ "/lib/SDL3.lib"));
    b.installBinFile(sdl3_path ++ "/lib/SDL3.dll", "SDL3.dll");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

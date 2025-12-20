const std = @import("std");
const builtin = @import("builtin");

fn getSunVoxLibraryPath(target: std.Target) struct { []const u8, []const u8 } {
    switch (target.os.tag) {
        .windows => {
            switch (target.cpu.arch) {
                .x86_64 => return .{ "libs/sunvox/windows/lib_x86_64/sunvox.dll", "sunvox.dll" },
                else => return .{ "libs/sunvox/windows/lib_x86/sunvox.dll", "sunvox.dll" },
            }
        },
        .macos => {
            switch (target.cpu.arch) {
                .x86_64 => return .{ "libs/sunvox/macos/lib_x86_64/sunvox.dylib", "sunvox.dylib" },
                else => return .{ "libs/sunvox/macos/lib_arm64/sunvox.dylib", "sunvox.dylib" },
            }
        },
        .linux => {
            switch (target.cpu.arch) {
                .arm => @panic("Arm based SunVox lib is not support for linux yet"),
                .x86_64 => return .{ "libs/sunvox/linux/lib_x86_64/sunvox.so", "sunvox.so" },
                .x86 => return .{ "libs/sunvox/linux/lib_x86/sunvox.so", "sunvox.so" },
                else => @panic("Linux is a bit more complicated in the choice of CPU, \nPlease submit an issue if you have found an unsupported CPU for the existing SunVox Lib"),
            }
        },
        else => {
            @panic("ZunVox is not available in your current operating system yet");
        },
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zunvox = b.addModule("zunvox", .{
        .root_source_file = b.path("src/zunvox.zig"),
        .target = target,
        .link_libc = true,
    });

    // let's only consider 64bit windows first before moving onto other systems
    const src, const dest = getSunVoxLibraryPath(target.result);
    b.getInstallStep().dependOn(&b.addInstallBinFile(b.path(src), dest).step);

    // setting up test
    const test_step = b.step("test", "zunvox tests");

    const test_module = b.addModule("test", .{
        .root_source_file = b.path("src/zunvox.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .name = "zunvox-tests",
        .root_module = test_module,
    });

    tests.root_module.addImport("zunvox", zunvox);
    b.installArtifact(tests);

    var test_step_run = b.addRunArtifact(tests);
    test_step.dependOn(&test_step_run.step);

    test_step_run.setCwd(b.path("zig-out/bin"));
}

pub fn installSunVoxBinary(
    exe: *std.Build.Step.Compile,
    sunvox_dll: *std.Build.Dependency,
    install_dir: std.Build.InstallDir,
) void {
    const b = exe.step.owner;
    const src, const dest = getSunVoxLibraryPath(exe.rootModuleTarget());

    exe.step.dependOn(
        &b.addInstallFileWithDir(
            .{
                .dependency = .{
                    .dependency = sunvox_dll,
                    // .sub_path = "libs/sunvox/windows/lib_x86_64/sunvox.dll",
                    .sub_path = src,
                },
            },
            install_dir,
            dest,
        ).step,
    );
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zunvox = b.addModule("zunvox", .{
        .root_source_file = b.path("src/zunvox.zig"),
        .target = target,
    });

    // let's only consider 64bit windows first before moving onto other system
    b.getInstallStep().dependOn(&b.addInstallBinFile(b.path("libs/sunvox/windows/lib_x86_64/sunvox.dll"), "sunvox.dll").step);

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
    step: *std.Build.Step,
    sunvox_dll: *std.Build.Dependency,
    install_dir: std.Build.InstallDir,
) void {
    const b = step.owner;
    step.dependOn(
        &b.addInstallFileWithDir(
            .{ .dependency = .{
                .dependency = sunvox_dll,
                .sub_path = "libs/sunvox/windows/lib_x86_64/sunvox.dll",
            } },
            install_dir,
            "sunvox.dll",
        ).step,
    );
}

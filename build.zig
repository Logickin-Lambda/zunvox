const std = @import("std");

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zunvox", .{
        .root_source_file = b.path("src/zunvox.zig"),
        .target = target,
    });

    const sunvox = b.addModule("sunvox", .{
        .target = target,
        .optimize = optimize,
    });

    const sunvox_lib = b.addLibrary(.{
        .name = "sunvox",
        .root_module = sunvox,
        .linkage = .static,
    });

    b.installArtifact(sunvox_lib);

    sunvox.addIncludePath(b.path("libs/sunvox"));
    sunvox_lib.linkLibCpp();
    sunvox_lib.linkLibC();

    sunvox.addCSourceFile(.{
        .file = b.path("libs/sunvox/sunvox.c"),
        .flags = &.{
            "-DSUNVOX_MAIN",
        },
    });

    // let's only consider 64bit windows first before moving onto other system
    b.getInstallStep().dependOn(&b.addInstallBinFile(b.path("libs/sunvox/windows/lib_x86_64/sunvox.dll"), "sunvox.dll").step);

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

    tests.linkLibrary(sunvox_lib);
    tests.root_module.addLibraryPath(b.path("libs/sunvox/windows/lib_x86_64"));
    tests.root_module.linkSystemLibrary("sunvox", .{});

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

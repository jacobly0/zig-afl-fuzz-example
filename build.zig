const std = @import("std");
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const prog_name = b.fmt("prog{s}", .{target.result.exeFileExt()});
    const prog_bc_step = b.addExecutable(.{
        .name = prog_name,
        .root_source_file = b.path("prog.zig"),
        .target = target,
        .optimize = optimize,
    });
    prog_bc_step.root_module.stack_check = false; // not linking with compiler-rt
    prog_bc_step.root_module.link_libc = true; // afl runtime depends on libc
    _ = prog_bc_step.getEmittedBin(); // hack around build system bug

    const afl_clang_fast_path = try b.findProgram(
        &.{ "afl-clang-fast", "afl-clang" },
        if (b.option([]const u8, "afl-path", "Path to AFLplusplus")) |afl_path| &.{afl_path} else &.{},
    );
    const run_afl_clang_fast = b.addSystemCommand(&.{ afl_clang_fast_path, "-o" });
    const prog_exe = run_afl_clang_fast.addOutputFileArg(prog_name);
    run_afl_clang_fast.addFileArg(prog_bc_step.getEmittedLlvmBc());

    b.getInstallStep().dependOn(&b.addInstallBinFile(prog_exe, prog_name).step);
}

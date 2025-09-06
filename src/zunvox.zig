//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const SvError = error{
    FailedToLoadDll,
};

pub fn loadDll() SvError!void {
    if (sv_load_dll() < 0) {
        return SvError.FailedToLoadDll;
    }
}

extern fn sv_load_dll() c_int;

test "init sunvox library" {
    try loadDll();
}

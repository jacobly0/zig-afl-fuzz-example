const std = @import("std");
pub fn main() !void {
    var buf: [12]u8 = undefined;
    if (try std.io.getStdIn().reader().readAll(&buf) == buf.len) {
        std.debug.assert(!std.mem.eql(u8, &buf, "canyoufindme"));
    }
}

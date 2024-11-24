const xxhash = @import("./xxhash.zig").xxhash;
const std = @import("std");

pub export fn xxh64(message: [*c]const u8, seed: u64) u64 {
    const as_slice: [:0]const u8 = std.mem.span(message);
    const input = as_slice[0..as_slice.len];
    return xxhash.checksum(input, seed);
}

const std = @import("std");
const mem = std.mem;
const debug = std.debug;

var prime_1: u64 = 11400714785074694791;
var prime_2: u64 = 14029467366897019727;
var prime_3: u64 = 1609587929392839161;
var prime_4: u64 = 9650029242287828579;
var prime_5: u64 = 2870177450012600261;

pub const xxhash = struct {
    seed: u64,
    v1: u64,
    v2: u64,
    v3: u64,
    v4: u64,
    total_len: u64,
    buf: [32]u8,
    buf_used: i64,

    pub fn init(seed: u64) xxhash {
        var hash: xxhash = undefined;
        hash.seed = seed;
        hash.reset();
        return hash;
    }

    pub fn reset(self: *xxhash) void {
        self.v1 = self.seed +% prime_1 +% prime_2;
        self.v2 = self.seed +% prime_2;
        self.v3 = self.seed;
        self.v4 = self.seed -% prime_1;
        self.total_len = 0;
        self.buf_used = 0;
    }

    pub fn sum(self: *xxhash) u64 {
        var h64: u64 = 0;
        if (self.total_len >= 32) {
            h64 = rol1(self.v1) +% rol7(self.v2) +% rol12(self.v3) +% rol18(self.v4);

            self.v1 *%= prime_2;
            self.v2 *%= prime_2;
            self.v3 *%= prime_2;
            self.v4 *%= prime_2;

            h64 = (h64 ^ (rol31(self.v1) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(self.v2) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(self.v3) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(self.v4) *% prime_1)) *% prime_1 +% prime_4;

            h64 += self.total_len;
        } else {
            h64 = self.seed +% prime_5 +% self.total_len;
        }

        var p: usize = 0;
        const n = self.buf_used;

        while (@as(i64, @intCast(p)) <= n - 8) : (p += 8) {
            h64 ^= rol31(uint64(self.buf[p .. p + 8]) *% prime_2) *% prime_1;
            h64 = rol27(h64) *% prime_1 +% prime_4;
        }

        if (@as(i64, @intCast(p + 4)) <= n) {
            const sub = self.buf[p .. p + 4];
            h64 ^= uint32(sub) *% prime_1;
            h64 = rol23(h64) *% prime_2 +% prime_3;
            p += 4;
        }

        while (@as(i64, @intCast(p)) < n) : (p += 1) {
            h64 ^= self.buf[p] *% prime_5;
            h64 = rol11(h64) *% prime_1;
        }

        h64 ^= h64 >> 33;
        h64 *%= prime_2;
        h64 ^= h64 >> 29;
        h64 *%= prime_3;
        h64 ^= h64 >> 32;

        return h64;
    }

    pub fn write(self: *xxhash, input: []const u8) usize {
        const n = input.len;
        const m = @as(usize, @intCast((self.buf_used)));

        self.total_len += @as(u64, @intCast(n));

        const r = self.buf.len - m;

        if (n < r) {
            for (input, m..) |b, i| self.buf[i] = b;
            self.buf_used += @as(i64, @intCast(input.len));
            return n;
        }

        var p: usize = 0;
        if (m > 0) {
            for (input[0..r], @as(usize, @intCast((self.buf_used)))..) |b, i| self.buf[i] = b;
            self.buf_used += @as(i64, @intCast(input.len - r));

            self.v1 = rol31(self.v1 +% uint64(self.buf[0..]) *% prime_2) *% prime_1;
            self.v2 = rol31(self.v2 +% uint64(self.buf[8..]) *% prime_2) *% prime_1;
            self.v3 = rol31(self.v3 +% uint64(self.buf[16..]) *% prime_2) *% prime_1;
            self.v4 = rol31(self.v4 +% uint64(self.buf[24..]) *% prime_2) *% prime_1;

            p = r;
            self.buf_used = 0;
        }

        while (p <= n - 32) : (p += 32) {
            var sub = input[p..];

            self.v1 = rol31(self.v1 +% uint64(sub[0..]) *% prime_2) *% prime_1;
            self.v2 = rol31(self.v2 +% uint64(sub[8..]) *% prime_2) *% prime_1;
            self.v3 = rol31(self.v3 +% uint64(sub[16..]) *% prime_2) *% prime_1;
            self.v4 = rol31(self.v4 +% uint64(sub[24..]) *% prime_2) *% prime_1;
        }

        for (input[p..], @as(usize, @intCast((self.buf_used)))..) |b, i| self.buf[i] = b;
        self.buf_used += @as(i64, @intCast(input.len - p));

        return n;
    }

    pub fn checksum(input: []const u8, seed: u64) u64 {
        var n = input.len;
        var h64: u64 = 0;

        var input2: []const u8 = undefined;
        if (n >= 32) {
            var v1 = seed +% prime_1 +% prime_2;
            var v2 = seed +% prime_2;
            var v3 = seed;
            var v4 = seed -% prime_1;

            var p: usize = 0;
            while (p <= n - 32) : (p += 32) {
                var sub = input[p..];

                v1 = rol31(v1 +% uint64(sub[0..]) *% prime_2) *% prime_1;
                v2 = rol31(v2 +% uint64(sub[8..]) *% prime_2) *% prime_1;
                v3 = rol31(v3 +% uint64(sub[16..]) *% prime_2) *% prime_1;
                v4 = rol31(v4 +% uint64(sub[24..]) *% prime_2) *% prime_1;
            }

            h64 = rol1(v1) +% rol7(v2) +% rol12(v3) +% rol18(v4);

            v1 *%= prime_2;
            v2 *%= prime_2;
            v3 *%= prime_2;
            v4 *%= prime_2;

            h64 = (h64 ^ (rol31(v1) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(v2) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(v3) *% prime_1)) *% prime_1 +% prime_4;
            h64 = (h64 ^ (rol31(v4) *% prime_1)) *% prime_1 +% prime_4;

            h64 +%= n;

            input2 = input[p..];
            n -= p;
        } else {
            h64 = seed +% prime_5 +% n;
            input2 = input[0..];
        }

        var p: usize = 0;
        while (@as(i64, @intCast(p)) <= @as(i64, @intCast(n)) - 8) : (p += 8) {
            const sub = input2[p .. p + 8];
            h64 ^= rol31(uint64(sub) *% prime_2) *% prime_1;
            h64 = rol27(h64) *% prime_1 +% prime_4;
        }

        if (p + 4 <= n) {
            const sub = input2[p .. p + 4];
            h64 ^= @as(u64, @intCast(uint32(sub))) *% prime_1;
            h64 = rol23(h64) *% prime_2 +% prime_3;
            p += 4;
        }

        while (p < n) : (p += 1) {
            h64 ^= @as(u64, @intCast(input2[p])) *% prime_5;
            h64 = rol11(h64) *% prime_1;
        }

        h64 ^= h64 >> 33;
        h64 *%= prime_2;
        h64 ^= h64 >> 29;
        h64 *%= prime_3;
        h64 ^= h64 >> 32;
        return h64;
    }
};

fn uint64(buf: []const u8) u64 {
    return @as(u64, @intCast(buf[0])) | @as(u64, @intCast(buf[1])) << 8 | @as(u64, @intCast(buf[2])) << 16 | @as(u64, @intCast(buf[3])) << 24 | @as(u64, @intCast(buf[4])) << 32 | @as(u64, @intCast(buf[5])) << 40 | @as(u64, @intCast(buf[6])) << 48 | @as(u64, @intCast(buf[7])) << 56;
}

fn uint32(buf: []const u8) u32 {
    return @as(u32, @intCast(buf[0])) | @as(u32, @intCast(buf[1])) << 8 | @as(u32, @intCast(buf[2])) << 16 | @as(u32, @intCast(buf[3])) << 24;
}

fn rol1(u: u64) u64 {
    return u << 1 | u >> 63;
}

fn rol7(u: u64) u64 {
    return u << 7 | u >> 57;
}

fn rol11(u: u64) u64 {
    return u << 11 | u >> 53;
}

fn rol12(u: u64) u64 {
    return u << 12 | u >> 52;
}

fn rol18(u: u64) u64 {
    return u << 18 | u >> 46;
}

fn rol23(u: u64) u64 {
    return u << 23 | u >> 41;
}

fn rol27(u: u64) u64 {
    return u << 27 | u >> 37;
}

fn rol31(u: u64) u64 {
    return u << 31 | u >> 33;
}

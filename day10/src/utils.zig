const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const assert = std.debug.assert;

pub fn parseValue(slice: []const u8) !i16 {
    return switch (slice[0]) {
        '-' => -try std.fmt.parseInt(i16, slice[1..], 10),
        else => try std.fmt.parseInt(i16, slice[0..], 10),
    };
}

pub fn Check(cycleNum: usize, x: i64, pairs: *std.ArrayList(Pair), sum: *u64) !void {
    if (!isStrongSignals(cycleNum)) return;
    const p = Pair{ .x_value = x, .cycleNum = cycleNum };
    try pairs.*.append(p);
    std.debug.print("cycle {d} , x = {d} | sum = {d} + {d} = {d}\n", .{ cycleNum, x, sum.*, p.Multiply(), sum.* + p.Multiply() });
    sum.* += p.Multiply();
}

pub fn isStrongSignals(numOfLine: usize) bool {
    return (numOfLine >= 20 and (numOfLine == 20 or (numOfLine - 20) % 40 == 0));
}

pub const Pair = struct {
    x_value: i64,
    cycleNum: usize,
    const Self = @This();
    pub fn Multiply(self: *const Self) u64 {
        return @as(u64, @intCast(self.x_value)) * @as(u64, @intCast(self.cycleNum));
    }
};

test "parsing" {
    try expect(@as(i16, 5) == try parseValue("5"));
    try expect(@as(i16, -5) == try parseValue("-5"));
    try expect(@as(i16, 51) == try parseValue("51"));
    try expect(@as(i16, -51) == try parseValue("-51"));
    try expect(isStrongSignals(10) == false);
    try expect(isStrongSignals(30) == false);
    try expect(isStrongSignals(60) == true);
    try expect(isStrongSignals(100) == true);
    try expect(isStrongSignals(140) == true);
    try expect(isStrongSignals(180) == true);
}

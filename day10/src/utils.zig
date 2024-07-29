const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const assert = std.debug.assert;
const WIDTH: usize = 40;
const HEIGHT: usize = 40;

pub fn parseValue(slice: []const u8) !i16 {
    return switch (slice[0]) {
        '-' => -try std.fmt.parseInt(i16, slice[1..], 10),
        else => try std.fmt.parseInt(i16, slice[0..], 10),
    };
}

pub fn Check(cycleNum: usize, x: i64, pairs: *std.ArrayList(Pair), sum: *u64) !void {
    const index = try getIndex(cycleNum);
    // std.debug.print("\nindex = {d}\n", .{index});
    const spritIndices = [_]i64{ x - 1, x, x + 1 };
    if (In(&spritIndices, index))
        std.debug.print("# ", .{})
    else
        std.debug.print(". ", .{});
    if (index == 39) std.debug.print("\n", .{});
    if (!isStrongSignals(cycleNum)) return;
    const p = Pair{ .x_value = x, .cycleNum = cycleNum };
    try pairs.*.append(p);
    // std.debug.print("cycle {d} , x = {d} | sum = {d} + {d} = {d}\n", .{ cycleNum, x, sum.*, p.Multiply(), sum.* + p.Multiply() });
    sum.* += p.Multiply();
}

const WrongIndex = error{CANT_GET_INDEX};
fn getIndex(cycleNum: usize) WrongIndex!usize {
    if (cycleNum <= 40) return cycleNum - 1;
    var temp = cycleNum;
    while (temp > 40) {
        // for (0..9999999) |_| {}
        // std.debug.print("temp = {d}\n", .{temp});
        if (@as(i64, @intCast(temp)) - 40 > 0) temp = temp - 40;
        if (temp <= 40) return temp - 1;
    }
    return WrongIndex.CANT_GET_INDEX;
}

pub fn isStrongSignals(numOfLine: usize) bool {
    return (numOfLine >= 20 and (numOfLine == 20 or (numOfLine - 20) % 40 == 0));
}

fn In(array: []const i64, value: usize) bool {
    for (array) |v| {
        // if (v == value) std.debug.print("[MATCH] v == value = {d}\n", .{v});
        if (v == @as(i64, @intCast(value))) return true;
    }
    return false;
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

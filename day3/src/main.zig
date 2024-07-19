const std = @import("std");

const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    const fileName: []const u8 = "src/day3.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.split(u8, data, "\n");
    var arr = std.ArrayList(Line).init(std.heap.page_allocator);
    defer arr.deinit();
    while (it.next()) |line| {
        if (line.len != 0) try arr.append(splitLines(line));
    }
    std.debug.print("line = {d}\n", .{arr.items.len});
    const sum = try getSum(arr.items);
    std.debug.print("sum = {d}\n", .{sum});
}

const Line = struct { firstHalf: []const u8, secondHalf: []const u8 };

fn getSum(lines: []Line) !u32 {
    var sum: u32 = 0;
    for (lines) |line| {
        const common_letter = try getCommonLetter(line);
        sum += try getValue(common_letter);
    }
    return sum;
}

fn splitLines(line: []const u8) Line {
    return Line{
        .firstHalf = line[0..(line.len / 2)],
        .secondHalf = line[(line.len / 2)..],
    };
}
fn getCommonLetter(line: Line) !u8 {
    var map = std.AutoHashMap(u8, u8).init(std.heap.page_allocator);
    defer map.deinit();
    for (line.firstHalf) |letter| {
        try map.put(letter, 1);
    }
    for (line.secondHalf) |letter| {
        if (map.contains(letter)) {
            return letter;
        }
    }
    unreachable;
}

fn getValue(common_letter: u8) !u32 {
    return switch (common_letter) {
        'a'...'z' => common_letter - 'a' + 1,
        'A'...'Z' => common_letter - 'A' + 2 + ('z' - 'a'),
        else => unreachable,
    };
}

test "convert letter to value" {
    try expect(try getValue('p') == @as(u32, 16));
    try expect(try getValue('L') == @as(u32, 38));
    try expect(try getValue('P') == @as(u32, 42));
    try expect(try getValue('v') == @as(u32, 22));
    try expect(try getValue('t') == @as(u32, 20));
    try expect(try getValue('s') == @as(u32, 19));
}

test "maps" {
    try expect(try getCommonLetter(Line{ .firstHalf = "abpod", .secondHalf = "ksdae" }) == 'd');
}

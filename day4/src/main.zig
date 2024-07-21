const std = @import("std");

const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    const fileName: []const u8 = "src/day4.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.split(u8, data, "\n");
    var arr = std.ArrayList([2]pair).init(std.heap.page_allocator);
    defer arr.deinit();
    while (it.next()) |line| {
        if (line.len == 0) continue;
        var lPair = pair{};
        var rPair = pair{};
        var step: u2 = 0;
        for (line) |char| {
            switch (step) {
                0 => {
                    if (checkNum(char)) assignOrModify(&lPair.from, char) else step += 1;
                },
                1 => {
                    if (checkNum(char)) assignOrModify(&lPair.to, char) else step += 1;
                },
                2 => {
                    if (checkNum(char)) assignOrModify(&rPair.from, char) else step += 1;
                },
                3 => {
                    if (checkNum(char)) assignOrModify(&rPair.to, char) else step += 1;
                },
            }
        }
        // print("{}-{},{}-{}\n", .{ lPair.from, lPair.to, rPair.from, rPair.to });
        try arr.append([2]pair{ lPair, rPair });
    }
    print("sum = {d}\n", .{getNumOfContained(arr.items)});
    print("overlaps = {d}\n", .{getNumOfOverlaps(arr.items)});
}

fn getNumOfContained(pairs: [][2]pair) usize {
    var sum: usize = 0;
    for (pairs) |couple| {
        if (couple[0].contains(&couple[1]) or couple[1].contains(&couple[0])) sum += 1;
    }
    return sum;
}

fn getNumOfOverlaps(pairs: [][2]pair) usize {
    var sum: usize = 0;
    for (pairs) |couple| {
        if (couple[0].overlapWith(&couple[1]) or couple[1].overlapWith(&couple[0])) sum += 1;
    }
    return sum;
}
fn assignOrModify(numPtr: *u8, value: u8) void {
    if (numPtr.* == 0) numPtr.* = value - 48 else numPtr.* = (numPtr.*) * 10 + value - 48;
}

fn checkNum(char: u8) bool {
    return switch (char) {
        44 => false,
        45 => false,
        else => true,
    };
}

const pair = struct {
    from: u8 = 0,
    to: u8 = 0,
    const Self = @This();
    fn contains(self: *const Self, other: *const pair) bool {
        return (self.*.from <= other.*.from and self.*.to >= other.*.to);
    }
    fn overlapWith(self: *const Self, other: *const pair) bool {
        return !(self.*.from > other.*.to or self.*.to < other.*.from);
    }
};

test "Pairs" {
    const p1 = pair{ .from = 2, .to = 6 };
    const p2 = pair{ .from = 3, .to = 6 };
    const p3 = pair{ .from = 1, .to = 7 };
    try expect(!p1.contains(&p3));
    try expect(!p2.contains(&p1));
    try expect(!p2.contains(&p3));
    try expect(p1.contains(&p2));
    try expect(p3.contains(&p1));
    try expect(p3.contains(&p2));
}

const std = @import("std");
const u = @import("utils.zig");

const print = std.debug.print;
const expect = std.testing.expect;
var X: i64 = 1;
var cycles: usize = 0;
var sum: u64 = 0;

pub fn main() !void {
    const fileName: []const u8 = "src/day10.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var all = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = all.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.splitSequence(u8, data, "\n");
    var pairs = std.ArrayList(u.Pair).init(allocator);
    defer pairs.deinit();
    while (it.next()) |line| {
        if (line.len == 0) continue;
        switch (line[0]) {
            'n' => {
                cycles += 1;
                try u.Check(cycles, X, &pairs, &sum);
            },
            'a' => {
                cycles += 1;
                try u.Check(cycles, X, &pairs, &sum);
                cycles += 1;
                try u.Check(cycles, X, &pairs, &sum);
                const value = try u.parseValue(line[5..]);
                X += @as(i64, @intCast(value));
            },
            else => @panic("received unexpected input!\n"),
        }
    }
    std.debug.print("X = {d}\n", .{X});
    std.debug.print("sum = {d}\n", .{sum});
}

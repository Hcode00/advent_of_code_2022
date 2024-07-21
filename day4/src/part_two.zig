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
    // var arr = std.ArrayList(..type..).init(std.heap.page_allocator);
    // defer arr.deinit();
    while (it.next()) |line| {
        _ = line;
    }
    // std.debug.print("line = {d}\n", .{arr.items.len});
}

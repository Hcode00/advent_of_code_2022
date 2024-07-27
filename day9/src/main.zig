const std = @import("std");
const t = @import("types.zig");

const print = std.debug.print;
const expect = std.testing.expect;

fn moveHead() void {
    const d = t.Direction.toDir('L');
    std.debug.print("Direction = {any}", .{d});
}

pub fn main() !void {
    const fileName: []const u8 = "src/day9.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var all = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = all.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 1000);
    defer allocator.free(data);
    var it = std.mem.splitSequence(u8, data, "\n");
    var Vec = t.Vector().init(allocator);
    defer Vec.deinit();
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const direction = t.Direction.toDir(line[0]);
        var magnitude: u8 = undefined;
        if (line.len == 3) magnitude = line[2] - 48 else {
            const first: u8 = line[2] - 48;
            const last: u8 = line[3] - 48;
            magnitude = first * 10 + last;
        }

        // std.debug.print("move {d} steps {s}\n", .{ magnitude, direction.name() });
        Vec.moveHead(direction, magnitude);
    }
    // Vec.printVisited();
    std.debug.print("visited count = {d}\n", .{Vec.visitedCount()});
}

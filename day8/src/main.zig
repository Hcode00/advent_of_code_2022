const std = @import("std");
const t = @import("types.zig");

const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    const fileName: []const u8 = "src/day8.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var all = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = all.deinit();
    const allocator = all.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.splitSequence(u8, data, "\n");
    var arr = std.ArrayList([]const u8).init(allocator);
    defer arr.deinit();
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try arr.append(line);
    }
    const visibleEdgesCount = arr.items[0].len * 2 + (arr.items.len - 2) * 2;
    std.debug.print("number of edges = {d}\n", .{visibleEdgesCount});

    const visibleNonEdgeCount = countNonEdgeVisible(arr.items, true);
    // const visibleNonEdgeCount = countNonEdgeVisible(arr.items, false);
    std.debug.print("number of non edges visible trees = {d}\n", .{visibleNonEdgeCount});
    const total = visibleEdgesCount + visibleNonEdgeCount;
    std.debug.print("total visible trees = {d}\n", .{total});
}

fn countNonEdgeVisible(arr: [][]const u8, debug: bool) usize {
    const a = arr[1 .. arr.len - 1];
    var count: usize = 0;
    for (a, 0..) |line, outerIdx| {
        for (line, 0..) |char, idx| {
            if (idx == 0 or idx == line.len - 1) continue;
            // std.debug.print("{c} ", .{char});
            // check left
            var visibleLeft = true;
            var visibleRight = true;
            var visibleTop = true;
            var visibleBottom = true;
            for (line[0..idx]) |left| {
                if (left >= char) {
                    // std.debug.print("left -- {c} >= {c}\n", .{ left, char });
                    visibleLeft = false;
                    break;
                }
            }
            // check right
            for (line[idx + 1 ..]) |right| {
                if (right >= char) {
                    // std.debug.print("right -- {c} >= {c}\n", .{ right, char });
                    visibleRight = false;
                    break;
                }
            }
            // check top
            for (arr[0 .. outerIdx + 1]) |top| {
                if (top[idx] >= char) {
                    // std.debug.print("top -- {c} >= {c}\n", .{ top[idx], char });
                    visibleTop = false;
                    break;
                }
            }
            // check bottom
            for (arr[outerIdx + 2 ..]) |bottom| {
                // std.debug.print("outer index = {d} --  ", .{outerIdx});
                // std.debug.print("bottom = {s} for char = {c} \n", .{ arr[outerIdx + 2 ..], char });
                if (bottom[idx] >= char) {
                    // std.debug.print("bottom -- {c} <= {c}\n", .{ char, bottom[idx] });
                    visibleBottom = false;
                    break;
                }
            }
            // std.debug.print("--------------------------\n", .{});
            if (visibleRight or visibleLeft or visibleTop or visibleBottom) {
                count += 1;
                if (debug and visibleTop) std.debug.print("{c} is visible from Top at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleRight) std.debug.print("{c} is visible from Right at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleLeft) std.debug.print("{c} is visible from Left at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleBottom) std.debug.print("{c} is visible from Bottom at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
            }
        }
    }
    return count;
}

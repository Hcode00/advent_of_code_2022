const std = @import("std");

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

    // const visibleNonEdgeCount = Resolve(arr.items, true);
    const visibleNonEdgeCount = Resolve(arr.items, false);
    std.debug.print("number of non edges visible trees = {d}\n", .{visibleNonEdgeCount.visibleCount});
    const total = visibleEdgesCount + visibleNonEdgeCount.visibleCount;
    std.debug.print("total visible trees = {d}\n", .{total});
    std.debug.print("highest scenic = {d}\n", .{visibleNonEdgeCount.scenic});
}

const day8 = struct { visibleCount: usize = 0, scenic: usize = 0 };

fn Resolve(arr: [][]const u8, debug: bool) day8 {
    const a = arr[1 .. arr.len - 1];
    var solution = day8{};
    var maxSteps: usize = 0;
    for (a, 0..) |line, outerIdx| {
        for (line, 0..) |char, idx| {
            if (idx == 0 or idx == line.len - 1) continue;
            var visibleLeft = true;
            var visibleRight = true;
            var visibleTop = true;
            var visibleBottom = true;
            var stepsLeft: usize = 0;
            var stepsRight: usize = 0;
            var stepsTop: usize = 0;
            var stepsBottom: usize = 0;

            // check left

            for (line[0..idx]) |left| {
                if (left >= char) visibleLeft = false;
            }
            var i: usize = idx;
            while (i > 0) : (i -= 1) {
                if (line[i - 1] >= char) {
                    stepsLeft += 1;
                    break;
                }
                if (line[i - 1] <= char) stepsLeft += 1;
            }

            // check right

            for (line[idx + 1 ..]) |right| {
                if (right >= char) {
                    visibleRight = false;
                    stepsRight += 1;
                    break;
                }
                if (right <= char) stepsRight += 1;
            }

            // check top

            for (arr[0 .. outerIdx + 1]) |top| {
                if (top[idx] >= char) visibleTop = false;
            }
            i = outerIdx + 1;
            while (i > 0) : (i -= 1) {
                if (arr[0 .. outerIdx + 1][i - 1][idx] >= char) {
                    stepsTop += 1;
                    break;
                }
                if (arr[0 .. outerIdx + 1][i - 1][idx] <= char) stepsTop += 1;
            }

            // check bottom

            for (arr[outerIdx + 2 ..]) |bottom| {
                if (bottom[idx] >= char) {
                    visibleBottom = false;
                    stepsBottom += 1;
                    break;
                }
                if (bottom[idx] <= char) stepsBottom += 1;
            }

            if (visibleRight or visibleLeft or visibleTop or visibleBottom) {
                solution.visibleCount += 1;
                if (debug and visibleTop) std.debug.print("{c} is visible from Top at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleRight) std.debug.print("{c} is visible from Right at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleLeft) std.debug.print("{c} is visible from Left at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
                if (debug and visibleBottom) std.debug.print("{c} is visible from Bottom at [{d}:{d}]\n", .{ char, outerIdx + 1, idx });
            }
            const totalSteps = stepsLeft * stepsRight * stepsTop * stepsBottom;
            if (debug and visibleBottom) std.debug.print("{c} char has steps left = {d}, right = {d}, top = {d}, bottom = {d} total = {d}\n", .{ char, stepsLeft, stepsRight, stepsTop, stepsBottom, totalSteps });
            if (totalSteps > maxSteps) maxSteps = totalSteps;
        }
    }
    solution.scenic = maxSteps;
    return solution;
}

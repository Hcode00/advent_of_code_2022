const std = @import("std");
pub fn main() !void {
    const filename = "src/day2.txt";
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 15 * 1024);
    defer allocator.free(data);
    var arr = std.ArrayList([2]u8).init(std.heap.page_allocator);
    defer arr.deinit();
    var iterator = std.mem.split(u8, data, "\n");
    while (iterator.next()) |line| {
        if (line.len != 0) try arr.append([2]u8{ line[0], line[2] });
        // std.debug.print("line {s}\n", .{line});
    }
    std.debug.print("arr size {d}\n", .{arr.items.len});
    const total_case_1 = handleResults(arr.items);
    const total_case_2 = handleResults2(arr.items);
    std.debug.print("total score case 1 {d}\n", .{total_case_1});
    std.debug.print("total score case 2 {d}\n", .{total_case_2});
}

fn handleResults(arr: [][2]u8) i64 {
    var totalScore: i64 = 0;
    for (arr) |selections| {
        const mySelection = selections[1];
        const enemySelection = selections[0];
        var score: i64 = 0;
        switch (enemySelection) {
            'A' => { // rock
                switch (mySelection) {
                    'X' => { // Rock
                        score += 1;
                        score += 3;
                    },
                    'Y' => { // Paper
                        score += 2;
                        score += 6;
                    },
                    'Z' => { // Scissors
                        score += 3;
                    },
                    else => continue,
                }
            },
            'B' => { // Paper
                switch (mySelection) {
                    'X' => { // Rock
                        score += 1;
                    },
                    'Y' => { // Paper
                        score += 2;
                        score += 3;
                    },
                    'Z' => { // Scissors
                        score += 3;
                        score += 6;
                    },
                    else => continue,
                }
            },
            'C' => { // Scissors

                switch (mySelection) {
                    'X' => { // Rock
                        score += 1;
                        score += 6;
                    },
                    'Y' => { // Paper
                        score += 2;
                    },
                    'Z' => { // Scissors
                        score += 3;
                        score += 3;
                    },
                    else => continue,
                }
            },
            else => continue,
        }
        totalScore += score;
    }
    return totalScore;
}

fn handleResults2(arr: [][2]u8) i64 {
    var totalScore: i64 = 0;
    for (arr) |selections| {
        const mySelection = selections[1];
        const enemySelection = selections[0];
        var score: i64 = 0;
        switch (enemySelection) {
            'A' => { // rock
                switch (mySelection) {
                    'X' => { // lose
                        score += 3;
                    },
                    'Y' => { // tie
                        score += 1;
                        score += 3;
                    },
                    'Z' => { // win
                        score += 2;
                        score += 6;
                    },
                    else => continue,
                }
            },
            'B' => { // Paper
                switch (mySelection) {
                    'X' => { // lose
                        score += 1;
                    },
                    'Y' => { // tie
                        score += 2;
                        score += 3;
                    },
                    'Z' => { // win
                        score += 3;
                        score += 6;
                    },
                    else => continue,
                }
            },
            'C' => { // Scissors

                switch (mySelection) {
                    'X' => { // lose
                        score += 2;
                    },
                    'Y' => { // tie
                        score += 3;
                        score += 3;
                    },
                    'Z' => { // win
                        score += 1;
                        score += 6;
                    },
                    else => continue,
                }
            },
            else => continue,
        }
        totalScore += score;
    }
    return totalScore;
}

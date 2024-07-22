const std = @import("std");

pub fn main() !void {
    const sum = try handlePartTwo();
    std.debug.print("sum = {d}\n", .{sum});
}

fn handlePartTwo() !u32 {
    const fileName: []const u8 = "src/day3.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.split(u8, data, "\n");
    var arr = std.ArrayList([3][]const u8).init(std.heap.page_allocator);
    defer arr.deinit();
    var lines: [3][]const u8 = undefined;
    var i: usize = 0;
    while (it.next()) |line| {
        if (i == 3) {
            try arr.append(lines);
            i = 0;
        }
        lines[i] = line;
        i += 1;
    }
    return @as(u32, try getSum(arr.items));
}

fn getCommonLetter(lines: [3][]const u8) !u8 {
    var array = std.ArrayList(u8).init(std.heap.page_allocator);
    defer array.deinit();
    for (lines[0]) |letter_1| {
        for (lines[1]) |letter_2| {
            if (letter_1 == letter_2) try array.append(letter_2);
        }
    }
    for (array.items) |already_common| {
        for (lines[2]) |letter_3| {
            if (letter_3 == already_common) return already_common;
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
fn getSum(lines: [][3][]const u8) !u32 {
    var sum: u32 = 0;
    var i: usize = 1;
    for (lines) |line| {
        const common_letter = try getCommonLetter(line);
        i += 1;
        sum += @as(u32, try getValue(common_letter));
    }
    return sum;
}

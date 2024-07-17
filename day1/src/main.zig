const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    const fileName: []const u8 = "src/day1.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 10430);
    defer allocator.free(data);
    var it = std.mem.split(u8, data, "\n");
    var arena2 = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena2.deinit();
    const allocator2 = arena2.allocator();
    var arr = std.ArrayList(i64).init(allocator2);
    defer arr.deinit();
    var count: i64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            if (count != 0) {
                try arr.append(count);
                count = 0;
            }
        } else {
            count += try sum(line);
        }
    }
    print("number of groups = {d}\n", .{arr.items.len});
    print("most Calories = {d}\n", .{find_max(arr.items)});
}

fn sum(list: []const u8) !i64 {
    return try std.fmt.parseInt(i64, list, 10);
}
fn find_max(list: []i64) i64 {
    var max: i64 = 0;
    for (list) |num| {
        if (num > max) {
            max = num;
        }
    }
    return max;
}

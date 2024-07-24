const std = @import("std");
const t = @import("types.zig");

const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    const fileName: []const u8 = "src/day7.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var all = std.heap.GeneralPurposeAllocator(.{}){};
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
    const tree = try parseText(arr.items, allocator);
    // tree.printTree();
    std.debug.print("size = {d}\n", .{tree.Size()});

    std.debug.print("dir to delete has size = {d}\n", .{tree.findDirToDelete(70000000, 30000000)});
}

fn parseText(buffer: [][]const u8, allocator: std.mem.Allocator) !t.Dir {
    var root = t.Dir.init("/", null, allocator);
    var current = &root;
    for (buffer) |line| {
        switch (line[0]) {
            '$' => {
                if (line.len < 5) continue;
                switch (line[2]) {
                    'c' => {
                        switch (line[5]) {
                            '/' => current = &root,
                            '.' => current = current.parent.?,
                            else => {
                                const name = line[5..];
                                current = try current.FindDir(name);
                            },
                        }
                    },
                    else => continue,
                }
            },
            'd' => {
                const space_index = findCharIndex(line, ' ');
                const name = line[space_index + 1 ..];
                _ = try current.AddDir(name);
            },
            '1'...'9' => {
                const space_index = findCharIndex(line, ' ');
                const s = line[0..space_index];
                const name = line[space_index + 1 ..];
                try current.AddFile(name, try std.fmt.parseInt(u64, s, 10));
            },
            else => unreachable,
        }
    }
    return root;
}

fn findCharIndex(string: []const u8, letter: u8) usize {
    for (string, 0..) |char, i| {
        if (char == letter) return i;
    }
    unreachable;
}

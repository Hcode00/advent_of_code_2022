const std = @import("std");
const ls = @import("customLinkedList.zig");
const expect = std.testing.expect;

const markerMaxLen: usize = 4;
const messageMaxLen: usize = 14;

pub fn main() !void {
    const fileName: []const u8 = "src/day6.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    const buffer = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(buffer);

    const markerIndex = try getIndex(buffer, markerMaxLen);
    std.debug.print("marker index = {d}\n", .{markerIndex});
    const messageIndex = try getIndex(buffer, messageMaxLen);
    std.debug.print("message index = {d}\n", .{messageIndex});
}

const ListError = error{ NotFound, OutOfMemory };

fn getIndex(buffer: []u8, comptime maxLen: usize) ListError!usize {
    var list = ls.LinkedList(u8, maxLen).init();
    defer list.deinit();
    for (buffer, 0..) |letter, idx| {
        try list.append(letter);
        if (idx < maxLen) continue;
        if (!list.hasRepeatedValues()) {
            return idx + 1;
        }
    }
    return ListError.NotFound;
}

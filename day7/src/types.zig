const std = @import("std");
const testing = std.testing;

pub const File = struct {
    name: []const u8,
    size: u64,
    parent: ?*Dir = null,
};

pub const Dir = struct {
    name: []const u8,
    content: std.ArrayList(Children),
    parent: ?*Dir = null,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(name: []const u8, parent: ?*Dir, allocator: std.mem.Allocator) Self {
        return Self{
            .parent = parent,
            .name = name,
            .allocator = allocator,
            .content = std.ArrayList(Children).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.content.deinit();
    }

    pub fn printTree(self: *const Self) void {
        self.printTreeHelper(0);
    }
    fn printTreeHelper(self: *const Self, depth: usize) void {
        const indent = "  "; // Two spaces for each indent level

        // Print current directory
        for (0..depth) |_| {
            std.debug.print("{s}", .{indent});
        }
        std.debug.print("- {s} (dir)\n", .{self.name});

        // Print contents
        for (self.content.items) |child| {
            switch (child) {
                .Dir => |dir| dir.printTreeHelper(depth + 1),
                .File => |file| {
                    for (0..depth + 1) |_| {
                        std.debug.print("{s}", .{indent});
                    }
                    std.debug.print("- {s} (file, size={d})\n", .{ file.name, file.size });
                },
            }
        }
    }
    pub fn Size(self: *const Self) u64 {
        var sum: u64 = 0;
        for (self.content.items) |child| {
            switch (child) {
                .Dir => |dir| sum += dir.Size(),
                .File => |file| sum += file.size,
            }
        }
        return sum;
    }

    pub fn SumDirsUpTo(self: *const Self, limit: u64) u64 {
        var sum: u64 = 0;
        const dirSize = self.Size();

        if (dirSize <= limit) {
            sum += dirSize;
        }

        for (self.content.items) |child| {
            if (child == .Dir) {
                sum += child.Dir.SumDirsUpTo(limit);
            }
        }
        return sum;
    }

    pub fn AddFile(self: *Self, name: []const u8, size: u64) !void {
        try self.content.append(.{ .File = .{
            .name = name,
            .size = size,
            .parent = self,
        } });
    }

    pub fn AddDir(self: *Self, name: []const u8) !void {
        const newDir = try self.allocator.create(Dir);
        newDir.* = Dir.init(name, self, self.allocator);
        try self.content.append(.{ .Dir = newDir });
    }

    pub fn ParentDir(self: *Self) ?*Dir {
        return self.parent;
    }

    const DirError = error{NotFound};

    pub fn FindDir(self: *Self, dirName: []const u8) DirError!*Dir {
        for (self.content.items) |child| {
            switch (child) {
                .File => continue,
                .Dir => |dir| {
                    if (std.mem.eql(u8, dir.*.name, dirName)) {
                        return dir;
                    }
                },
            }
        }
        return DirError.NotFound;
    }
};

pub const Children = union(enum) {
    File: File,
    Dir: *Dir,
};

test "File system with dynamic content addition" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var root = Dir.init("root", null, allocator);
    defer root.deinit();

    // Add files to root
    try root.AddFile("root_file1.txt", 100);
    try root.AddFile("root_file2.txt", 200);

    // Add a subdirectory
    try root.AddDir("home");
    var home_dir = try root.FindDir("home");

    // Add files to home directory
    try home_dir.AddFile("home_file1.txt", 150);
    try home_dir.AddFile("home_file2.txt", 250);

    // Add another level of subdirectory
    try home_dir.AddDir("documents");
    var documents_dir = try home_dir.FindDir("documents");
    try documents_dir.AddFile("doc1.txt", 50);

    // Test sizes
    try testing.expectEqual(@as(u64, 750), root.Size());
    try testing.expectEqual(@as(u64, 450), home_dir.Size());
    try testing.expectEqual(@as(u64, 50), documents_dir.Size());

    // Test structure
    try testing.expectEqual(@as(usize, 3), root.content.items.len);
    try testing.expectEqual(@as(usize, 3), home_dir.content.items.len);
    try testing.expectEqual(@as(usize, 1), documents_dir.content.items.len);

    // Test names
    try testing.expectEqualStrings("root", root.name);
    try testing.expectEqualStrings("home", home_dir.name);
    try testing.expectEqualStrings("documents", documents_dir.name);

    // Test file names and sizes
    try testing.expectEqualStrings("root_file1.txt", root.content.items[0].File.name);
    try testing.expectEqual(@as(u64, 100), root.content.items[0].File.size);
    try testing.expectEqualStrings("home_file1.txt", home_dir.content.items[0].File.name);
    try testing.expectEqual(@as(u64, 150), home_dir.content.items[0].File.size);

    // Test parent relationships
    try testing.expect(home_dir.parent == &root);
    try testing.expect(documents_dir.parent == home_dir);
    try testing.expect(root.parent == null);
}

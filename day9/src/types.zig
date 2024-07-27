const std = @import("std");
const testing = std.testing;

pub const Point = struct {
    x: i32 = 0,
    y: i32 = 0,
    const Self = @This();
    pub fn eql(self: Self, other: Point) bool {
        return (self.x == other.x and self.y == other.y);
    }
};

pub const Direction = enum(u8) {
    UP = 'U',
    RIGHT = 'R',
    DOWN = 'D',
    LEFT = 'L',
    pub fn toDir(char: u8) Direction {
        return switch (char) {
            'U' => Direction.UP,
            'R' => Direction.RIGHT,
            'D' => Direction.DOWN,
            'L' => Direction.LEFT,
            else => unreachable,
        };
    }
    pub fn name(self: Direction) []const u8 {
        return switch (self) {
            .UP => "UP",
            .RIGHT => "RIGHT",
            .DOWN => "DOWN",
            .LEFT => "LEFT",
        };
    }
};

pub fn Vector() type {
    return struct {
        knots: [10]Point = [_]Point{Point{ .x = 0, .y = 0 }} ** 10,
        visited: std.AutoHashMap(Point, void),
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            var self = Self{
                .visited = std.AutoHashMap(Point, void).init(allocator),
            };
            self.markVisited(); // Mark the starting point
            return self;
        }

        pub fn deinit(self: *Self) void {
            self.visited.deinit();
        }

        pub fn visitedCount(self: *Self) usize {
            return self.visited.count();
        }

        fn markVisited(self: *Self) void {
            self.visited.put(self.knots[9], {}) catch unreachable;
        }

        pub fn moveHead(self: *Self, direction: Direction, magnitude: u8) void {
            for (0..@as(usize, @intCast(magnitude))) |_| {
                switch (direction) {
                    .LEFT => self.knots[0].x -= 1,
                    .RIGHT => self.knots[0].x += 1,
                    .UP => self.knots[0].y += 1,
                    .DOWN => self.knots[0].y -= 1,
                }

                for (1..self.knots.len) |i| {
                    self.moveKnot(i);
                }

                self.markVisited();
            }
        }

        fn moveKnot(self: *Self, index: usize) void {
            const prev = self.knots[index - 1];
            var curr = &self.knots[index];

            const dx = prev.x - curr.x;
            const dy = prev.y - curr.y;

            if (@abs(dx) > 1 or @abs(dy) > 1) {
                curr.x += std.math.sign(dx);
                curr.y += std.math.sign(dy);
            }
        }

        pub fn printVisited(self: *Self) void {
            std.debug.print("Visited positions:\n", .{});
            var it = self.visited.keyIterator();
            while (it.next()) |point| {
                std.debug.print("({d}, {d})\n", .{ point.x, point.y });
            }
        }
    };
}

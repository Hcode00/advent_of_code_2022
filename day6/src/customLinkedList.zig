const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
pub fn LinkedList(comptime T: type, comptime maxLen: usize) type {
    return struct {
        const Self = @This();
        const Node = struct {
            prev: ?*Node = null,
            next: ?*Node = null,
            data: T,
        };
        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
        maxLen: usize = maxLen,

        pub fn init() Self {
            return Self{};
        }

        pub fn popFirstElem(self: *Self) ?T {
            if (self.head) |head| {
                const data = head.data;
                if (self.len == 1) {
                    self.head = null;
                    self.tail = null;
                } else {
                    self.head = head.next;
                    if (self.head) |newHead| {
                        newHead.prev = null;
                    }
                }
                self.len -= 1;
                return data;
            }
            return null;
        }

        pub fn append(self: *Self, data: T) !void {
            var node = try std.heap.page_allocator.create(Node);
            node.* = Node{ .data = data };

            if (self.len == self.maxLen) {
                _ = self.popFirstElem();
            }

            if (self.tail) |tail| {
                tail.next = node;
                node.prev = tail;
                self.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }
            self.len += 1;
        }

        pub fn hasRepeatedValues(self: *Self) bool {
            if (self.len <= 1) return false;

            var current = self.head;
            var i: usize = 0;
            while (current) |node| : (current = node.next) {
                var check = node.next;
                var j: usize = i + 1;
                while (check) |checkNode| : (check = checkNode.next) {
                    if (std.meta.eql(node.data, checkNode.data)) {
                        return true;
                    }
                    j += 1;
                    if (j >= self.maxLen) break;
                }
                i += 1;
                if (i >= self.maxLen - 1) break;
            }

            return false;
        }

        pub fn deinit(self: *Self) void {
            while (self.popFirstElem()) |_| {}
        }
    };
}

test "LinkedList basic operations" {
    var list = LinkedList(i32, 4).init();
    defer list.deinit();

    try list.append(1);
    try list.append(2);
    try list.append(3);

    try expect(list.len == 3);
    try expect(list.head.?.data == 1);
    try expect(list.tail.?.data == 3);

    const popped = list.popFirstElem();

    try expect(popped.? == 1);
    try expect(list.len == 2);
    try expect(list.head.?.data == 2);
}

test "LinkedList max length" {
    var list = LinkedList(i32, 4).init();
    defer list.deinit();

    try list.append(1);
    try list.append(2);
    try list.append(3);
    try list.append(4);
    try list.append(5);

    try expect(list.len == 4);
    try expect(list.head.?.data == 2);
    try expect(list.tail.?.data == 5);
}

test "LinkedList empty operations" {
    var list = LinkedList(i32, 14).init();
    defer list.deinit();

    const popped_empty = list.popFirstElem();

    try expect(popped_empty == null);
    try expect(list.len == 0);

    try list.append(1);

    const popped = list.popFirstElem();

    try expect(list.len == 0);
    try expect(popped.? == 1);
}

test "LinkedList check for repeated values" {
    var list = LinkedList(i32, 4).init();
    defer list.deinit();

    try list.append(1);
    try list.append(2);
    try list.append(3);
    try list.append(4);

    var hasRepeats = list.hasRepeatedValues();
    try expect(hasRepeats == false);

    try list.append(2); // This should replace the first element (1) with 2

    hasRepeats = list.hasRepeatedValues();
    try expect(hasRepeats == true);
}

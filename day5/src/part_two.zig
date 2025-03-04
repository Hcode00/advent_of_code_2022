const std = @import("std");

const print = std.debug.print;
const expect = std.testing.expect;

const num_of_stacks = 9;
pub fn main() !void {
    const fileName: []const u8 = "src/day5.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = try file.readToEndAlloc(allocator, 1024 * 20);
    defer allocator.free(data);
    var it = std.mem.split(u8, data, "\n");
    var instructions = std.ArrayList([]const u8).init(std.heap.page_allocator);
    const Stacks = [num_of_stacks]std.ArrayList(u8);
    var stacks: Stacks = undefined;
    for (0..num_of_stacks) |i| {
        stacks[i] = std.ArrayList(u8).init(allocator);
    }
    defer instructions.deinit();
    var stage: u1 = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        switch (stage) {
            0 => {
                for (line, 0..) |char, idx| {
                    switch (char) {
                        'A'...'Z' => {
                            const x = getIndex(idx);
                            try stacks[x].append(char);
                        },
                        ' ', '[', ']' => continue,
                        'm', '1' => {
                            stage = 1;
                            break;
                        },
                        else => {
                            print("char: {c}\n", .{char});
                            unreachable;
                        },
                    }
                }
            },
            1 => {
                if (line[0] == 'm') try instructions.append(line);
            },
        }
    }
    try executeInstructions(instructions.items, &stacks);
}

const Instruction = struct {
    count: u8,
    from: u8,
    to: u8,
};

fn executeInstructions(ins: [][]const u8, stacks: *[num_of_stacks]std.ArrayList(u8)) !void {
    for (ins) |i| {
        const s = parseInstruction(i);
        const from = &stacks.*[s.from - 1];
        const to = &stacks.*[s.to - 1];

        const move_count = @min(s.count, from.items.len);

        try to.insertSlice(0, from.items[0..move_count]);

        try from.replaceRange(0, move_count, &[_]u8{});
    }

    for (stacks.*) |stack| {
        if (stack.items.len > 0) {
            std.debug.print("{c}", .{stack.items[0]});
        }
    }
    print("\n", .{});
}

fn parseInstruction(instruction: []const u8) Instruction {
    var count: u8 = 0;
    var from: u8 = 0;
    var to: u8 = 0;
    for (instruction, 0..) |char, idx| {
        switch (char) {
            'v' => {
                count = instruction[idx + 3] - 48;
                if (instruction[idx + 4] != ' ') assignOrModify(&count, instruction[idx + 4]);
            },
            'f' => {
                from = instruction[idx + 5] - 48;
                if (instruction[idx + 6] != ' ') assignOrModify(&from, instruction[idx + 6]);
            },
            't' => {
                to = instruction[idx + 3] - 48;
                if (instruction.len == idx + 4) break;
                if (instruction[idx + 4] != ' ') assignOrModify(&to, instruction[idx + 4]);
            },
            else => continue,
        }
    }
    return Instruction{ .from = from, .to = to, .count = count };
}

fn assignOrModify(numPtr: *u8, value: u8) void {
    if (numPtr.* == 0) numPtr.* = value - 48 else numPtr.* = (numPtr.*) * 10 + value - 48;
}

fn getIndex(idx: usize) usize {
    var e: usize = 1;
    return switch (idx) {
        1 => 0,
        else => {
            while (true) : (e += 1) {
                if (idx - e * 4 == 1) return e;
            }
        },
    };
}

test "simple test" {
    try expect(getIndex(5) == 1);
    try expect(getIndex(9) == 2);
    try expect(getIndex(13) == 3);
    try expect(getIndex(17) == 4);
}

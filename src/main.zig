const std = @import("std");
const print = @import("std").debug.print;

pub fn encrypt(file_name: []const u8, table: [256]u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const data = try std.fs.cwd().readFileAlloc(gpa.allocator(), file_name, 1_000_000_000);

    for (data, 0..) |_, index| {
        data[index] = table[data[index]];
    }

    try std.fs.cwd().writeFile(file_name, data);

    return data.len;
}

pub fn generate_table(seed: u64, reverse: bool) [256]u8 {
    var bytes: [256]u8 = undefined;
    for (bytes, 0..) |_, index| {
        bytes[index] = @intCast(index);
    }

    var rng = std.rand.DefaultPrng.init(seed);

    for (bytes, 0..) |_, index| {
        const temp: u8 = bytes[index];
        const rand_index: u8 = @intCast(rng.next() % 256);
        bytes[index] = bytes[rand_index];
        bytes[rand_index] = temp;
    }

    if (reverse) {
        var reverse_table: [256]u8 = undefined;

        for (bytes, 0..) |_, index| {
            reverse_table[bytes[index]] = @intCast(index);
        }
        return reverse_table;
    }
    return bytes;
}

pub fn print_time_stamp() void {
    const OFFSET: u64 = 3600;
    const time: u64 = @intCast(std.time.timestamp());
    const total_sec = time % 86_400 + OFFSET;
    const hours = total_sec / 3600;
    const minutes = total_sec % 3600 / 60;
    const seconds = total_sec % 3600 % 60;
    print("[{}:{}:{}] ", .{ hours, minutes, seconds });
}

const COLOR = struct {
    const BLACK = "\x1B[30m";
    const RED = "\x1B[31m";
    const GREEN = "\x1B[32m";
    const YELLOW = "\x1B[33m";
    const BLUE = "\x1B[34m";
    const MAGENTA = "\x1B[35m";
    const BLUECYAN = "\x1B[36m";
    const WHITE = "\x1B[37m";
    const RESET = "\x1B[39m";
};

pub fn print_stats(file_size: u64, elapsed_ms: u64, decrypting: bool) void {
    print_time_stamp();

    if (decrypting) {
        print("{s}Decrypted ", .{COLOR.GREEN});
    } else {
        print("{s}Encrypted ", .{COLOR.GREEN});
    }

    if (file_size >= 1_000_000_000) {
        print("{s}{} GB{s} ", .{ COLOR.MAGENTA, file_size / 1_000_000_000, COLOR.RESET });
    } else if (file_size >= 1_000_000) {
        print("{s}{} MB{s} ", .{ COLOR.MAGENTA, file_size / 1_000_000, COLOR.RESET });
    } else if (file_size >= 1_000) {
        print("{s}{} KB{s} ", .{ COLOR.MAGENTA, file_size / 1_000, COLOR.RESET });
    } else {
        print("{s}{} B{s} ", .{ COLOR.MAGENTA, file_size, COLOR.RESET });
    }

    const secs = elapsed_ms / 1000;
    const millis = elapsed_ms - secs * 1000;
    print("{s}in {s}{}.{} s{s} ", .{ COLOR.GREEN, COLOR.BLUE, secs, millis, COLOR.RESET });

    const speed: u64 = file_size / elapsed_ms / 1000;
    print("({s}{} MB/s{s})\n", .{ COLOR.BLUECYAN, speed, COLOR.RESET });
}

pub fn get_str_len(str: [*:0]u8) u32 {
    var i: u32 = 0;
    while (str[i] != 0) {
        i += 1;
    }
    return i;
}

pub fn main() !void {
    if (std.os.argv.len < 4) {
        print("{s}Not enough arguments!{s}\nUsage: <executable> <filename> <mode (E/d)> <key>", .{ COLOR.RED, COLOR.RESET });
        return;
    }

    var file_name: []u8 = undefined;
    var decrypting: bool = false;
    var seed: u64 = 10;

    for (std.os.argv, 0..) |arg, arg_index| {
        switch (arg_index) {
            1 => {
                const len: u8 = @intCast(get_str_len(arg));
                file_name = arg[0..len];
            },
            2 => {
                if (arg[0] == 'd') {
                    decrypting = true;
                }
            },
            3 => {
                const len: u8 = @intCast(get_str_len(arg));
                const str_seed: []const u8 = arg[0..len];
                seed = try std.fmt.parseInt(u64, str_seed, 10);
            },
            else => {},
        }
    }

    print("\n", .{});
    if (decrypting) {
        print_time_stamp();
        print("{s}Decrypting...{s}\n", .{ COLOR.MAGENTA, COLOR.RESET });
    } else {
        print_time_stamp();
        print("{s}Encrypting...{s}\n", .{ COLOR.YELLOW, COLOR.RESET });
    }

    const time_start_ms: i64 = @intCast(std.time.milliTimestamp());

    const table: [256]u8 = generate_table(seed, decrypting);

    const file_size: u64 = try encrypt(file_name, table);

    const elapsed_ms: u64 = @intCast(std.time.milliTimestamp() - time_start_ms);

    print_stats(file_size, elapsed_ms, decrypting);

    print("\n", .{});
}

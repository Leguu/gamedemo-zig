const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.Core.new(
        .{
            .title = "GameDemo",
            .size = .{.x = 1000, .y = 800},
            .flags = &.{.resizable},
        },
    );
    defer core.cleanup();

    var timer = try lsdl.Timer.new();

    var player = @import("Player.zig").new(core.render);
    defer player.deinit();

    const font = lsdl.Font.new("res/OpenSans-Regular.ttf", 34);
    const small_font = lsdl.Font.new("res/OpenSans-Regular.ttf", 12);

    var boxes = [_]lsdl.Bounding.Box{.{.pos = .{ .x = 300, .y = 300 }, .size = .{ .x = 160, .y = 160 }}};
    var other_bounding = lsdl.Bounding.new(.{.x=0, .y=0}, &boxes);

    var text = [_]u8{0} ** 1000;

    var running = true;
    while (running) {
        while (lsdl.input.poll()) |event| {
            if (event.type == lsdl.events.QUIT or event.button.button == lsdl.scancode.Q) {
                running = false;
            }
        }

        player.update(core.window.size().lossyCast(f32));

        while (timer.doFrame()) {
            core.render.clear(lsdl.Color.uniform(200));

            if (lsdl.input.keyboardPressed(lsdl.scancode.W) or
                lsdl.input.keyboardPressed(lsdl.scancode.A) or
                lsdl.input.keyboardPressed(lsdl.scancode.S) or
                lsdl.input.keyboardPressed(lsdl.scancode.D))
            {
                try player.draw(&core.render, timer);
            } else {
                try player.drawIdle(&core.render, timer);
            }

            other_bounding.draw(&core.render);
            if (player.bnd.colliding(other_bounding)) {
                font.draw(core.render, .{ .x = 20, .y = 20 }, "Collision detected!");
            } else {
                font.draw(core.render, .{ .x = 20, .y = 20 }, "No collisions!");
            }
            _ = try std.fmt.bufPrint(&text, "{}", .{player.bnd.boxes[0]});
            small_font.draw(core.render, .{ .x = 20, .y = 300 }, &text);

            core.render.present();
        }

        timer.tick();
        timer.wait();
    }
}

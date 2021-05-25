const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.Core.new(lsdl.Size.new(1000, 800));
    defer core.cleanup();

    var timer = try lsdl.Timer.new();

    var player = @import("Player.zig").new(core.render);

    const font = lsdl.Font.new("res/OpenSans-Regular.ttf", 12);

    var other_bounding = lsdl.Bounding.new(&[_]lsdl.Bounding.Box{lsdl.Bounding.Box.new(lsdl.Size.new(300, 300), lsdl.Size.new(32, 32))});

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

            font.draw(core.render, .{.x = 20, .y = 20}, "Hello, world!");

            if (lsdl.input.keyboardPressed(lsdl.scancode.W) or
                lsdl.input.keyboardPressed(lsdl.scancode.A) or
                lsdl.input.keyboardPressed(lsdl.scancode.S) or
                lsdl.input.keyboardPressed(lsdl.scancode.D))
            {
                try player.draw(&core.render, timer);
            } else {
                try player.drawIdle(&core.render);
            }

            other_bounding.draw(&core.render, lsdl.Vector(i32).zero());
            // if (player.bounding.colliding(other_bounding)) {
            //     std.debug.print("Collision detected!\n", .{});
            // } else {
            //     std.debug.print("NOT\n", .{});
            // }

            core.render.present();
        }

        timer.tick();
        timer.wait();
    }
}

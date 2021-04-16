const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.Core.new(lsdl.Size.new(1000, 800));
    defer core.cleanup();

    var timer = try lsdl.Timer.new();

    const lettuce = lsdl.Image.load(core.render, "res/lettuce.png");

    const human = lsdl.Spritesheet.new(
        lsdl.Image.loadScale(core.render, "res/armorleft.png", 5),
        .{ .y = 32, .x = 32 },
    );
    var human_anim = lsdl.Animation.new(human, 120 * std.time.ns_per_ms);

    var pos = lsdl.Vector(f32).zero();
    var running = true;
    while (running) {
        while (lsdl.input.poll()) |event| {
            if (event.type == lsdl.events.QUIT or event.button.button == lsdl.scancode.Q) {
                running = false;
            }

            // if (event.button.button == lsdl.scancode.SPACE) x = 0;
        }

        const speed = 0.2;
        if (lsdl.input.keyboardPressed(lsdl.scancode.W)) pos.y -= speed;
        if (lsdl.input.keyboardPressed(lsdl.scancode.A)) pos.x -= speed;
        if (lsdl.input.keyboardPressed(lsdl.scancode.S)) pos.y += speed;
        if (lsdl.input.keyboardPressed(lsdl.scancode.D)) pos.x += speed;

        const window_size = core.window.size().lossyCast(f32);
        const sprite_size = human.size();
        pos.y = lsdl.bound(pos.y, 0, window_size.y - sprite_size.y);
        pos.x = lsdl.bound(pos.x, 0, window_size.x - sprite_size.x);

        while (timer.doFrame()) {
            core.render.clear(lsdl.Color.uniform(200));

            // x += 1;
            // y += 0.2;
            // if (y > @intToFloat(f32, human.length)) y = 0;

            try human_anim.drawFrame(core.render, pos, timer.deltaTime());

            // lettuce.draw(core.render, lsdl.Vector(f32).new(x, 0));
            // try human.draw(core.render, lsdl.Vector(f32).new(x, 200), @floatToInt(i32, y));

            core.render.present();
        }

        timer.tick();
        timer.wait();
    }
}

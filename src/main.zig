const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.Core.new(lsdl.Size.new(1000, 800));
    defer core.cleanup();

    var timer = try lsdl.Timer.new();

    const lettuce = lsdl.Image.load(core.render, "res/lettuce.png");
    const human = lsdl.Spritesheet.new(
        lsdl.Image.loadScale(core.render, "res/human_base.png", 5),
        .{ .y = 18, .x = 16 },
    );

    var x: f32 = 0;
    var y: usize = 0;
    var running = true;
    while (running) {
        while (lsdl.input.poll()) |event| {
            if (event.type == lsdl.events.QUIT or event.button.button == lsdl.scancode.Q) {
                running = false;
            }

            if (event.button.button == lsdl.scancode.SPACE) x = 0;
        }

        if (timer.doFrame()) {
            core.render.clear(lsdl.Color.uniform(20));

            x += 1;
            y += 1;
            if (y > human.length) y = 0;

            lettuce.drawScale(core.render, lsdl.Vector(f32).new(x, 0));
            try human.draw(core.render, lsdl.Vector(f32).new(x, 200), y);

            core.render.present();
        }

        timer.tick();
        timer.wait();
    }
}

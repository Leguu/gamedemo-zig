const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.Core.new(1000, 800);
    defer core.cleanup();

    var timer_sixty = try lsdl.Timer.new();
    var timer_hundred = try lsdl.Timer.new();

    const lettuce = lsdl.Image.load(core.render, "res/lettuce.png");

    var x: f32 = 0;
    var running = true;
    while (running) {
        while (lsdl.input.poll()) |event| {
            if (event.type == lsdl.events.QUIT or event.button.button == lsdl.scancode.Q) {
                running = false;
            }
        }

        if (timer_hundred.doFrame(100)) {
            const dt = 10 * timer_hundred.deltaTime(f32) / std.time.ns_per_s;
            timer_hundred.tick();
        }

        if (timer_sixty.doFrame(60)) {
            core.render.clear(lsdl.Color.gray(20));

            x += 1;

            lettuce.drawScale(core.render, lsdl.Vector(f32).new(x, 0), 0.5);

            core.render.present();

            timer_sixty.tick();
        }
    }
}

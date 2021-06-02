const std = @import("std");
const lsdl = @import("lsdl");

const Self = @This();
const speed = 0.2;

bnd: lsdl.Bounding,

animation: lsdl.Animation,

facing: lsdl.SDL_RendererFlip = .SDL_FLIP_NONE,

pub fn new(render: lsdl.Render) Self {
    const human = lsdl.Spritesheet.new(
        lsdl.Image.loadScale(render, "res/armorleft.png", 5),
        .{ .y = 32, .x = 32 },
    );
    const box = lsdl.Bounding.Box.new(lsdl.Vector(f32).zero(), human.size());
    const bnd = lsdl.Bounding.new(&[_]lsdl.Bounding.Box{box});
    return Self{
        .animation = lsdl.Animation.new(human, 120 * std.time.ns_per_ms),
        .bnd = bnd,
    };
}

pub fn update(self: *Self, window_size: lsdl.Vector(f32)) void {
    if (lsdl.input.keyboardPressed(lsdl.scancode.W)) self.bnd.pos.y -= speed;
    if (lsdl.input.keyboardPressed(lsdl.scancode.A)) {
        self.bnd.pos.x -= speed;
        self.facing = .SDL_FLIP_NONE;
    }
    if (lsdl.input.keyboardPressed(lsdl.scancode.S)) self.bnd.pos.y += speed;
    if (lsdl.input.keyboardPressed(lsdl.scancode.D)) {
        self.bnd.pos.x += speed;
        self.facing = .SDL_FLIP_HORIZONTAL;
    }

    const sprite_size = self.animation.spritesheet.size();
    self.bnd.pos.y = lsdl.bound(self.bnd.pos.y, 0, window_size.y - sprite_size.y);
    self.bnd.pos.x = lsdl.bound(self.bnd.pos.x, 0, window_size.x - sprite_size.x);
}

pub fn draw(self: *Self, render: *lsdl.Render, timer: lsdl.Timer) !void {
    try self.animation.drawFrame(render.*, self.bnd.pos, timer.deltaTime(), .{ .flip = self.facing });
    self.bnd.draw(render, self.bnd.pos.lossyCast(i32));
}

pub fn drawIdle(self: *Self, render: *lsdl.Render) !void {
    self.animation.index = 0;
    try self.animation.spritesheet.draw(render.*, self.bnd.pos, 0, .{ .flip = self.facing });
    self.bnd.draw(render, self.bnd.pos.lossyCast(i32));
}

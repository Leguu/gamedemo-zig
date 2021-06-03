const std = @import("std");
const lsdl = @import("lsdl");

const Self = @This();
const speed = 0.2;

bnd: lsdl.Bounding,
animation: lsdl.Animation,
idle_animation: lsdl.Animation,
facing: lsdl.SDL_RendererFlip = .SDL_FLIP_NONE,

pub fn new(render: lsdl.Render) Self {
    const walking_sheet = lsdl.Spritesheet.new(
        lsdl.Image.loadScale(render, "res/armorleft.png", 5),
        .{ .y = 32, .x = 32 },
    );
    const idle_sheet = lsdl.Spritesheet.new(
        lsdl.Image.loadScale(render, "res/armoridle.png", 5),
        .{ .y = 32, .x = 32 },
    );
    var boxes = std.heap.page_allocator.create([1]lsdl.Bounding.Box) catch unreachable;
    boxes[0] = .{ .pos = lsdl.Vector(f32).zero(), .size = walking_sheet.size() };
    return Self{
        .animation = lsdl.Animation.new(walking_sheet, 120),
        .idle_animation = lsdl.Animation.new(idle_sheet, 700),
        .bnd = lsdl.Bounding.new(.{ .x = 33, .y = 33 }, boxes),
    };
}

pub fn deinit(self: *Self) void {
    std.heap.page_allocator.destroy(self.bnd.boxes.ptr);
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
    self.bnd.draw(render);
}

pub fn drawIdle(self: *Self, render: *lsdl.Render, timer: lsdl.Timer) !void {
    self.animation.index = 0;
    try self.idle_animation.drawFrame(render.*, self.bnd.pos, timer.deltaTime(), .{ .flip = self.facing });
    self.bnd.draw(render);
}

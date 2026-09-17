const std = @import("std");
const Io = std.Io;
const rl = @import("raylib");
const rg = @import("raygui");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct { screenWidth: i32, screenHeight: i32, playerWidth: f32, playerHeight: f32, playerStartY: f32, bulletWidth: f32, bulletHeight: f32, shieldStartX: f32, shieldY: f32, shieldWidth: f32, shieldHeight: f32, shieldSpacing: f32, invaderStartX: f32, invaderStartY: f32, invaderWidth: f32, invaderHeight: f32, invaderSpacingX: f32, invaderSpacingY: f32 };

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Greeting");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        rl.drawText("Hello, World!", screenWidth / 3, screenHeight / 2, 20, .green);
    }
}

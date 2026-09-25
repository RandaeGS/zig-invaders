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

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
};

const Player = struct {
    positionX: f32,
    positionY: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.positionX += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.positionX -= self.speed;
        }

        if (self.positionX < 0) {
            self.positionX = 0;
        }

        if (self.positionX + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.positionX = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.positionX),
            @intFromFloat(self.positionY),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.green,
        );
    }
};

const Bullet = struct {
    positionX: f32,
    positionY: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.positionY -= self.speed;
            if (self.positionY < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.positionX),
                @intFromFloat(self.positionY),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.yellow,
            );
        }
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bulletWidth, bulletHeight);
    }

    rl.initWindow(screenWidth, screenHeight, "Greeting");
    defer rl.closeWindow();

    const playerWidth = 50.0;
    const playerHeight = 30.0;

    var player = Player.init(
        @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth / 2,
        @as(f32, @floatFromInt(screenHeight)) - 60.0,
        playerWidth,
        playerHeight,
    );

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);
        player.update();

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                bullet.positionX = player.positionX + player.width / 2 - bullet.width / 2;
                bullet.positionY = player.positionY;
                bullet.active = true;
                break;
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }
        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }

        rl.drawText("Hello, World!", screenWidth / 3, screenHeight / 2, 20, .green);
    }
}

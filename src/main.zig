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

const Invader = struct {
    positionX: f32,
    positionY: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
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
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.positionX),
                @intFromFloat(self.positionY),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.positionX += dx;
        self.positionY += dy;
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

    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;
    const invaderSpeed = 5.0;
    const invaderMoveDelay = 30;
    const invaderDropDistance = 5.0;
    var invaderDirection: f32 = 1.0;
    var moveTimer: i32 = 0;

    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bulletWidth, bulletHeight);
    }

    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(x, y, invaderWidth, invaderHeight);
        }
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
                if (!bullet.active) {
                    bullet.positionX = player.positionX + player.width / 2 - bullet.width / 2;
                    bullet.positionY = player.positionY;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        moveTimer += 1;
        if (moveTimer >= invaderMoveDelay) {
            moveTimer = 0;

            var hitEdge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const nextX = invader.positionX + (invader.speed * invaderDirection);
                        if (nextX < 0 or nextX + invader.width > @as(f32, @floatFromInt(screenWidth))) {
                            hitEdge = true;
                            break;
                        }
                    }
                }
                if (hitEdge) break;
            }

            if (hitEdge) {
                invaderDirection *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invaderDropDistance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invaderSpeed * invaderDirection, 0);
                    }
                }
            }
        }

        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }
    }
}

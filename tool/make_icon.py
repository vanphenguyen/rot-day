"""Draws the app icon and the launch screen picture: a glass of iced milk tea
with tapioca pearls and a straw, filled to the dashed line.

Run from the project root with the bundled Python:
    python tool/make_icon.py
Then regenerate the platform icons:
    dart run flutter_launcher_icons

Writing the pictures as code keeps them in the repository and lets the
colours be changed in one place, instead of carrying binaries nobody can
edit. The launch images are written straight into the android and ios
folders, because flutter_launcher_icons does not make those.

The glass is drawn the same way as on the pour screen
(lib/widgets/glass_painter.dart): clear walls with some thickness, a solid
foot, the rim and the surfaces seen as ovals from a little above, and light
catching the left side.
"""

from __future__ import annotations

import math
import pathlib
import random

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icon"

SIZE = 1024
# Everything is drawn this many times too big, then shrunk, for smooth edges.
SUPER = 3

# Background: warm amber, lighter behind the glass (lib/style/palette.dart).
BG_CENTRE = (255, 204, 92)
BG_MID = (240, 156, 24)
BG_EDGE = (184, 96, 0)

# The drink is milk tea, not beer. An amber drink under a white head reads
# as beer and would push the age rating up, so the drink is an opaque
# caramel brown, with dark tapioca pearls at the bottom and a wide straw.
# Keep all three.
MILK = (201, 146, 104)
MILK_DEEP = (132, 84, 54)
MILK_LIGHT = (228, 188, 150)
FOAM = (255, 247, 232)
FOAM_SHADE = (224, 192, 156)
PEARL = (50, 26, 16)
STRAW = (36, 152, 138)
STRAW_DARK = (20, 94, 85)
STRAW_LIGHT = (160, 228, 216)
LINE = (232, 58, 58)
SHADOW = (104, 48, 0)
WHITE = (255, 255, 255)

# The glass, in a 1024-wide design space. The shape is the game's "flared"
# glass (lib/game/glass_shape.dart).
CX = 512
RIM_Y = 205
FLOOR_Y = 790
HALF = 226
TILT = 0.15
WALL = 9
FOOT_Y = FLOOR_Y + 46
LIQUID = 0.62
FOAM_TOP = 0.75
STRAW_TO = (706, 64)
STRAW_ANGLE = math.radians(23)  # from upright, leaning right
STRAW_W = 54


def width_at(h: float) -> float:
    return 0.62 + 0.38 * h


def rx(h: float) -> float:
    return width_at(h) * HALF


def gy(h: float) -> float:
    return FLOOR_Y - (FLOOR_Y - RIM_Y) * h


def oval_points(h, a0, a1, grow=0.0, y=None, steps=96):
    cy = gy(h) if y is None else y
    r = rx(h) + grow
    return [
        (CX + r * math.cos(a0 + (a1 - a0) * i / steps),
         cy + r * TILT * math.sin(a0 + (a1 - a0) * i / steps))
        for i in range(steps + 1)
    ]


def side(s, grow=0.0, h0=0.0, h1=1.0, steps=64):
    pts = []
    for i in range(steps + 1):
        h = h0 + (h1 - h0) * i / steps
        pts.append((CX + s * (rx(h) + grow), gy(h)))
    return pts


def inside_points():
    """Up the left wall, over the back of the rim, down the right wall and
    round the front of the floor."""
    return (side(-1) + oval_points(1, math.pi, 2 * math.pi)
            + side(1)[::-1] + oval_points(0, 0, math.pi))


def outside_points():
    return (side(-1, WALL) + oval_points(1, math.pi, 2 * math.pi, WALL)
            + side(1, WALL)[::-1] + oval_points(0, 0, math.pi, WALL, y=FOOT_Y))


def rgba(c):
    return c if len(c) == 4 else c + (255,)


class Canvas:
    """A square picture with the design space scaled by [scale] and centred."""

    def __init__(self, n: int, scale: float, background: bool):
        self.n = n
        self.k = n / 1024 * scale
        self.ox = n / 2 - 512 * self.k
        self.oy = n / 2 - 482 * self.k
        self.im = (radial_background(n) if background
                   else Image.new("RGBA", (n, n), (0, 0, 0, 0)))

    def p(self, pts):
        return [(self.ox + x * self.k, self.oy + y * self.k) for x, y in pts]

    def blank(self):
        return Image.new("L", (self.n, self.n), 0)

    def poly(self, pts):
        m = self.blank()
        ImageDraw.Draw(m).polygon(self.p(pts), fill=255)
        return m

    def oval(self, h, grow=0.0, y=None):
        return self.poly(oval_points(h, 0, 2 * math.pi, grow, y))

    def rows(self, y0, y1):
        m = self.blank()
        ImageDraw.Draw(m).rectangle(
            [0, self.oy + y0 * self.k, self.n, self.oy + y1 * self.k], fill=255)
        return m

    def stroke(self, pts, width, round_ends=False):
        m = self.blank()
        d = ImageDraw.Draw(m)
        px = self.p(pts)
        w = max(1, round(width * self.k))
        d.line(px, fill=255, width=w, joint="curve")
        if round_ends:
            for x, y in (px[0], px[-1]):
                d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=255)
        return m

    def circle(self, x, y, r, ry=None):
        m = self.blank()
        ry = r if ry is None else ry
        (px, py), = self.p([(x, y)])
        ImageDraw.Draw(m).ellipse(
            [px - r * self.k, py - ry * self.k, px + r * self.k, py + ry * self.k],
            fill=255)
        return m

    def grad(self, along_x, a, b, stops):
        """A gradient running across (or down) the picture from design
        coordinate [a] to [b]."""
        coord = np.arange(self.n, dtype=np.float32)
        o = self.ox if along_x else self.oy
        t = np.clip((coord - (o + a * self.k)) / ((b - a) * self.k), 0, 1)
        ts = [s[0] for s in stops]
        line = np.stack(
            [np.interp(t, ts, [rgba(s[1])[c] for s in stops]) for c in range(4)],
            -1).astype(np.uint8)
        shape = (self.n, self.n, 4)
        arr = np.broadcast_to(line[None, :, :] if along_x else line[:, None, :], shape)
        return Image.fromarray(np.ascontiguousarray(arr), "RGBA")

    def paint(self, fill, mask, opacity=1.0):
        if isinstance(fill, tuple):
            fill = Image.new("RGBA", (self.n, self.n), rgba(fill))
        a = ImageChops.multiply(fill.getchannel("A"), mask)
        if opacity < 1:
            a = a.point(lambda v: round(v * opacity))
        layer = fill.copy()
        layer.putalpha(a)
        self.im = Image.alpha_composite(self.im, layer)


def radial_background(n: int) -> Image.Image:
    s = 256
    y, x = np.mgrid[0:s, 0:s].astype(np.float32) / (s - 1)
    d = np.clip(np.sqrt((x - 0.44) ** 2 + (y - 0.4) ** 2) / 0.78, 0, 1)
    stops = [(0, BG_CENTRE), (0.5, BG_MID), (1, BG_EDGE)]
    ts = [t for t, _ in stops]
    arr = np.stack([np.interp(d, ts, [c[i] for _, c in stops]) for i in range(3)], -1)
    img = Image.fromarray(arr.astype(np.uint8), "RGB").resize((n, n), Image.BICUBIC)
    return img.convert("RGBA")


def union(*masks):
    out = masks[0]
    for m in masks[1:]:
        out = ImageChops.lighter(out, m)
    return out


def both(a, b):
    return ImageChops.multiply(a, b)


def minus(a, b):
    return ImageChops.subtract(a, b)


def draw(c: Canvas) -> None:
    inside = c.poly(inside_points())
    outside = c.poly(outside_points())
    y_liquid, y_foam = gy(LIQUID), gy(FOAM_TOP)

    # Shadow on the table.
    shadow = c.blank()
    (x0, y0), (x1, y1) = c.p([(CX - 240 + 30, FOOT_Y - 26), (CX + 240 + 30, FOOT_Y + 40)])
    ImageDraw.Draw(shadow).ellipse([x0, y0, x1, y1], fill=255)
    c.paint(SHADOW, shadow.filter(ImageFilter.GaussianBlur(20 * c.k)), 0.55)

    # The glass, a faint white veil, stronger at the edges.
    c.paint(c.grad(True, CX - HALF - WALL, CX + HALF + WALL, [
        (0, (255, 255, 255, 80)), (0.3, (255, 255, 255, 30)),
        (0.7, (255, 255, 255, 18)), (1, (255, 255, 255, 70))]), outside)
    c.paint(WHITE, c.stroke(oval_points(1, math.pi, 2 * math.pi), 4), 0.55)

    # The milk tea: darker at the sides, where light goes through more drink.
    surface = c.oval(LIQUID)
    liquid = minus(both(inside, c.rows(y_liquid, FOOT_Y)), surface)
    r = rx(LIQUID)
    c.paint(c.grad(True, CX - r, CX + r, [
        (0, MILK_DEEP), (0.2, MILK), (0.4, MILK_LIGHT), (0.72, MILK), (1, MILK_DEEP)]),
        liquid)
    c.paint(c.grad(False, y_liquid, FLOOR_Y, [
        (0, (0, 0, 0, 0)), (1, (60, 30, 10, 90))]), liquid)

    # Tapioca pearls resting against the front of the glass.
    rng = random.Random(11)
    pearls = []
    while len(pearls) < 15:
        h = rng.uniform(0.0, 0.2)
        x = CX + rng.uniform(-0.86, 0.86) * rx(h)
        y = gy(h) + rng.uniform(0, 0.6) * rx(h) * TILT
        if all((x - px) ** 2 + (y - py) ** 2 > 44 ** 2 for px, py in pearls):
            pearls.append((x, y))
    for x, y in sorted(pearls, key=lambda p: p[1]):
        body = both(c.circle(x, y, 24), liquid)
        c.paint(PEARL, body)
        c.paint((96, 56, 36), both(c.circle(x + 3, y + 4, 17), body), 0.55)
        c.paint(PEARL, both(c.circle(x + 1, y + 1, 13), body), 0.8)
        c.paint(WHITE, both(c.circle(x - 9, y - 9, 6.5, 5), body), 0.85)
        c.paint(WHITE, both(c.circle(x + 9, y + 11, 3), body), 0.35)

    # The cream on top.
    top = c.oval(FOAM_TOP)
    foam = both(union(both(inside, c.rows(y_foam, y_liquid)), surface, top), inside)
    c.paint(c.grad(False, y_foam, y_liquid + rx(LIQUID) * TILT, [
        (0, FOAM), (0.6, FOAM), (1, FOAM_SHADE)]), foam)
    r = rx(FOAM_TOP)
    c.paint(c.grad(True, CX - r, CX + r, [
        (0, MILK_DEEP + (70,)), (0.15, MILK_DEEP + (0,)),
        (0.85, MILK_DEEP + (0,)), (1, MILK_DEEP + (60,))]), foam)
    c.paint(c.grad(False, y_foam - r * TILT, y_foam + r * TILT, [
        (0, (238, 214, 186)), (0.5, (252, 240, 222)), (1, (255, 250, 242))]), top)
    rng = random.Random(5)
    for _ in range(26):
        a = rng.uniform(0, 2 * math.pi)
        d = math.sqrt(rng.uniform(0.05, 0.9))
        x = CX + math.cos(a) * d * r
        y = y_foam + math.sin(a) * d * r * TILT
        size = 2 + rng.random() ** 2 * 6
        c.paint(FOAM_SHADE, c.circle(x, y + 1, size, size * 0.7), 0.6)
        c.paint(WHITE, c.circle(x, y, size * 0.8, size * 0.55), 0.9)

    # The straw, standing in the cream and leaning out over the rim.
    dx, dy = math.sin(STRAW_ANGLE), -math.cos(STRAW_ANGLE)
    entry_y = y_foam + 0.25 * r * TILT
    length = (entry_y - STRAW_TO[1]) / -dy
    entry = (STRAW_TO[0] - dx * length, entry_y)
    nx, ny = -dy, dx
    half_w = STRAW_W / 2

    def along(off, frm=entry, to=STRAW_TO):
        return [(frm[0] + nx * off, frm[1] + ny * off), (to[0] + nx * off, to[1] + ny * off)]

    c.paint(FOAM_SHADE, c.circle(entry[0], entry[1] + 2, half_w * 1.5, half_w * 0.42), 0.9)
    straw = c.poly(along(-half_w) + along(half_w)[::-1])
    c.paint(STRAW, straw)
    c.paint(STRAW_DARK, both(c.stroke(along(half_w * 0.62), STRAW_W * 0.36), straw), 0.7)
    c.paint(STRAW_LIGHT, both(c.stroke(along(-half_w * 0.42), STRAW_W * 0.16), straw), 0.8)
    c.paint(WHITE, both(c.stroke(along(-half_w * 0.45), STRAW_W * 0.05), straw), 0.6)
    # Seen through the front of the glass, it is a little paler.
    c.paint(WHITE, minus(both(straw, inside), c.oval(1)), 0.14)
    # Cream hugging the straw where it goes in.
    lip = both(c.circle(entry[0], entry[1], half_w * 1.25, half_w * 0.4),
               c.rows(entry[1], entry[1] + STRAW_W))
    c.paint(FOAM, lip)
    # The open end.
    end = []
    for i in range(48):
        a = 2 * math.pi * i / 48
        end.append((STRAW_TO[0] + nx * half_w * math.cos(a) + dx * half_w * 0.32 * math.sin(a),
                    STRAW_TO[1] + ny * half_w * math.cos(a) + dy * half_w * 0.32 * math.sin(a)))
    c.paint(STRAW_DARK, c.poly(end))
    inner = [(STRAW_TO[0] + (x - STRAW_TO[0]) * 0.72, STRAW_TO[1] + (y - STRAW_TO[1]) * 0.72)
             for x, y in end]
    c.paint((10, 52, 47), c.poly(inner))

    # No drops of water on the glass: inside the drink they read as rising
    # bubbles, and a fizzy brown drink under a white head reads as beer.

    # Walls.
    for s in (-1, 1):
        c.paint(WHITE, c.poly(side(s) + side(s, WALL)[::-1]), 0.22)
        c.paint(WHITE, c.stroke(side(s), 3), 0.45)
        c.paint(WHITE, c.stroke([(CX + s * (rx(0) + WALL), FOOT_Y)] + side(s, WALL), 5), 0.9)

    # The solid foot, picking up the colour of the drink.
    r0 = rx(0) + WALL
    foot = c.poly([(CX - r0, FLOOR_Y)] + oval_points(0, math.pi, 0, WALL, y=FOOT_Y)
                  + [(CX + r0, FLOOR_Y)] + oval_points(0, 0, math.pi))
    c.paint(c.grad(False, FLOOR_Y, FOOT_Y + r0 * TILT, [
        (0, (255, 255, 255, 70)), (1, (255, 255, 255, 130))]), foot)
    c.paint(MILK, foot, 0.3)
    c.paint(WHITE, c.stroke(oval_points(0, 0, math.pi, WALL, y=FOOT_Y), 5), 0.9)
    c.paint(WHITE, c.stroke(oval_points(0, math.pi * 0.62, math.pi * 0.9, -8, y=FOOT_Y - 12, steps=24),
                            6, round_ends=True), 0.75)

    # The rim: a thick ring of glass with light along the front.
    ring = minus(c.oval(1, WALL), c.oval(1))
    c.paint(WHITE, ring, 0.3)
    c.paint(WHITE, c.stroke(oval_points(1, 0, 2 * math.pi, WALL), 4), 0.9)
    c.paint(WHITE, c.stroke(oval_points(1, math.pi * 0.56, math.pi * 0.86, WALL * 0.5, steps=32),
                            7, round_ends=True), 0.95)

    # Light streaks down the glass, fading out at both ends.
    fade = c.grad(False, gy(0.94), gy(0.06), [
        (0, (255, 255, 255, 0)), (0.22, (255, 255, 255, 255)),
        (0.7, (255, 255, 255, 210)), (1, (255, 255, 255, 0))])
    for at, width, alpha in ((-0.74, 26, 0.6), (-0.55, 6, 0.45), (0.83, 10, 0.4)):
        pts = [(CX + rx(h) * at, gy(h)) for h in np.linspace(0.06, 0.94, 40)]
        c.paint(fade, c.stroke(pts, width, round_ends=True), alpha)

    # The line to stop on, round the front of the glass, with ticks outside.
    arc = oval_points(LIQUID, 0, math.pi, WALL * 0.5, steps=600)
    lengths = [0.0]
    for (ax, ay), (bx, by) in zip(arc, arc[1:]):
        lengths.append(lengths[-1] + math.hypot(bx - ax, by - ay))
    dash, gap = 34, 22
    line = c.blank()
    start = (lengths[-1] - dash) % (dash + gap) / 2
    while start < lengths[-1]:
        seg = [p for p, d in zip(arc, lengths) if start <= d <= start + dash]
        if len(seg) > 1:
            line = union(line, c.stroke(seg, 13, round_ends=True))
        start += dash + gap
    for s in (-1, 1):
        edge = CX + s * (rx(LIQUID) + WALL)
        line = union(line, c.stroke([(edge + s * 18, y_liquid), (edge + s * 74, y_liquid)],
                                    15, round_ends=True))
    c.paint((120, 20, 20), line.filter(ImageFilter.GaussianBlur(3 * c.k)), 0.35)
    c.paint(LINE, line)


def render(size: int, *, background: bool, scale: float) -> Image.Image:
    c = Canvas(size * SUPER, scale, background)
    draw(c)
    return c.im.resize((size, size), Image.LANCZOS)


def write_launch_images() -> list[pathlib.Path]:
    """Writes the launch picture at the sizes each platform asks for. The
    launch screen puts it in the middle of a plain amber background, so the
    app opens on something of its own instead of blank white."""
    written = []
    ios = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    for scale, name in ((1, "LaunchImage.png"), (2, "LaunchImage@2x.png"), (3, "LaunchImage@3x.png")):
        path = ios / name
        render(120 * scale, background=False, scale=0.92).save(path)
        written.append(path)
    android = ROOT / "android" / "app" / "src" / "main" / "res"
    for folder, px in (
        ("drawable-mdpi", 120),
        ("drawable-hdpi", 180),
        ("drawable-xhdpi", 240),
        ("drawable-xxhdpi", 360),
        ("drawable-xxxhdpi", 480),
    ):
        target = android / folder
        target.mkdir(parents=True, exist_ok=True)
        path = target / "launch_image.png"
        render(px, background=False, scale=0.92).save(path)
        written.append(path)
    return written


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    # The main icon: a full square with no see-through corners. iOS rounds
    # the icon itself, and a see-through corner would come out black.
    render(SIZE, background=True, scale=1.1).convert("RGB").save(OUT / "icon.png")
    # Android's adaptive icon: the glass alone, with room for the mask.
    render(SIZE, background=False, scale=0.8).save(OUT / "icon_foreground.png")
    print(f"wrote {OUT / 'icon.png'} and {OUT / 'icon_foreground.png'}")
    for path in write_launch_images():
        print(f"wrote {path}")


if __name__ == "__main__":
    main()

"""Draws the app icon and the launch screen picture: a glass filled to a
dashed line.

Run from the project root with the bundled Python:
    python tool/make_icon.py
Then regenerate the platform icons:
    dart run flutter_launcher_icons

Writing the pictures as code keeps them in the repository and lets the
colours be changed in one place, instead of carrying binaries nobody can
edit. The launch images are written straight into the android and ios
folders, because flutter_launcher_icons does not make those.
"""

from __future__ import annotations

import pathlib

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icon"

# The app's colours, matching lib/app.dart.
AMBER = (242, 165, 22, 255)
AMBER_DARK = (198, 124, 0, 255)
# The drink is milk tea, not beer: amber liquid under a white head would
# read as beer and push the age rating up.
MILK_TEA = (200, 149, 107, 255)
FOAM = (255, 244, 224, 255)
LINE = (227, 70, 70, 255)
GLASS = (255, 255, 255, 255)

SIZE = 1024


def glass_width(height: float) -> float:
    """Relative width of the tulip shape at a height from 0 to 1."""
    import math

    return 0.58 + 0.42 * math.sin(math.pi * height)


def draw_glass(
    d: ImageDraw.ImageDraw,
    *,
    cx: float,
    top: float,
    bottom: float,
    half: float,
    fill_to: float,
    outline_width: float,
) -> None:
    """Draws one glass, filled with liquid up to [fill_to] (0 to 1)."""
    height = bottom - top

    def edge(h: float, side: int) -> tuple[float, float]:
        return (cx + side * glass_width(h) * half, bottom - h * height)

    def band(low: float, high: float, steps: int = 24) -> list[tuple[float, float]]:
        left = [edge(low + (high - low) * i / steps, -1) for i in range(steps + 1)]
        right = [edge(low + (high - low) * i / steps, 1) for i in range(steps + 1)]
        return left + right[::-1]

    # Liquid, with a band of foam on top.
    d.polygon(band(0, fill_to), fill=MILK_TEA)
    d.polygon(band(fill_to, min(1.0, fill_to + 0.07)), fill=FOAM)

    # Outline: up one side, across the foot, down the other.
    steps = 48
    left = [edge(1 - i / steps, -1) for i in range(steps + 1)]
    right = [edge(i / steps, 1) for i in range(steps + 1)]
    d.line(left + right, fill=GLASS, width=int(outline_width), joint="curve")


def draw_line(
    d: ImageDraw.ImageDraw,
    *,
    cx: float,
    top: float,
    bottom: float,
    half: float,
    at: float,
    width: float,
) -> None:
    """The dashed target line the player aims for."""
    y = bottom - at * (bottom - top)
    reach = glass_width(at) * half + half * 0.3
    dash, gap = half * 0.22, half * 0.14
    x = cx - reach
    while x < cx + reach:
        d.line([(x, y), (min(x + dash, cx + reach), y)], fill=LINE, width=int(width))
        x += dash + gap


def icon(size: int, *, background: bool, margin: float) -> Image.Image:
    # A full square with no see-through corners: iOS rounds the icon itself,
    # and a transparent corner would come out white on the home screen.
    im = Image.new("RGBA", (size, size), AMBER_DARK if background else (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    inner = size * (1 - 2 * margin)
    top = size * margin
    bottom = top + inner
    draw_glass(
        d,
        cx=size / 2,
        top=top,
        bottom=bottom,
        half=inner * 0.3,
        fill_to=0.62,
        outline_width=max(2, size * 0.022),
    )
    draw_line(
        d,
        cx=size / 2,
        top=top,
        bottom=bottom,
        half=inner * 0.3,
        at=0.62,
        width=max(2, size * 0.02),
    )
    return im


def smooth(*, background: bool, margin: float) -> Image.Image:
    """Draws four times too big, then shrinks it. Pillow's polygons have
    hard edges, and shrinking is what gives them smooth ones."""
    big = icon(SIZE * 4, background=background, margin=margin)
    return big.resize((SIZE, SIZE), Image.LANCZOS)


def launch_image(size: int) -> Image.Image:
    """The glass alone, see-through around it, for the launch screen.

    The launch screen puts this in the middle of a plain amber background,
    so the app opens on something of its own instead of blank white.
    """
    big = icon(size * 4, background=False, margin=0.08)
    return big.resize((size, size), Image.LANCZOS)


def write_launch_images() -> list[pathlib.Path]:
    """Writes the launch picture at the sizes each platform asks for."""
    written = []
    # iOS wants one image at three scales, named by Xcode's convention.
    ios = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    for scale, name in ((1, "LaunchImage.png"), (2, "LaunchImage@2x.png"), (3, "LaunchImage@3x.png")):
        path = ios / name
        launch_image(120 * scale).save(path)
        written.append(path)
    # Android keeps one bitmap per screen density.
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
        launch_image(px).save(path)
        written.append(path)
    return written


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    # The main icon: glass on the app's amber background.
    smooth(background=True, margin=0.18).save(OUT / "icon.png")
    # Android's adaptive icon: foreground only, with room for the mask.
    smooth(background=False, margin=0.3).save(OUT / "icon_foreground.png")
    print(f"wrote {OUT / 'icon.png'} and {OUT / 'icon_foreground.png'}")
    for path in write_launch_images():
        print(f"wrote {path}")


if __name__ == "__main__":
    main()

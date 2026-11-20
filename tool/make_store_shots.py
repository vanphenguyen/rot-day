"""App Store screenshots in the same style as the earlier apps (AncestryDay,
ForgetNot): a bold headline on top, the app screen inside an iPhone frame
with a Dynamic Island, a 9:41 status bar, a home indicator and a soft shadow,
on a plain light background.

Input : tool/screenshots/raw/<lang>-<n>-<name>.png, made by
        flutter test tool/screenshots_test.dart --update-goldens
        (1179x2556, an iPhone screen at 3x with the notch and home-bar
        areas left empty).
Output: docs/app-store/screenshots/<WxH>/<lang>/<n>.png, RGB, no alpha,
        in both sizes Apple accepts for the 6.9" and 6.3" iPhones.

Run from the project root:  python tool/make_store_shots.py
"""

from __future__ import annotations

import glob
import os
import pathlib

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / 'tool' / 'screenshots' / 'raw'
OUT = ROOT / 'docs' / 'app-store' / 'screenshots'

# The app's own font and colours (lib/style/palette.dart).
HEAD_FONT = str(ROOT / 'assets' / 'fonts' / 'Nunito-900.ttf')
STATUS_FONT = str(ROOT / 'assets' / 'fonts' / 'Nunito-800.ttf')
BG_TOP = (255, 245, 230)       # cream
BG_BOTTOM = (247, 226, 190)    # warm sand
INK = (59, 36, 20)             # coffee
SHADOW = (120, 80, 30)

SIZES = [(1290, 2796), (1206, 2622)]

# Which raw screens go on the store, in order, with their headlines.
SHOTS = ['1-home', '2-pouring', '3-result', '4-stats', '5-howto']
HEADLINES = {
    'vi': [
        'Giữ để rót,\nthả tay đúng vạch',
        'Thả tay rồi\nnước vẫn chảy',
        'Lệch dưới 1 mm\nlà hoàn hảo',
        '10 huy chương\nđể sưu tầm',
        'Sáu loại nước,\nsáu kiểu ly',
    ],
    'en': [
        'Hold to pour.\nLet go on the line.',
        'The stream keeps\nfalling after you let go',
        'Within 1 mm\nis perfect',
        '10 medals\nto collect',
        'Six drinks,\nsix glasses',
    ],
}


def gradient(w: int, h: int) -> Image.Image:
    img = Image.new('RGB', (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(round(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3)))
    return img


def fit_font(lines: list[str], max_w: int, start: int) -> ImageFont.FreeTypeFont:
    size = start
    while size > 40:
        f = ImageFont.truetype(HEAD_FONT, size)
        if all(f.getbbox(l)[2] - f.getbbox(l)[0] <= max_w for l in lines):
            return f
        size -= 2
    return ImageFont.truetype(HEAD_FONT, size)


def with_status_bar(shot: Image.Image) -> Image.Image:
    """Draws the 9:41 status bar into the empty strip the app leaves at the
    top, the way a real iPhone shows it."""
    shot = shot.copy()
    d = ImageDraw.Draw(shot)
    u = shot.width / 1179.0          # 3 px per point
    cy = 84 * u                      # centre of the status items, ~28pt down
    d.text((150 * u, cy), '9:41', font=ImageFont.truetype(STATUS_FONT, round(50 * u)), fill=INK, anchor='mm')
    x, base = 862 * u, cy + 18 * u
    for i, hgt in enumerate((14, 22, 30, 38)):
        d.rounded_rectangle([x + i * 15 * u, base - hgt * u, x + i * 15 * u + 10 * u, base], 3, fill=INK)
    wx, wy = 962 * u, cy + 18 * u
    for r in (34, 23, 12):
        d.arc([wx - r * u, wy - r * u, wx + r * u, wy + r * u], 225, 315, fill=INK, width=round(7 * u))
    d.ellipse([wx - 5 * u, wy - 9 * u, wx + 5 * u, wy + u], fill=INK)
    bx, by = 1010 * u, cy
    d.rounded_rectangle([bx, by - 16 * u, bx + 64 * u, by + 16 * u], round(9 * u), outline=INK, width=round(4 * u))
    d.rounded_rectangle([bx + 7 * u, by - 9 * u, bx + 57 * u, by + 9 * u], round(5 * u), fill=INK)
    d.rounded_rectangle([bx + 68 * u, by - 6 * u, bx + 73 * u, by + 6 * u], 2, fill=INK)
    return shot


def compose(screen: Image.Image, headline: str, W: int, H: int) -> Image.Image:
    k = W / 1206.0
    canvas = gradient(W, H)

    scr_w = round(800 * k)
    scr_h = round(screen.height * scr_w / screen.width)
    screen = screen.resize((scr_w, scr_h), Image.LANCZOS)
    bezel = round(26 * k)
    ph_w, ph_h = scr_w + 2 * bezel, scr_h + 2 * bezel
    ph_x = (W - ph_w) // 2
    ph_y = H - ph_h - round(110 * k)
    r_out, r_in = round(150 * k), round(124 * k)

    # Headline, centred in the band above the phone.
    lines = headline.split('\n')
    font = fit_font(lines, W - round(150 * k), round(100 * k))
    line_h = round(font.size * 1.22)
    block = line_h * len(lines)
    y = (ph_y - block) // 2 + round(12 * k)
    d = ImageDraw.Draw(canvas)
    for line in lines:
        d.text((W // 2, y), line, font=font, fill=INK, anchor='mt')
        y += line_h

    # Soft shadow under the phone.
    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        [ph_x + 18, ph_y + 40, ph_x + ph_w + 18, ph_y + ph_h + 40], r_out, fill=110)
    shadow = shadow.filter(ImageFilter.GaussianBlur(38 * k))
    canvas = Image.composite(Image.new('RGB', (W, H), SHADOW), canvas, shadow)
    d = ImageDraw.Draw(canvas)

    # Side buttons, metal edge, black bezel.
    btn = (30, 30, 32)
    for top, bot in ((300, 380), (430, 560), (590, 720)):
        d.rounded_rectangle([ph_x - 9, ph_y + top * k, ph_x + 4, ph_y + bot * k], 5, fill=btn)
    d.rounded_rectangle([ph_x + ph_w - 4, ph_y + 460 * k, ph_x + ph_w + 9, ph_y + 640 * k], 5, fill=btn)
    d.rounded_rectangle([ph_x - 3, ph_y - 3, ph_x + ph_w + 3, ph_y + ph_h + 3], r_out + 3, fill=(88, 86, 84))
    d.rounded_rectangle([ph_x, ph_y, ph_x + ph_w, ph_y + ph_h], r_out, fill=(18, 18, 20))

    # The screen, with rounded corners.
    mask = Image.new('L', screen.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, scr_w - 1, scr_h - 1], r_in, fill=255)
    canvas.paste(screen, (ph_x + bezel, ph_y + bezel), mask)
    d = ImageDraw.Draw(canvas)

    # Dynamic Island.
    di_w, di_h = round(236 * k), round(70 * k)
    di_y = ph_y + bezel + round(22 * k)
    d.rounded_rectangle([W // 2 - di_w // 2, di_y, W // 2 + di_w // 2, di_y + di_h], di_h // 2, fill=(0, 0, 0))

    # Home indicator.
    hi_w = round(290 * k)
    hy = ph_y + bezel + scr_h - round(22 * k)
    d.rounded_rectangle([W // 2 - hi_w // 2, hy - round(9 * k), W // 2 + hi_w // 2, hy], 5, fill=INK)
    return canvas.convert('RGB')


def main() -> None:
    made = 0
    for lang, heads in HEADLINES.items():
        screens = []
        for name in SHOTS:
            path = RAW / f'{lang}-{name}.png'
            if not path.exists():
                raise SystemExit(f'missing {path}: run tool/screenshots_test.dart first')
            screens.append(with_status_bar(Image.open(path).convert('RGB')))
        for W, H in SIZES:
            folder = OUT / f'{W}x{H}' / lang
            folder.mkdir(parents=True, exist_ok=True)
            for old in glob.glob(str(folder / '*.png')):
                os.remove(old)
            for n, (screen, head) in enumerate(zip(screens, heads), start=1):
                img = compose(screen, head, W, H)
                assert img.size == (W, H) and img.mode == 'RGB'
                img.save(folder / f'{n}.png', optimize=True)
                made += 1
    print('made', made, 'images in', OUT)

    # A contact sheet per language, for a quick look.
    for lang in HEADLINES:
        n = len(SHOTS)
        sheet = Image.new('RGB', (n * 402 + (n + 1) * 20, 874 + 40), (255, 255, 255))
        for i in range(n):
            im = Image.open(OUT / '1206x2622' / lang / f'{i + 1}.png')
            sheet.paste(im.resize((402, 874), Image.LANCZOS), (20 + i * 422, 20))
        sheet.save(ROOT / 'tool' / 'screenshots' / f'sheet_{lang}.png')


if __name__ == '__main__':
    main()

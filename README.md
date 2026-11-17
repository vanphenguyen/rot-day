# Rót Đầy (Pour Perfect)

Game một thao tác: giữ ngón tay để rót, thả tay đúng vạch. Tràn là mất ly.
Flutter, chạy trên Android và iPhone. Không tài khoản, không mạng, không quảng cáo, dữ liệu chỉ nằm trên máy.

Mã app: `com.phenv.rotday`

## Cái khó của game

Thả tay đúng vạch là đã muộn. Hai lý do:

- Phần nước đang lơ lửng vẫn rơi xuống sau khi thả tay. Nước càng đặc càng rơi dai (sinh tố dai nhất).
- Bia và nước ngọt nổi bọt, và khoảng một phần tư lớp bọt lắng xuống thành nước.

Thêm vào đó, sáu kiểu ly làm mực nước dâng nhanh chậm khác nhau ở từng đoạn, nên cùng một lượng nước mà
mỗi ly lại nhìn khác.

## Ba chế độ

- **Ly hôm nay**: mỗi ngày một ly, mọi máy ra cùng một ly, chỉ được rót một lần. Có nút chép kết quả để dán lên mạng.
- **Rót liên tục**: hết ly này sang ly khác. Mức cho phép hẹp dần từ 9 mm xuống 2,5 mm, tốc độ rót nhanh dần,
  từ ly thứ bảy dòng nước bắt đầu tự chao. Lệch vạch hay tràn là hết lượt.
- **Tập rót**: rót thoải mái, không tính gì.

Ngoài ra có 10 huy chương, màn hình Thành tích, màn hình Cách chơi và màn hình Cài đặt (rung, âm thanh, ngôn ngữ).

## Cấu trúc

Phần tính toán tách khỏi phần vẽ, nên luật chơi kiểm tra được bằng test mà không cần mở giao diện.

| File | Việc |
|---|---|
| `lib/game/prng.dart` | Bộ số ngẫu nhiên riêng, cho ra cùng dãy số trên mọi máy. `dart:math` không hứa điều đó, mà ly hôm nay thì bắt buộc giống nhau. |
| `lib/game/glass_shape.dart` | Sáu hình ly, và bảng đổi giữa chiều cao và lượng nước. |
| `lib/game/drink.dart` | Sáu loại nước: bọt, độ đặc, màu, mở khóa ở ly thứ mấy. |
| `lib/game/level.dart` | Sinh một ly: nước gì, ly gì, vạch ở đâu, chảy nhanh bao nhiêu. Ly hôm nay sinh từ số thứ tự ngày (#1 là 1/1/2026). |
| `lib/game/pour_physics.dart` | Dòng chảy, bọt, tràn. Bước tính cố định 1/240 giây nên máy nhanh hay chậm đều ra cùng kết quả. |
| `lib/game/scoring.dart` | Chấm điểm theo số mm lệch (ly cao 120 mm), tính điểm, danh sách huy chương. |
| `lib/services/score_store.dart` | Lưu kết quả, kỷ lục, huy chương, cài đặt bằng `shared_preferences`. |
| `lib/services/feedback.dart` | Rung và tiếng tách. Dùng âm thanh hệ thống nên app không mang theo file nhạc nào. |
| `lib/screens/` | Bốn màn hình: chính, rót, thành tích, cách chơi, cài đặt. |
| `lib/widgets/glass_painter.dart` | Vẽ ly, nước, bọt, dòng chảy, vạch. Vẽ thẳng bằng `CustomPainter`, không dùng thư viện game. |
| `lib/l10n/` | Chữ giao diện: tiếng Việt và tiếng Anh. Sửa file `.arb` rồi chạy `flutter gen-l10n`. |
| `tool/make_icon.py` | Vẽ biểu tượng app và ảnh màn hình chờ. |

## Một điều không được đổi

Ly hôm nay phải giống nhau trên mọi máy. Vì vậy **không được đổi thứ tự** các giá trị trong `Drink` và `GlassShape`,
cũng không được sửa `Prng` hay `Level.generate` sau khi app đã lên store. Thêm loại nước mới thì **thêm vào cuối**
danh sách. Đổi thứ tự là người chơi ở hai phiên bản khác nhau sẽ nhận hai ly khác nhau trong cùng một ngày.

Đó cũng là lý do nội dung game nằm trong code Dart chứ không nằm trong file JSON như MemoMate.

## Kiểm tra

```bash
flutter pub get
flutter analyze && flutter test
```

Vẽ lại biểu tượng và ảnh màn hình chờ sau khi sửa `tool/make_icon.py`:

```bash
python tool/make_icon.py
dart run flutter_launcher_icons
```

## Build

- **APK để cài thử**: GitHub Actions (`.github/workflows/build.yml`) tự build sau mỗi lần đẩy code, tên artifact `rot-day-apk`.
- **Bản iPhone**: Codemagic (`codemagic.yaml`), xem hướng dẫn từng bước ở `docs/APP_STORE.md`.
- **Bản web và trang quyền riêng tư**: `.github/workflows/pages.yml` đăng lên GitHub Pages.
  Phải bật Settings > Pages > Source: **GitHub Actions**.

## Chỉnh cảm giác chơi

Các con số hiện tại là ước lượng, chưa chơi thử trên máy thật. Chỗ cần chỉnh:

- `lib/game/drink.dart`: `foamPerHeight` (nổi bao nhiêu bọt), `settleRate` (bọt lắng nhanh chậm),
  `thickness` (thả tay rồi còn chảy dai bao lâu).
- `lib/game/pour_physics.dart`: `baseFallTime` (độ trễ khi thả tay), `foamLiquidRatio` (bọt thành nước bao nhiêu).
- `lib/game/level.dart`: `minFlowRate`, `maxBaseFlowRate` (tốc độ rót), `minLine` (vạch thấp nhất).
- `lib/game/scoring.dart`: `endlessTolerance` (mức cho phép ở chế độ rót liên tục).

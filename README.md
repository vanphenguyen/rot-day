# Rót Đầy (Pour Perfect)

Game một chạm: giữ ngón tay để rót, thả tay đúng vạch. Tràn là thua.
Flutter, chạy trên Android và iPhone. Không tài khoản, không mạng, dữ liệu chỉ nằm trên máy.

## Cách chơi

- **Ly hôm nay**: mỗi ngày một ly, ai cũng rót chung ly đó, chỉ được một lần. Có nút "Chép kết quả" để dán lên mạng.
- **Rót liên tục**: rót hết ly này sang ly khác; mỗi ly vạch cho lệch càng ít (10 mm xuống tới 3 mm).
- Bia có bọt: bọt lắng xuống thành thêm chút bia, nên phải thả tay sớm hơn vạch.
  Nước mía có ít bọt, trà không có bọt.

## Cấu trúc

- `lib/game/level.dart`: hình ly, loại nước, vạch. Ly hôm nay sinh từ số thứ tự ngày (#1 là 1/1/2026)
  bằng bộ số ngẫu nhiên riêng, nên mọi máy ra cùng một ly.
- `lib/game/pour_physics.dart`: dòng chảy, bọt, tràn. Chạy theo bước cố định 1/240 giây nên máy nhanh hay chậm
  đều cho cùng kết quả.
- `lib/game/scoring.dart`: chấm điểm theo số mm lệch (ly cao 120 mm).
- `lib/services/score_store.dart`: lưu kết quả và kỷ lục bằng `shared_preferences`.
- `lib/screens/`: màn hình chính và màn hình rót. `lib/widgets/glass_painter.dart` vẽ ly.
- `lib/l10n/`: chữ giao diện, hiện có tiếng Việt và tiếng Anh. Sửa file `.arb` rồi chạy `flutter gen-l10n`.

## Kiểm tra

```bash
flutter pub get
flutter analyze && flutter test
```

GitHub Actions (`.github/workflows/build.yml`) build file APK sau mỗi lần đẩy code, tên `rot-day-apk`.

# Đưa Rót Đầy (Pour Perfect) lên App Store bằng Codemagic

Codemagic thay cho máy Mac: nó build bản iPhone và tải lên App Store Connect. Cấu hình nằm trong `codemagic.yaml`.

**Bạn đã làm việc này một lần cho MemoMate, nên phần lớn thiết lập dùng lại được.** Bảng dưới đây nói rõ cái nào
dùng lại, cái nào phải tạo mới.

## Cái gì dùng lại, cái gì tạo mới

| Thứ | Dùng lại từ MemoMate? | Vì sao |
|---|---|---|
| Tài khoản Apple Developer (99 USD/năm) | **Dùng lại** | Một tài khoản chứa được nhiều app |
| Khóa API App Store Connect tên `codemagic` | **Dùng lại** | Khóa gắn với tài khoản, không gắn với app |
| Chứng chỉ **Apple Distribution** | **Dùng lại** | Chứng chỉ gắn với tài khoản |
| Mã app (Bundle ID) | **Tạo mới**: `com.phenv.rotday` | Mỗi app một mã, không trùng được |
| App trên App Store Connect | **Tạo mới** | Đây là app khác |
| Provisioning profile | **Tạo mới** | Profile gắn với từng mã app |
| App trên Codemagic | **Tạo mới** | Trỏ vào repo `rot-day` |

Mã app `com.phenv.rotday` đã được đặt sẵn trong code (Android, iOS và `codemagic.yaml`). Bạn **không phải sửa code**,
chỉ cần đăng ký đúng mã đó bên phía Apple.

## 0. Build thử trước (không cần tài khoản Apple)
Codemagic > app rot-day > **Start new build** > nhánh `main` > workflow **iOS - Build thử (không cần Apple)**.
Bước này chỉ kiểm tra bản iPhone biên dịch được; kết quả không cài được lên máy.

Muốn thử trên máy Android: chạy workflow **Android - APK để cài thử**, xong thì tải file `app-release.apk` ở mục
Artifacts của lần build đó và cài lên máy (phải cho phép cài app từ nguồn ngoài).

Muốn xem thử ngay trên trình duyệt: workflow **iOS - Bản cho máy ảo iPhone (xem thử)**, rồi bấm nút Quick Launch
cạnh artifact `.app`.

## 1. Đăng ký mã app với Apple
developer.apple.com > Account > Certificates, Identifiers & Profiles > **Identifiers** > dấu **+** > App IDs > App.
- Description: `Pour Perfect`. Bundle ID: chọn **Explicit**, nhập `com.phenv.rotday`.
- Không cần tích khả năng (capability) nào. Game chạy hoàn toàn trên máy, không thông báo, không mạng.

## 2. Tạo app trên App Store Connect
appstoreconnect.apple.com > Apps > dấu **+** > New App.
- Platform: iOS. Name: `Pour Perfect: Fill the Glass`. Primary language: English.
- Sau khi tạo, thêm ngôn ngữ Vietnamese cho trang app và đặt tên ở đó là `Rót Đầy: Rót Chuẩn Từng Giọt`.
- Bundle ID: chọn mã vừa đăng ký. SKU: ví dụ `rotday`.

## 3. Khóa API cho Codemagic
**Dùng lại khóa `codemagic` đã tạo cho MemoMate. Không cần tạo mới.**

Kiểm tra lại: Codemagic > Teams > (tài khoản của bạn) > **Integrations** > Developer Portal > Manage keys. Phải thấy
một khóa tên đúng là `codemagic` (file `codemagic.yaml` gọi khóa theo tên này).

## 4. Chứng chỉ ký app
**Dùng lại chứng chỉ Apple Distribution đã tạo cho MemoMate. Không cần tạo mới.**

Kiểm tra: Codemagic > Teams > (tài khoản của bạn) > **codemagic.yaml settings** > Code signing identities > tab
**iOS certificates**. Phải thấy chứng chỉ loại Apple Distribution.

## 5. Hồ sơ cấp phép (provisioning profile) — phải tạo mới
Profile gắn với từng mã app, nên app mới bắt buộc có profile mới.

developer.apple.com > Profiles > dấu **+** > Distribution > **App Store Connect**.
- Chọn App ID `com.phenv.rotday`, chọn chứng chỉ Apple Distribution đã có, đặt tên (ví dụ `rotday appstore`), Generate.

Quay lại Codemagic > Code signing identities > tab **iOS provisioning profiles** > Fetch profiles > chọn hồ sơ đó,
đặt tên tham chiếu bất kỳ.

Codemagic tự tìm profile khớp với `bundle_identifier: com.phenv.rotday` ghi trong `codemagic.yaml`, nên bạn
**không phải nhập mã app vào giao diện Codemagic**.

## 6. Chạy build
Codemagic > app rot-day > **Start new build** > nhánh `main` > workflow **iOS - App Store**.
- Nếu Codemagic hỏi kiểu cấu hình, chọn dùng `codemagic.yaml`.
- Build mất khoảng 10 đến 20 phút. Xong, bản build tự được tải lên App Store Connect, mục **TestFlight**
  (Apple xử lý thêm 10 đến 30 phút mới hiện).

## 7. Thử trên iPhone bằng TestFlight
App Store Connect > app > TestFlight > Internal Testing > tạo nhóm, thêm Apple ID của bạn.
Cài app **TestFlight** trên iPhone và cài bản thử.

**Đây là lúc phải chơi thật và chỉnh cảm giác chơi.** Các con số về tốc độ rót, lượng bọt và độ trễ khi thả tay
mới là ước lượng; phải chơi trên máy thật mới biết có khó quá hay dễ quá. Những chỗ chỉnh nằm trong
`lib/game/drink.dart` (bọt, độ đặc) và `lib/game/level.dart` (tốc độ rót, vạch).

Nhớ bật tắt thử phần **rung và âm thanh** trong mục Cài đặt, vì hai thứ này không chạy được trên máy ảo.

## 8. Điền thông tin trang App Store
Nội dung viết sẵn (tên, phụ đề, mô tả, từ khóa, ghi chú cho người duyệt) ở `docs/app-store/listing.md`.

App Store Connect > app > tab Distribution (App Store):
- **Ảnh chụp màn hình**: chưa có, bạn phải tự chụp. Xem phần "Ảnh chụp màn hình" bên dưới.
- **Mô tả, từ khóa, danh mục** (gợi ý: Games > Casual, phụ: Puzzle).
- **Support URL**: `https://github.com/vanphenguyen/rot-day/issues`
- **Privacy Policy URL**: `https://vanphenguyen.github.io/rot-day/privacy.html`
  (trang này do workflow `.github/workflows/pages.yml` tự đăng; phải bật GitHub Pages trong Settings > Pages,
  chọn Source là **GitHub Actions**)
- **App Privacy**: chọn **Data Not Collected** (game không thu thập gì).
- **Age Rating**: trả lời "None / No" cho mọi câu hỏi, kết quả sẽ là 4+.
- **Giá**: Free.
- Mục Build: chọn bản build đã tải lên ở bước 6.

## Ảnh chụp màn hình — việc bạn phải làm
Apple bắt buộc có ảnh. Cách dễ nhất:
1. Cài bản TestFlight lên iPhone.
2. Chụp 4 màn hình: màn hình chính, lúc đang rót, lúc vừa rót xong (có ngôi sao), và màn hình Thành tích.
3. Ảnh phải đúng cỡ Apple yêu cầu cho iPhone (hiện là 1290x2796 hoặc 1206x2622). Chụp từ iPhone đời mới là đúng cỡ.
4. Tải lên mục App Previews and Screenshots.

Nếu không có iPhone: chạy workflow **iOS - Bản cho máy ảo iPhone**, mở app preview trên trình duyệt Codemagic rồi
chụp, nhưng ảnh sẽ không đúng cỡ nên phải chỉnh lại kích thước.

## 9. Gửi duyệt
Bấm **Add for Review** rồi **Submit**. Apple thường duyệt trong 1 đến 3 ngày.

### Rủi ro bị từ chối, và cái gì đã làm để giảm
Apple hay từ chối game đơn giản theo hai điều khoản:

- **4.2 Minimum Functionality**: app quá đơn giản, chỉ một tính năng nhỏ.
- **4.3 Spam**: app trùng lặp với nhiều app đã có mà không khác gì.

Những thứ đã làm trong bản này để giảm rủi ro:

| Việc | Tình trạng |
|---|---|
| Biểu tượng app riêng (không để icon mặc định Flutter) | Xong |
| Màn hình chờ riêng, không mở ra màn trắng | Xong |
| Ba chế độ chơi: ly hôm nay, rót liên tục, tập rót | Xong |
| 6 loại nước và 6 kiểu ly, mỗi thứ chơi khác nhau | Xong |
| 10 huy chương để sưu tầm | Xong |
| Màn hình Thành tích, Cách chơi, Cài đặt | Xong |
| Rung và âm thanh, bật tắt được | Xong |
| Hai ngôn ngữ, chọn được trong app | Xong |
| Mô tả store nêu rõ điểm khác biệt | Xong, ở `listing.md` |

**Vẫn còn rủi ro.** Game một thao tác là loại Apple soi kỹ nhất. Nếu bị từ chối, Apple ghi rõ lý do; gửi nội dung đó
cho Claude để sửa. Hướng sửa thường là thêm nội dung chơi, không phải sửa chữ trong mô tả.

## Số thứ tự build
Apple chỉ nhận bản có số build lớn hơn mọi bản đã tải lên. Workflow dùng ngày giờ lúc build (giờ UTC, dạng
`YYMMDDHHMM`) làm số build, nên số này luôn tăng dù build ở tài khoản Codemagic nào.
Nếu sau này build trên máy Mac, dùng cùng cách:

```bash
flutter build ipa --release --build-number=$(date -u +%y%m%d%H%M)
```

## Mỗi lần ra bản mới
Tăng `version` trong `pubspec.yaml` (và sửa `appVersion` trong `lib/screens/settings_screen.dart` cho khớp),
đẩy lên `main`, chạy lại bước 6, rồi tạo phiên bản mới trên App Store Connect và gửi duyệt.

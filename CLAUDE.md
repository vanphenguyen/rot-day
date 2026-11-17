# Ghi chú cho người (hoặc AI) làm tiếp project này

## Cách làm việc với chủ dự án

Chủ dự án **không phải lập trình viên**. Vì vậy:

- Trả lời bằng **tiếng Việt**, câu ngắn, không dùng từ chuyên môn mà không giải thích.
- Khi đổi giao diện, kèm **ảnh chụp màn hình**. Nếu không chụp được thì nói rõ là không chụp được, đừng im lặng.
- Khi có việc chủ dự án phải tự làm (bấm nút trên web Apple, tải ảnh lên store), **nói rõ từng bước bấm vào đâu**.
- Đừng hỏi lại những thứ tự quyết định được. Quyết rồi báo lại là đã quyết thế nào và vì sao.

## Luật không được phá: ly hôm nay phải giống nhau trên mọi máy

Chế độ "Ly hôm nay" sinh ly từ số thứ tự ngày, bằng `Prng` tự viết trong `lib/game/prng.dart`.
Mọi người chơi trong cùng một ngày phải nhận **đúng cùng một ly**, kể cả khi họ dùng phiên bản app khác nhau.

Do đó, sau khi app đã lên store:

- **Không đổi thứ tự** các giá trị trong `enum Drink` và `enum GlassShape`. Thêm loại mới thì thêm **vào cuối**.
- **Không sửa** `Prng`, `Level.generate`, `Level.daily`, hay `dailyNumber`.
- **Không đổi** `minLine`, `minFlowRate`, `maxBaseFlowRate`, hay cách tính `difficulty` trong `Level.daily`.

Muốn đổi những thứ trên thì phải đổi cả cách đánh số ngày (ví dụ thêm một "mùa" mới), chứ không sửa trực tiếp.

Đây là lý do nội dung game nằm trong code Dart, khác với MemoMate (project tham khảo) để nội dung trong file JSON.

## Chạy lệnh trên máy của chủ dự án

Flutter **không cài vào hệ thống**, nằm ở `D:\WORK\AI\tools\flutter`. Máy cũng không cho ghi vào thư mục
AppData mặc định, nên **mọi lệnh flutter/dart phải đặt lại biến môi trường trước**:

```powershell
$t='D:\WORK\AI\tools'
$env:TEMP="$t\tmp"; $env:TMP="$t\tmp"
$env:APPDATA="$t\appdata"; $env:LOCALAPPDATA="$t\localappdata"
$env:PUB_CACHE="$t\pub-cache"
$env:Path="$t\flutter\bin;$env:Path"
```

Không làm thế thì lệnh sẽ lỗi "Access is denied" hoặc "Flutter failed to write to a file".

Máy **không có Android SDK và không có Java**, nên **không build được APK tại máy**. Kiểm tra tại máy chỉ gồm:

```powershell
flutter analyze
flutter test
flutter build web
```

APK lấy từ GitHub Actions. Bản iPhone lấy từ Codemagic.

Mạng hay đứt giữa lúc tải gói. Nếu `flutter pub get` lỗi "Connection closed while receiving data", chạy lại vài lần.
Nếu vẫn kẹt ở một gói, tải tay file `.tar.gz` của gói đó rồi `flutter pub cache preload <file>`.

## Rủi ro App Store, và vì sao code trông "nhiều thứ"

Apple từ chối game đơn giản theo điều **4.2 Minimum Functionality** (app quá đơn giản) và **4.3 Spam** (trùng lặp).
Game một thao tác là loại bị soi kỹ nhất.

Những thứ sau có trong app **để giảm rủi ro bị từ chối**, không phải để cho vui. Đừng bỏ bớt:

- Biểu tượng app riêng và màn hình chờ riêng (icon mặc định của Flutter gần như chắc chắn bị từ chối).
- Ba chế độ chơi, 6 loại nước, 6 kiểu ly.
- 10 huy chương, màn hình Thành tích.
- Màn hình Cách chơi và màn hình Cài đặt.
- Rung, âm thanh, và hai ngôn ngữ chọn được trong app.

Chi tiết và bảng theo dõi ở `docs/APP_STORE.md`, mục "Rủi ro bị từ chối".

## Chưa làm, và biết là chưa làm

- **Chưa chơi thử trên máy thật.** Các con số về bọt, độ đặc, tốc độ rót mới là ước lượng. Phần cần chỉnh
  liệt kê ở cuối `README.md`.
- **Chưa có ảnh chụp màn hình cho App Store.** Apple bắt buộc có. Chủ dự án phải tự chụp từ bản TestFlight,
  hướng dẫn ở `docs/app-store/listing.md`.
- **Chưa có âm thanh riêng.** Hiện dùng tiếng tách của hệ thống (`SystemSound`), nên app không mang file nhạc nào.
  Muốn có tiếng nước chảy thật thì phải thêm gói phát âm thanh và file âm thanh.
- **Chưa kiểm tra tên "Rót Đầy" và "Pour Perfect" có bị trùng trên store hay chưa.**
- **Chưa khảo sát đối thủ trên store.** Lúc làm bản này, công cụ tìm kiếm web trên máy không dùng được
  (thiếu khóa API), nên mọi nhận định về thị trường đều là suy luận, chưa có số liệu.

## Phần lấy từ MemoMate

Project tham khảo là MemoMate (app Nhớ Nhé, `com.phenv.nhonhe`). Lấy lại: cách lưu dữ liệu bằng
`shared_preferences`, cách dịch bằng file `.arb`, theme, `codemagic.yaml` 4 workflow, `pages.yml`, và cấu trúc
`docs/APP_STORE.md`. Phần luật chơi và vẽ thì viết mới hoàn toàn.

Tài khoản Apple, khóa API `codemagic` và chứng chỉ Apple Distribution **dùng chung với MemoMate**.
Mã app, provisioning profile và app trên App Store Connect thì phải tạo mới cho `com.phenv.rotday`.

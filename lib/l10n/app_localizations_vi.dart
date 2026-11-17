// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Rót Đầy';

  @override
  String get appTagline => 'Giữ để rót. Thả tay đúng vạch.';

  @override
  String get modeDaily => 'Ly hôm nay';

  @override
  String get modeDailySub => 'Một ly, ai cũng rót chung, chỉ một lần';

  @override
  String get modeEndless => 'Rót liên tục';

  @override
  String get modeEndlessSub => 'Hết ly này sang ly khác, tới khi lệch vạch';

  @override
  String get modePractice => 'Tập rót';

  @override
  String get modePracticeSub => 'Rót bao nhiêu cũng được, không tính điểm';

  @override
  String dailyNumber(int number) {
    return 'Ly số $number';
  }

  @override
  String glassNumber(int number) {
    return 'Ly thứ $number';
  }

  @override
  String get holdToPour => 'Giữ tay vào đâu cũng rót được';

  @override
  String get letGoOnLine => 'Thả tay đúng vạch kẻ';

  @override
  String get pouring => 'Đang rót…';

  @override
  String get settling => 'Đang lắng…';

  @override
  String get ratingPerfect => 'Hoàn hảo';

  @override
  String get ratingGreat => 'Rất khéo';

  @override
  String get ratingGood => 'Tạm được';

  @override
  String get ratingMiss => 'Lệch vạch';

  @override
  String get ratingSpilled => 'Tràn rồi!';

  @override
  String offBy(String mm) {
    return 'Lệch $mm mm';
  }

  @override
  String offByShort(String mm) {
    return 'Thiếu $mm mm';
  }

  @override
  String offByOver(String mm) {
    return 'Quá $mm mm';
  }

  @override
  String get spilledOver => 'Nước trào qua miệng ly';

  @override
  String get drinkTea => 'Trà đá';

  @override
  String get drinkCoffee => 'Cà phê';

  @override
  String get drinkSugarcane => 'Nước mía';

  @override
  String get drinkSmoothie => 'Sinh tố';

  @override
  String get drinkSoda => 'Nước ngọt';

  @override
  String get drinkBeer => 'Bia';

  @override
  String get shapeStraight => 'Ly thẳng';

  @override
  String get shapeFlared => 'Ly loe';

  @override
  String get shapeTapered => 'Ly thóp';

  @override
  String get shapeTulip => 'Ly bầu';

  @override
  String get shapeHourglass => 'Ly thắt';

  @override
  String get shapeBowl => 'Ly tròn';

  @override
  String get playAgain => 'Rót lại';

  @override
  String get nextGlass => 'Ly tiếp';

  @override
  String get backHome => 'Về trang chính';

  @override
  String get copyResult => 'Chép kết quả';

  @override
  String get copied => 'Đã chép. Dán vào đâu cũng được.';

  @override
  String get comeBackTomorrow => 'Mai quay lại có ly mới.';

  @override
  String get alreadyPlayed => 'Bạn đã rót ly hôm nay rồi.';

  @override
  String get yourResult => 'Kết quả của bạn';

  @override
  String get runOver => 'Hết lượt';

  @override
  String runGlasses(int count) {
    return '$count ly';
  }

  @override
  String runPoints(int points) {
    return '$points điểm';
  }

  @override
  String get newRecord => 'Kỷ lục mới!';

  @override
  String streakOf(int count) {
    return '$count ly liền';
  }

  @override
  String toleranceNow(String mm) {
    return 'Phải lệch dưới $mm mm mới được đi tiếp';
  }

  @override
  String get statsTitle => 'Thành tích';

  @override
  String get statsPoured => 'Số ly đã rót';

  @override
  String get statsPerfect => 'Lần rót hoàn hảo';

  @override
  String get statsSpills => 'Số lần tràn';

  @override
  String get statsBestRun => 'Lượt dài nhất';

  @override
  String get statsBestPoints => 'Điểm cao nhất';

  @override
  String get statsDailyStars => 'Sao từ ly hôm nay';

  @override
  String get statsStreak => 'Số ngày liên tục';

  @override
  String get statsDrinks => 'Loại nước đã rót';

  @override
  String get statsShapes => 'Kiểu ly đã rót';

  @override
  String get statsNothingYet => 'Rót một ly là thành tích hiện ra ở đây.';

  @override
  String get medalsTitle => 'Huy chương';

  @override
  String medalsEarned(int won, int total) {
    return 'Được $won trên $total';
  }

  @override
  String get medalWon => 'Được huy chương!';

  @override
  String get medalFirstPour => 'Ly đầu tiên';

  @override
  String get medalFirstPourHow => 'Rót xong một ly';

  @override
  String get medalFirstPerfect => 'Đúng vạch';

  @override
  String get medalFirstPerfectHow => 'Lệch dưới 1 mm';

  @override
  String get medalThreePerfect => 'Tay chắc';

  @override
  String get medalThreePerfectHow => 'Lệch dưới 1 mm ba lần';

  @override
  String get medalFiveInARow => 'Đang lên tay';

  @override
  String get medalFiveInARowHow => 'Năm ly liền không lệch trong một lượt';

  @override
  String get medalTenGlasses => 'Mười ly';

  @override
  String get medalTenGlassesHow => 'Rót mười ly trong một lượt';

  @override
  String get medalTwentyGlasses => 'Thợ pha chế';

  @override
  String get medalTwentyGlassesHow => 'Rót hai mươi ly trong một lượt';

  @override
  String get medalEveryDrink => 'Đủ món';

  @override
  String get medalEveryDrinkHow => 'Rót qua tất cả các loại nước';

  @override
  String get medalEveryShape => 'Đủ ly';

  @override
  String get medalEveryShapeHow => 'Rót qua tất cả các kiểu ly';

  @override
  String get medalWeekStreak => 'Bảy ngày';

  @override
  String get medalWeekStreakHow => 'Chơi ly hôm nay bảy ngày liền';

  @override
  String get medalNoSpillRun => 'Không rớt giọt nào';

  @override
  String get medalNoSpillRunHow => 'Năm ly trong một lượt mà không tràn';

  @override
  String get howToTitle => 'Cách chơi';

  @override
  String get howToHoldTitle => 'Giữ rồi thả';

  @override
  String get howToHoldBody =>
      'Ấn tay vào màn hình là nước chảy. Thả tay là ngừng. Mỗi ly chỉ được giữ một lần.';

  @override
  String get howToTrailTitle => 'Thả tay rồi nước vẫn chảy';

  @override
  String get howToTrailBody =>
      'Phần nước đang lơ lửng vẫn rơi xuống sau khi bạn thả tay, nên phải thả sớm hơn vạch một chút. Nước càng đặc thì rơi càng dai.';

  @override
  String get howToFoamTitle => 'Bọt sẽ thành nước';

  @override
  String get howToFoamBody =>
      'Bia và nước ngọt nổi bọt, và khoảng một phần tư lớp bọt đó lắng xuống thành nước. Nước nào nhiều bọt thì phải nhắm thấp hơn.';

  @override
  String get howToShapeTitle => 'Hình ly đổi hết mọi thứ';

  @override
  String get howToShapeBody =>
      'Ly tròn thì mấy giọt đầu gần như không thấy gì, rồi mực nước vọt lên. Ly thắt thì khúc giữa đầy nhanh nhất. Nhìn ly trước khi rót.';

  @override
  String get howToScoreTitle => 'Cách tính';

  @override
  String get howToScoreBody =>
      'Lệch dưới 1 mm là hoàn hảo, dưới 3 mm là rất khéo, dưới 7 mm là tạm được. Trào qua miệng ly là mất ly đó. Ở chế độ rót liên tục, mức cho phép hẹp dần theo từng ly.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSound => 'Âm thanh';

  @override
  String get settingsSoundSub => 'Tiếng tách khi rót và khi xong một ly';

  @override
  String get settingsHaptics => 'Rung';

  @override
  String get settingsHapticsSub => 'Rung nhẹ trong lúc nước đang chảy';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSystem => 'Theo máy';

  @override
  String get settingsAbout => 'Về app';

  @override
  String get settingsPrivacy =>
      'Không tài khoản, không quảng cáo, không theo dõi. Mọi thứ bạn rót chỉ lưu trên máy này.';

  @override
  String settingsVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String shareLine(int number, String emoji) {
    return 'Rót Đầy #$number $emoji';
  }

  @override
  String get shareSpilled => '💦 Tràn mất';

  @override
  String shareError(String emoji, String mm) {
    return '$emoji Lệch $mm mm';
  }
}

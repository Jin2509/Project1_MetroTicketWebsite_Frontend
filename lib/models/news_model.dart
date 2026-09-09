import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class NewsArticle {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String date;
  final String readTime;
  final String author;
  final List<Color> gradientColors;
  final PhosphorIconData icon;
  final String keyTakeaway;
  final List<String> contentParagraphs;
  final List<String> commuterTips;
  final bool isFeatured;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.date,
    required this.readTime,
    required this.author,
    required this.gradientColors,
    required this.icon,
    required this.keyTakeaway,
    required this.contentParagraphs,
    required this.commuterTips,
    this.isFeatured = false,
  });
}

class NewsData {
  static const List<NewsArticle> articles = [
    NewsArticle(
      id: 'art-1',
      title: 'Tuyến Metro Số 1 (Bến Thành – Suối Tiên) chính thức vận hành thương mại toàn tuyến',
      subtitle:
          'TP. Hồ Chí Minh chính thức khai trương hành lang giao thông công cộng hiện đại, kết nối Quận 1 với TP. Thủ Đức chỉ trong 32 phút.',
      category: 'Cập nhật tuyến',
      date: '14/10/2026',
      readTime: '4 phút đọc',
      author: 'Ban Quản lý Đường sắt Đô thị & MetroGo',
      gradientColors: [Color(0xFF2F6FED), Color(0xFF1E4DB7)],
      icon: PhosphorIconsRegular.train,
      isFeatured: true,
      keyTakeaway:
          'Tuyến số 1 gồm 14 nhà ga (3 ga ngầm, 11 ga trên cao), hoạt động từ 05:00 đến 22:00 hàng ngày với tần suất 5 phút/chuyến vào giờ cao điểm.',
      contentParagraphs: [
        'Hôm nay đánh dấu cột mốc lịch sử đối với giao thông đô thị TP. Hồ Chí Minh khi Tuyến Metro Số 1 chính thức mở cửa đón hành khách rộng rãi. Với chiều dài gần 20 km từ ga ngầm Bến Thành đến bến xe Suối Tiên, đoàn tàu điện tốc độ cao hứa hẹn thay đổi hoàn toàn thói quen đi lại hàng ngày.',
        'Hành khách giờ đây chỉ mất 26 phút để di chuyển từ trung tâm Quận 1 đến Khu Công nghệ cao TP. Thủ Đức, không còn nỗi lo kẹt xe trên xa lộ Hà Nội. Các đoàn tàu vận hành tự động với hệ thống tín hiệu an toàn hiện đại, điều hòa liên tục và khoang dành riêng cho người khuyết tật.',
        'Hệ thống cổng soát vé tự động chấp nhận quét mã QR trên ứng dụng MetroGo, thẻ từ thông minh NFC và ví điện tử, giúp tiết kiệm thời gian xếp hàng mua vé tại nhà ga.',
      ],
      commuterTips: [
        'Các ga ngầm (Bến Thành, Nhà hát Thành phố, Ba Son) có lối đi bộ ngầm kết nối trực tiếp với trung tâm thương mại lân cận.',
        'Wi-Fi miễn phí được phủ sóng tại toàn bộ 14 nhà ga và trên tất cả các toa tàu.',
        'Giờ cao điểm từ 06:30–08:30 và 16:30–19:00 với tần suất đón tàu 4.5 phút/chuyến.',
        'Bãi giữ xe máy, xe đạp và các tuyến xe buýt gom kết nối đã sẵn sàng tại các ga trên cao.',
      ],
    ),
    NewsArticle(
      id: 'art-2',
      title: 'Hướng dẫn chi tiết quét mã QR qua cổng soát vé tự động MetroGo',
      subtitle:
          'Trải nghiệm ra vào ga nhanh chóng, không chạm tại tất cả các cổng tự động với mã QR tăng sáng và chạm NFC.',
      category: 'Cẩm nang đi lại',
      date: '12/10/2026',
      readTime: '3 phút đọc',
      author: 'Đội ngũ Trải nghiệm Khách hàng',
      gradientColors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      icon: PhosphorIconsRegular.qrCode,
      keyTakeaway:
          'Đưa mã QR trên màn hình MetroGo cách mặt kính quét quang học khoảng 10cm ở phía bên tay phải của cổng kiểm soát.',
      contentParagraphs: [
        'Việc vào và ra khỏi các ga MetroGo hoàn toàn dễ dàng với mã QR động. Khi mở vé điện tử trên ứng dụng, độ sáng màn hình điện thoại sẽ tự động tối ưu để cảm biến laser quét nhanh chóng.',
        'Cả vé lượt và vé tháng không giới hạn đều tạo mã token được mã hóa theo thời gian thực, bảo vệ tài khoản khỏi chia sẻ trái phép và đảm bảo thời gian mở cổng dưới 0.2 giây.',
        'Lưu ý hành khách cần quét cùng một mã QR ở cả ga đi và ga đến để hệ thống tính toán chính xác hành trình của bạn.',
      ],
      commuterTips: [
        'Mở sẵn màn hình mã QR trên điện thoại trước khi tiến vào làn cổng soát vé.',
        'Giữ khoảng cách điện thoại từ 8cm đến 15cm so với mặt kính cảm biến nghiêng.',
        'Đối với chủ vé tháng, có thể ghim widget MetroGo lên màn hình khóa để mở vé tức thì.',
      ],
    ),
    NewsArticle(
      id: 'art-3',
      title: 'Ưu đãi giảm 50% giá vé cho học sinh, sinh viên: Đăng ký trực tuyến trên MetroGo',
      subtitle:
          'Học sinh, sinh viên các trường đại học, cao đẳng và THPT trên địa bàn TP.HCM được hưởng mức giá vé tháng chỉ bằng 50%.',
      category: 'Ưu đãi',
      date: '10/10/2026',
      readTime: '3 phút đọc',
      author: 'Chương trình Hỗ trợ Học sinh - Sinh viên',
      gradientColors: [Color(0xFF10B981), Color(0xFF047857)],
      icon: PhosphorIconsRegular.graduationCap,
      keyTakeaway:
          'Sinh viên đã xác thực chỉ phải trả 130.000 đ / tháng để đi lại không giới hạn trên toàn bộ mạng lưới metro.',
      contentParagraphs: [
        'Phối hợp cùng Sở Giáo dục & Đào tạo, MetroGo triển khai chính sách trợ giá vé phương tiện công cộng cho giới trẻ. Học sinh, sinh viên toàn thành phố được giảm 50% khi mua vé tháng không giới hạn.',
        'Thủ tục xác thực chỉ mất chưa đầy 2 phút ngay trong mục Tài khoản trên ứng dụng MetroGo bằng cách chụp ảnh thẻ học sinh - sinh viên còn hiệu lực hoặc liên kết tài khoản định danh VNeID.',
        'Sau khi duyệt thành công, mức giá ưu đãi sẽ tự động áp dụng khi bạn đặt vé hoặc tra cứu bảng giá.',
      ],
      commuterTips: [
        'Đảm bảo ảnh chụp thẻ sinh viên rõ họ tên, mã số sinh viên và năm học hiện tại.',
        'Thời gian xét duyệt hồ sơ thông thường chỉ trong vòng 15 phút trong giờ hành chính.',
        'Ưu đãi có giá trị 12 tháng kể từ ngày xác thực và có thể gia hạn hàng năm.',
      ],
    ),
    NewsArticle(
      id: 'art-4',
      title: 'Nhà ga Trung tâm Bến Thành: Điểm kết nối tương lai với Tuyến Metro Số 2',
      subtitle:
          'Khám phá không gian ngầm 4 tầng hiện đại bậc nhất khu vực, kết nối đồng bộ Tuyến 1, 2, 3A và 4.',
      category: 'Cập nhật tuyến',
      date: '07/10/2026',
      readTime: '5 phút đọc',
      author: 'Nhóm Kỹ thuật Metro',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      icon: PhosphorIconsRegular.gitBranch,
      keyTakeaway:
          'Tầng B1 là khu thương mại và sảnh đón khách bán vé, trong khi các tầng B2, B3 và B4 phục vụ đón trả khách các tuyến đường sắt.',
      contentParagraphs: [
        'Với diện tích hơn 45.000 m² dưới lòng đất khu vực Công viên 23/9 và Quảng trường Quách Thị Trang, Ga Trung tâm Bến Thành là nút giao đường sắt ngầm quy mô lớn hàng đầu Đông Nam Á.',
        'Được thiết kế là đầu mối trung chuyển đa tuyến, hành khách tương lai sẽ chuyển tuyến thuận tiện giữa Tuyến 1 (Suối Tiên) và Tuyến 2 (Tham Lương) mà không cần ra ngoài cổng soát vé.',
        'Ánh sáng tự nhiên được dẫn truyền qua giếng trời kính hình tròn đường kính 6m xuống sảnh trung tâm, tạo không gian thoáng đãng và tiết kiệm năng lượng chiếu sáng ban ngày.',
      ],
      commuterTips: [
        'Sử dụng Lối vào số 1 (phía đường Lê Lợi) để đi thang cuốn thẳng tới khu quầy vé.',
        'Tủ gửi đồ tự động và phòng chăm sóc trẻ nhỏ được bố trí gần Cổng B tại Tầng B1.',
        'Hành lang ngầm kết nối trực tiếp đến khu phố mua sắm ngầm và trạm xe buýt trung tâm.',
      ],
    ),
    NewsArticle(
      id: 'art-5',
      title: 'Dấu ấn giao thông xanh: Hành khách MetroGo góp phần giảm 120 tấn CO₂ trong tháng đầu',
      subtitle:
          'Dữ liệu cho thấy xu hướng chuyển đổi tích cực từ xe máy cá nhân sang đường sắt điện dọc hành lang xa lộ Hà Nội.',
      category: 'Môi trường xanh',
      date: '04/10/2026',
      readTime: '3 phút đọc',
      author: 'Hội đồng Phát triển Giao thông Xanh',
      gradientColors: [Color(0xFF059669), Color(0xFF065F46)],
      icon: PhosphorIconsRegular.leaf,
      keyTakeaway:
          'Đi một chuyến tàu điện thay cho xe máy cá nhân giúp giảm tới 82% lượng phát thải carbon trên cùng hành trình.',
      contentParagraphs: [
        'Trong tháng đầu tiên vận hành, hơn 1.2 triệu lượt hành khách đã di chuyển trên Tuyến Metro Số 1. Kết quả giám sát môi trường ghi nhận giảm hơn 120 tấn khí thải CO₂ dọc trục giao thông phía đông.',
        'Sử dụng nguồn điện sạch qua các trạm biến áp tân tiến, MetroGo tự hào đồng hành cùng mục tiêu phát thải ròng bằng 0 (Net Zero) vào năm 2050 của TP. Hồ Chí Minh.',
        'Tính năng sắp ra mắt trên ứng dụng MetroGo: theo dõi chỉ số tiết kiệm phát thải carbon cá nhân sau mỗi hành trình di chuyển.',
      ],
      commuterTips: [
        'Theo dõi huy hiệu tiết kiệm CO₂ hàng tuần ngay trong trang cá nhân của bạn.',
        'Kết hợp đi metro cùng các trạm xe đạp điện công cộng được bố trí quanh mỗi nhà ga.',
      ],
    ),
  ];
}

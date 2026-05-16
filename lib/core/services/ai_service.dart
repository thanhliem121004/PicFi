import 'dart:math';
import '../../core/constants/app_strings.dart';
import '../../core/constants/expense_categories.dart';

class AIService {
  static const _responses = {
    'xin chào': 'Chào bạn! Tôi là trợ lý tài chính PicFi. Tôi có thể giúp gì cho bạn?',
    'tôi đã tiêu bao nhiêu': 'Bạn có thể kiểm tra tổng chi tiêu trong tab Thống kê. Tôi sẽ giúp bạn phân tích chi tiêu!',
    'làm sao để tiết kiệm': 'Bạn có thể thử đặt ngân sách cho từng danh mục, theo dõi chi tiêu hàng ngày và hạn chế các khoản chi không cần thiết.',
    'chi tiêu nhiều nhất': 'Hãy kiểm tra biểu đồ danh mục trong phần Thống kê để xem khoản chi lớn nhất của bạn.',
    'cà phê': 'Cà phê là khoản chi nhỏ nhưng nếu uống hàng ngày sẽ thành một khoản lớn. Hãy thử giới hạn 3 ly/tuần!',
    'ăn uống': 'Chi phí ăn uống thường chiếm 30-40% tổng chi tiêu. Hãy đặt ngân sách cụ thể cho danh mục này.',
    'mua sắm': 'Trước khi mua sắm, hãy tự hỏi: "Mình có thực sự cần nó không?" và chờ 24h trước khi quyết định.',
    'hóa đơn': 'Hãy đặt nhắc nhở thanh toán hóa đơn đúng hạn để tránh phí phạt. Tôi có thể giúp bạn theo dõi!',
    'tiết kiệm': 'Quy tắc 50/30/20: 50% cho nhu cầu, 30% cho mong muốn, 20% cho tiết kiệm. Hãy thử áp dụng!',
    'ngân sách': 'Đặt ngân sách là bước đầu tiên để quản lý tài chính. Bắt đầu với 3-5 danh mục chính.',
  };

  static final Random _random = Random();

  Future<String> chatWithAI(String message) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    final lowerMsg = message.toLowerCase();
    for (final entry in _responses.entries) {
      if (lowerMsg.contains(entry.key)) {
        return entry.value;
      }
    }

    final defaultResponses = [
      'Tôi hiểu. Bạn có thể cho tôi biết thêm chi tiết để tôi phân tích kỹ hơn?',
      'Cảm ơn bạn đã chia sẻ! Tôi sẽ ghi nhớ thông tin này để phân tích chi tiêu.',
      'Thông tin hữu ích! Bạn có muốn tôi đề xuất cách tiết kiệm cho khoản này không?',
      'Tôi đã ghi nhận. Hãy tiếp tục theo dõi chi tiêu hàng ngày để quản lý tài chính tốt hơn.',
      'Rất tốt! Bạn có muốn xem báo cáo chi tiết về khoản chi này không?',
    ];
    return defaultResponses[_random.nextInt(defaultResponses.length)];
  }

  Future<ExpenseCategory> autoCategorizeExpense(String note, double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final lowerNote = note.toLowerCase();

    if (lowerNote.contains('ăn') || lowerNote.contains('cơm') || lowerNote.contains('phở') ||
        lowerNote.contains('bún') || lowerNote.contains('bánh') || lowerNote.contains('trưa') ||
        lowerNote.contains('tối') || lowerNote.contains('sáng') || lowerNote.contains('lẩu') ||
        lowerNote.contains('lotte') || lowerNote.contains('food') || lowerNote.contains('quán')) {
      return ExpenseCategory.food;
    }
    if (lowerNote.contains('cà phê') || lowerNote.contains('coffee') || lowerNote.contains('trà') ||
        lowerNote.contains('highlands') || lowerNote.contains('starbucks') || lowerNote.contains('katinat')) {
      return ExpenseCategory.coffee;
    }
    if (lowerNote.contains('xe') || lowerNote.contains('xăng') || lowerNote.contains('bus') ||
        lowerNote.contains('grab') || lowerNote.contains('taxi') || lowerNote.contains('đổ') ||
        lowerNote.contains('bảo dưỡng') || lowerNote.contains('vận chuyển')) {
      return ExpenseCategory.transport;
    }
    if (lowerNote.contains('mua') || lowerNote.contains('shop') || lowerNote.contains('quần') ||
        lowerNote.contains('áo') || lowerNote.contains('giày') || lowerNote.contains('túi') ||
        lowerNote.contains('mỹ phẩm')) {
      return ExpenseCategory.shopping;
    }
    if (lowerNote.contains('phim') || lowerNote.contains('game') || lowerNote.contains('xem') ||
        lowerNote.contains('concert') || lowerNote.contains('du lịch') || lowerNote.contains('bar') ||
        lowerNote.contains('bia')) {
      return ExpenseCategory.entertainment;
    }
    if (lowerNote.contains('học') || lowerNote.contains('sách') || lowerNote.contains('khóa') ||
        lowerNote.contains('lớp') || lowerNote.contains('trung tâm') || lowerNote.contains('đào tạo')) {
      return ExpenseCategory.education;
    }
    if (lowerNote.contains('khám') || lowerNote.contains('bệnh') || lowerNote.contains('thuốc') ||
        lowerNote.contains('viện') || lowerNote.contains('sức khỏe') || lowerNote.contains('doctor')) {
      return ExpenseCategory.health;
    }
    if (lowerNote.contains('quà') || lowerNote.contains('tặng') || lowerNote.contains('sinh nhật') ||
        lowerNote.contains('valentine') || lowerNote.contains('noel')) {
      return ExpenseCategory.gift;
    }
    if (lowerNote.contains('điện thoại') || lowerNote.contains('laptop') || lowerNote.contains('công nghệ') ||
        lowerNote.contains('máy tính') || lowerNote.contains('phone') || lowerNote.contains('ipad') ||
        lowerNote.contains('apple')) {
      return ExpenseCategory.tech;
    }
    if (lowerNote.contains('nhà') || lowerNote.contains('thuê') || lowerNote.contains('chung cư') ||
        lowerNote.contains('điện') || lowerNote.contains('nước') || lowerNote.contains('sửa')) {
      return ExpenseCategory.housing;
    }
    if (lowerNote.contains('hóa đơn') || lowerNote.contains('bill') || lowerNote.contains('điện thoại') ||
        lowerNote.contains('internet') || lowerNote.contains('truyền hình')) {
      return ExpenseCategory.bills;
    }

    return ExpenseCategory.other;
  }

  Future<Map<String, dynamic>> scanReceiptOCR(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final random = _random.nextInt(5);
    final amounts = [45000, 120000, 320000, 85000, 250000];
    final categories = [
      ExpenseCategory.food,
      ExpenseCategory.shopping,
      ExpenseCategory.entertainment,
      ExpenseCategory.transport,
      ExpenseCategory.coffee,
    ];
    final stores = ['VinMart', 'Shopee', 'CGV Cinemas', 'Grab', 'Highlands Coffee'];
    final dates = [
      DateTime.now(),
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now(),
    ];

    return {
      'amount': amounts[random],
      'category': categories[random],
      'store': stores[random],
      'date': dates[random],
      'confidence': 0.85 + _random.nextDouble() * 0.15,
    };
  }

  Future<String> getSpendingInsights(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final insights = [
      'Bạn đã chi tiêu nhiều hơn 15% so với tháng trước trong danh mục Ăn uống. Hãy thử nấu ăn tại nhà để tiết kiệm!',
      'Danh mục Di chuyển của bạn tăng 20% trong tuần này. Cân nhắc sử dụng phương tiện công cộng thay vì Grab.',
      'Xin chúc mừng! Bạn đã tiết kiệm được 12% so với ngân sách tháng này. Hãy duy trì nhé!',
      'Bạn có xu hướng chi tiêu nhiều vào cuối tuần. Hãy lên kế hoạch trước cho các hoạt động cuối tuần.',
      'Phát hiện: Bạn chi tiêu cho Cà phê nhiều gấp đôi bạn bè cùng lứa. Hãy thử giới hạn 2 ly/tuần!',
    ];

    return insights[_random.nextInt(insights.length)];
  }
}

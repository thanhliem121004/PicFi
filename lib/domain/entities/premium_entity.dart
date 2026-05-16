enum PremiumStatus { active, inactive, expired, cancelled }

enum PremiumPlan { monthly, yearly, lifetime }

enum PremiumFeatures {
  aiChatbot,
  autoCategorize,
  ocrScanning,
  advancedAnalytics,
  customThemes,
  noAds,
  exportCSV,
  smartNotifications,
}

extension PremiumFeaturesLabel on PremiumFeatures {
  String get label {
    switch (this) {
      case PremiumFeatures.aiChatbot:
        return 'AI Trợ lý tài chính';
      case PremiumFeatures.autoCategorize:
        return 'Tự động phân loại';
      case PremiumFeatures.ocrScanning:
        return 'Quét hóa đơn OCR';
      case PremiumFeatures.advancedAnalytics:
        return 'Phân tích nâng cao';
      case PremiumFeatures.customThemes:
        return 'Giao diện tùy chỉnh';
      case PremiumFeatures.noAds:
        return 'Không quảng cáo';
      case PremiumFeatures.exportCSV:
        return 'Xuất CSV/Excel';
      case PremiumFeatures.smartNotifications:
        return 'Thông báo thông minh';
    }
  }
}

extension PremiumPlanLabel on PremiumPlan {
  String get label {
    switch (this) {
      case PremiumPlan.monthly:
        return 'Hàng tháng';
      case PremiumPlan.yearly:
        return 'Hàng năm';
      case PremiumPlan.lifetime:
        return 'Trọn đời';
    }
  }
}

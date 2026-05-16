import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/constants/expense_categories.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

class OcrResult extends Equatable {
  final double amount;
  final ExpenseCategory category;
  final String store;
  final DateTime date;
  final double confidence;

  const OcrResult({
    required this.amount,
    required this.category,
    required this.store,
    required this.date,
    required this.confidence,
  });

  @override
  List<Object?> get props => [amount, category, store, date, confidence];
}

class AIState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ExpenseCategory? suggestedCategory;
  final OcrResult? ocrResult;
  final String? insights;
  final String? error;

  const AIState({
    this.messages = const [],
    this.isLoading = false,
    this.suggestedCategory,
    this.ocrResult,
    this.insights,
    this.error,
  });

  AIState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ExpenseCategory? suggestedCategory,
    OcrResult? ocrResult,
    String? insights,
    String? error,
    bool clearSuggested = false,
    bool clearOcr = false,
    bool clearInsights = false,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      suggestedCategory: clearSuggested ? null : (suggestedCategory ?? this.suggestedCategory),
      ocrResult: clearOcr ? null : (ocrResult ?? this.ocrResult),
      insights: clearInsights ? null : (insights ?? this.insights),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, suggestedCategory, ocrResult, insights, error];
}

class AICubit extends Cubit<AIState> {
  final AIService _service = AIService();

  AICubit() : super(const AIState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now());
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    ));

    try {
      final response = await _service.chatWithAI(text);
      final aiMessage = ChatMessage(text: response, isUser: false, timestamp: DateTime.now());
      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  Future<void> autoCategorize(String note, double amount) async {
    emit(state.copyWith(isLoading: true));
    try {
      final category = await _service.autoCategorizeExpense(note, amount);
      emit(state.copyWith(isLoading: false, suggestedCategory: category));

      final msg = ChatMessage(
        text: 'Gợi ý danh mục cho "${note.length > 30 ? "${note.substring(0, 30)}..." : note}": ${category.label}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(messages: [...state.messages, msg]));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  Future<void> scanReceipt(String imagePath) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _service.scanReceiptOCR(imagePath);
      emit(state.copyWith(
        isLoading: false,
        ocrResult: OcrResult(
          amount: result['amount'] as double,
          category: result['category'] as ExpenseCategory,
          store: result['store'] as String,
          date: result['date'] as DateTime,
          confidence: result['confidence'] as double,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  Future<void> getInsights(String userId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final insights = await _service.getSpendingInsights(userId);
      emit(state.copyWith(isLoading: false, insights: insights));

      final msg = ChatMessage(text: insights, isUser: false, timestamp: DateTime.now());
      emit(state.copyWith(messages: [...state.messages, msg]));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  void clearOcrResult() {
    emit(state.copyWith(clearOcr: true));
  }

  void clearMessages() {
    emit(state.copyWith(messages: []));
  }
}

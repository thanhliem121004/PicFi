import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState extends Equatable {
  final String localeCode;

  const LocaleState({this.localeCode = 'vi'});

  LocaleState copyWith({String? localeCode}) {
    return LocaleState(localeCode: localeCode ?? this.localeCode);
  }

  @override
  List<Object?> get props => [localeCode];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState()) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'vi';
    emit(state.copyWith(localeCode: code));
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    emit(state.copyWith(localeCode: code));
  }
}

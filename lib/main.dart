import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'l10n/l10n.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/expense/expense_cubit.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/budget/budget_cubit.dart';
import 'presentation/blocs/friends/friends_cubit.dart';
import 'presentation/blocs/recurring/recurring_cubit.dart';
import 'presentation/blocs/savings/savings_goal_cubit.dart';
import 'presentation/blocs/backup/backup_cubit.dart';
import 'presentation/blocs/locale/locale_cubit.dart';
import 'presentation/blocs/premium/premium_cubit.dart';
import 'presentation/blocs/ai/ai_cubit.dart';
import 'presentation/blocs/analytics/advanced_analytics_cubit.dart';
import 'presentation/blocs/connectivity/connectivity_cubit.dart';
import 'presentation/blocs/lock/lock_cubit.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/utils/performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ImageCacheManager.configure();

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  await NotificationService.init(scaffoldMessengerKey);
  await OfflineService.instance.init();
  DeepLinkService.instance.init();

  runApp(PicFiApp(scaffoldMessengerKey: scaffoldMessengerKey));
}

class PicFiApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const PicFiApp({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ExpenseCubit()),
        BlocProvider(create: (_) => BudgetCubit()),
        BlocProvider(create: (_) => FriendsCubit()),
        BlocProvider(create: (_) => RecurringCubit()),
        BlocProvider(create: (_) => SavingsGoalCubit()),
        BlocProvider(create: (_) => BackupCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => PremiumCubit()),
        BlocProvider(create: (_) => AICubit()),
        BlocProvider(create: (_) => AdvancedAnalyticsCubit()),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(create: (_) => LockCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final localeState = context.watch<LocaleCubit>().state;
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: Locale(localeState.localeCode),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            routerConfig: AppRouter.router,
            scaffoldMessengerKey: scaffoldMessengerKey,
          );
        },
      ),
    );
  }
}

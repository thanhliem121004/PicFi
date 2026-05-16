import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/expense/expense_cubit.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/budget/budget_cubit.dart';
import 'presentation/blocs/friends/friends_cubit.dart';
import 'presentation/blocs/premium/premium_cubit.dart';
import 'presentation/blocs/ai/ai_cubit.dart';
import 'presentation/blocs/analytics/advanced_analytics_cubit.dart';
import 'presentation/blocs/connectivity/connectivity_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await Firebase.initializeApp();

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
        BlocProvider(create: (_) => PremiumCubit()),
        BlocProvider(create: (_) => AICubit()),
        BlocProvider(create: (_) => AdvancedAnalyticsCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            scaffoldMessengerKey: scaffoldMessengerKey,
          );
        },
      ),
    );
  }
}

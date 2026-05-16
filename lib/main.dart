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
import 'presentation/blocs/recurring/recurring_cubit.dart';
import 'presentation/blocs/savings/savings_goal_cubit.dart';
import 'presentation/blocs/backup/backup_cubit.dart';
import 'presentation/blocs/locale/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await Firebase.initializeApp();
  runApp(const PicFiApp());
}

class PicFiApp extends StatelessWidget {
  const PicFiApp({super.key});

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
          );
        },
      ),
    );
  }
}

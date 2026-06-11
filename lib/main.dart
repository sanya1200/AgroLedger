import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/core/theme/app_theme.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/pages/auth_flow_controller.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_event.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('offline_cache');
  
  // Initialize dependency injection (includes Dio, Storage, etc.)
  await initServiceLocator();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('kk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: const AgroLedgerApp(),
    ),
  );
}

class AgroLedgerApp extends StatelessWidget {
  const AgroLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<CalculatorBloc>(
          create: (context) => sl<CalculatorBloc>(),
        ),
        BlocProvider<MarketplaceBloc>(
          create: (context) => sl<MarketplaceBloc>(),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => sl<CalendarBloc>()..add(const LoadCalendarTasksEvent()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => sl<ChatBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'AgroLedger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // The Intelligent Gateway of the application
        home: const AuthFlowController(),
      ),
    );
  }
}

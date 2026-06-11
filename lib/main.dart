import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/core/theme/app_theme.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/pages/auth_flow_controller.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection (includes Dio, Storage, etc.)
  await initServiceLocator();
  
  runApp(const AgroLedgerApp());
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
      ],
      child: MaterialApp(
        title: 'AgroLedger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // The Intelligent Gateway of the application
        home: const AuthFlowController(),
      ),
    );
  }
}

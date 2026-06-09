import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/core/theme/app_theme.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/pages/auth_flow_controller.dart';

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
          create: (context) => sl<AuthBloc>(), // Event triggered in AuthFlowController
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

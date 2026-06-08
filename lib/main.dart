import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/pages/login_screen.dart';
import 'package:agroledger/features/calculator/presentation/pages/cycles_list_screen.dart';
import 'package:agroledger/features/marketplace/presentation/pages/catalog_screen.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';

void main() async {
  // Добавляем try-catch для отлова критических ошибок при старте
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initServiceLocator();
    runApp(const AgroLedgerApp());
  } catch (e) {
    debugPrint("CRITICAL STARTUP ERROR: $e");
    // Если всё совсем плохо, запускаем минимальное приложение с ошибкой
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Ошибка запуска: $e")))));
  }
}

class AgroLedgerApp extends StatelessWidget {
  const AgroLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(AuthCheckStatusRequested()),
      child: MaterialApp(
        title: 'AgroLedger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[800]!),
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainNavigationScreen();
        } else if (state is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const CatalogScreen(),
    const CyclesListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<MarketplaceBloc>()),
        BlocProvider(create: (context) => sl<CalculatorBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.green[800],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Маркет'),
            BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Калькулятор'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final email = state is AuthAuthenticated ? state.user.email : "Гость";
        return Scaffold(
          appBar: AppBar(title: const Text('Профиль')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                Text(email, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
                  child: const Text('Выйти из аккаунта'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

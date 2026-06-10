import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/pages/catalog_screen.dart';
import 'package:agroledger/features/calculator/presentation/pages/calculator_dashboard_screen.dart';
import 'package:agroledger/features/home/presentation/pages/profile_screen.dart';
import 'package:agroledger/features/home/presentation/pages/home_screen.dart';
import 'package:agroledger/features/home/presentation/pages/help_support_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final List<Widget> pages = [
          HomeScreen(
            onNavigateToCalculator: () => setState(() => _currentIndex = 1),
            onNavigateToMarket: () => setState(() => _currentIndex = 2),
            onNavigateToHelp: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          const CalculatorDashboardScreen(),
          const CatalogScreen(),
          const ProfileScreen(),
        ];

        if (_currentIndex >= pages.length) _currentIndex = 0;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Главная',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: 'Калькулятор',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Маркет',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        );
      },
    );
  }
}

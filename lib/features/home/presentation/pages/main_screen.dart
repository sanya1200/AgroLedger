import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:agroledger/features/marketplace/presentation/pages/catalog_screen.dart';
import 'package:agroledger/features/calculator/presentation/pages/cycles_list_screen.dart';
import 'package:agroledger/features/home/presentation/pages/profile_screen.dart';
import 'package:agroledger/core/theme/app_colors.dart';

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

        final bool isFarmer = user.role == 'farmer_business';
        
        final List<Widget> pages = isFarmer 
          ? [const CyclesListScreen(), const CatalogScreen(), const ProfileScreen()]
          : [const CatalogScreen(), const ProfileScreen()];

        if (_currentIndex >= pages.length) _currentIndex = 0;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: [
              if (isFarmer)
                const NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Учет',
                ),
              const NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Маркет',
              ),
              const NavigationDestination(
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

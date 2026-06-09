import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/router/smooth_page_route.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Умный учет',
      description: 'Автоматизируйте учет циклов, кормов и расходов вашего хозяйства в один клик.',
      icon: Icons.analytics_outlined,
    ),
    OnboardingData(
      title: 'Прямой маркетплейс',
      description: 'Продавайте продукцию оптом и в розницу без посредников и лишних комиссий.',
      icon: Icons.storefront_outlined,
    ),
    OnboardingData(
      title: 'Абсолютная безопасность',
      description: 'Ваши данные под защитой финтех-стандартов. Безопасность — наш приоритет.',
      icon: Icons.security_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.sagePrimary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _pages[index].icon,
                            size: 100,
                            color: AppColors.sagePrimary,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _pages[index].description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMax.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicators and Button
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 48),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage == _pages.length - 1
                        ? ElevatedButton(
                            key: const ValueKey('start_btn'),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                SmoothPageRoute(page: const LoginScreen()),
                              );
                            },
                            child: const Text('Начать работу'),
                          )
                        : TextButton(
                            key: const ValueKey('next_btn'),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Далее'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.sagePrimary : AppColors.sageLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({required this.title, required this.description, required this.icon});
}

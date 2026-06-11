import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/auth/presentation/pages/pin_code_screen.dart';
import 'package:agroledger/features/home/presentation/pages/business_setup_screen.dart';
import 'package:agroledger/features/home/presentation/pages/premium_hub_screen.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _avatarEmoji = "🐮";
  String _preferredCurrency = "₸";
  int _verificationStep = 0; // 0 = idle, 1 = request, 2 = binary check, 3 = complete

  final List<String> _avatars = ["🐮", "🐑", "🐔", "🐝", "🐴", "🐰", "🐷", "🚜", "🌾", "👤"];
  final List<String> _currencies = ["₸", "₽", "\$"];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _fetchStats();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarEmoji = prefs.getString('selected_avatar') ?? "🐮";
      _preferredCurrency = prefs.getString('preferred_currency') ?? "₸";
    });
  }

  Future<void> _savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _fetchStats() {
    final calcState = context.read<CalculatorBloc>().state;
    if (calcState is CalculatorInitial) {
      context.read<CalculatorBloc>().add(const FetchCalculatorSummaryEvent());
    }
    final calendarState = context.read<CalendarBloc>().state;
    if (calendarState is CalendarInitial) {
      context.read<CalendarBloc>().add(const LoadCalendarTasksEvent());
    }
  }

  String _formatCurrency(double amount) {
    double converted = amount;
    String symbol = _preferredCurrency;
    if (_preferredCurrency == '₽') {
      converted = amount * 0.20;
    } else if (_preferredCurrency == '\$') {
      converted = amount * 0.0022;
    }
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return '${formatter.format(converted)} $symbol';
  }

  void _startVerification() async {
    setState(() => _verificationStep = 1);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _verificationStep = 2);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthVerifyUserRequested());
    setState(() => _verificationStep = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Поздравляем! Ваше хозяйство успешно верифицировано.'),
        backgroundColor: AppColors.sagePrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Выберите аватар хозяйства', style: AppTextStyles.h2),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final emoji = _avatars[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _avatarEmoji = emoji;
                      });
                      _savePreference('selected_avatar', emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.creamSurface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(UserModel user) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.creamBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Редактировать профиль', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedInputField(
                      controller: nameController,
                      label: 'ФИО',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    AnimatedInputField(
                      controller: phoneController,
                      label: 'Телефон',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      dropdownColor: AppColors.creamBackground,
                      decoration: InputDecoration(
                        labelText: 'Роль пользователя',
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.sagePrimary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.sageLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.sagePrimary, width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'farmer_business', child: Text('Фермер / Предприятие')),
                        DropdownMenuItem(value: 'customer_buyer', child: Text('Покупатель / Клиент')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      AuthUpdateSettingsRequested(
                        fullName: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        role: selectedRole,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    bool confirmDelete = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.creamBackground,
            title: const Text('Удаление аккаунта'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Вы уверены, что хотите полностью удалить свой аккаунт? Все ваши данные, включая записи в калькуляторе и товары на маркете, будут удалены безвозвратно.',
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: confirmDelete,
                  onChanged: (val) => setState(() => confirmDelete = val ?? false),
                  title: Text(
                    'Я понимаю, что мои данные будут безвозвратно удалены',
                    style: AppTextStyles.caption.copyWith(color: AppColors.errorSoft),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.errorSoft,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: confirmDelete
                    ? () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(AuthDeleteAccountRequested());
                      }
                    : null,
                child: Text('Удалить', style: TextStyle(color: confirmDelete ? AppColors.errorSoft : AppColors.textLight)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamBackground,
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.errorSoft)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Мой профиль'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(AuthCheckStatusRequested());
              _fetchStats();
            },
          )
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          // Map role name to localized user-friendly role
          final roleString = user.role == 'farmer_business'
              ? 'Фермер / Производитель'
              : 'Покупатель / Клиент';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Redesigned Premium Glassmorphic Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.sagePrimary, AppColors.sageDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sageDark.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              child: Text(
                                _avatarEmoji,
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.photo_camera_rounded, size: 14, color: AppColors.sageDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName ?? 'Анонимный пользователь',
                              style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(user),
                            child: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          roleString,
                          style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Verification status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            user.isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                            color: user.isVerified ? AppColors.accentGold : Colors.orangeAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.isVerified ? 'Верифицированный партнёр' : 'Требуется верификация',
                            style: AppTextStyles.caption.copyWith(
                              color: user.isVerified ? AppColors.accentGold : Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Premium Status Banner
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PremiumHubScreen()),
                    );
                  },
                  child: SoftCard(
                    color: user.isPremium ? AppColors.sagePrimary : AppColors.accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(
                          user.isPremium ? Icons.stars_rounded : Icons.star_border_rounded,
                          color: user.isPremium ? AppColors.accentGold : Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.isPremium ? 'AgroLedger Premium' : 'Активировать Premium',
                                style: AppTextStyles.bodyMax.copyWith(
                                  color: user.isPremium ? Colors.white : AppColors.sageDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.isPremium
                                    ? 'Активен до: ${user.premiumUntil != null ? DateFormat('dd.MM.yyyy').format(user.premiumUntil!) : '—'}'
                                    : 'ИИ-Ветеринар, безлимитные группы, PDF-отчёты',
                                style: AppTextStyles.caption.copyWith(
                                  color: user.isPremium ? Colors.white.withValues(alpha: 0.8) : AppColors.textDark.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: user.isPremium ? Colors.white : AppColors.sageDark,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Integrated Farm Statistics
                Text(
                  'Сводная статистика хозяйства',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Active Livestock Groups count
                    Expanded(
                      child: BlocBuilder<CalculatorBloc, CalculatorState>(
                        builder: (context, calcState) {
                          int activeGroupsCount = 0;
                          if (calcState is CalculatorSummaryLoaded) {
                            activeGroupsCount = calcState.assets.length;
                          }
                          return _buildStatMiniCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'Активных групп',
                            value: calcState is CalculatorLoading ? '...' : activeGroupsCount.toString(),
                            color: AppColors.sagePrimary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expected financial profit/balance
                    Expanded(
                      child: BlocBuilder<CalculatorBloc, CalculatorState>(
                        builder: (context, calcState) {
                          double netProfit = 0.0;
                          if (calcState is CalculatorSummaryLoaded) {
                            netProfit = calcState.summary.netProfit;
                          }
                          return _buildStatMiniCard(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Чистая прибыль',
                            value: calcState is CalculatorLoading ? '...' : _formatCurrency(netProfit),
                            color: AppColors.accentGold,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pending calendar tasks
                    Expanded(
                      child: BlocBuilder<CalendarBloc, CalendarState>(
                        builder: (context, calendarState) {
                          int tasksCount = 0;
                          if (calendarState is CalendarTasksLoaded) {
                            tasksCount = calendarState.tasks.where((t) => !t.isCompleted).length;
                          }
                          return _buildStatMiniCard(
                            icon: Icons.assignment_outlined,
                            title: 'Задач на уход',
                            value: calendarState is CalendarLoading ? '...' : tasksCount.toString(),
                            color: AppColors.errorSoft,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Farm Profile Setup & Stepper
                SoftCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront_outlined, color: AppColors.sagePrimary, size: 22),
                              const SizedBox(width: 8),
                              Text('Данные хозяйства', style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BusinessSetupScreen()),
                              );
                            },
                            child: Text(
                              user.hasBusinessProfile ? 'Редактировать' : 'Создать',
                              style: AppTextStyles.caption.copyWith(color: AppColors.sagePrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (user.hasBusinessProfile) ...[
                        _buildFarmInfoRow(Icons.business, 'Название', 'Хозяйство зарегистрировано'),
                        const SizedBox(height: 8),
                        Text(
                          'Полные данные можно проверить в меню «Редактировать».',
                          style: AppTextStyles.caption,
                        ),
                      ] else ...[
                        Text(
                          'Настройки профиля хозяйства не заполнены. Укажите БИН и регион для публикации товаров на Маркете.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                        ),
                      ],
                      if (!user.isVerified) ...[
                        const Divider(height: 24),
                        if (_verificationStep == 0)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _startVerification,
                              icon: const Icon(Icons.verified_user_outlined, size: 18),
                              label: const Text('Запустить верификацию хозяйства'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sagePrimary,
                              ),
                            ),
                          )
                        else ...[
                          Text(
                            _verificationStep == 1 ? 'Отправка запроса верификации...' : 'Проверка БИН в реестре...',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sagePrimary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStepIndicator(1, 'Запрос', _verificationStep >= 1),
                              _buildStepConnector(_verificationStep >= 2),
                              _buildStepIndicator(2, 'Реестр', _verificationStep >= 2),
                              _buildStepConnector(false),
                              _buildStepIndicator(3, 'Готово', false),
                            ],
                          ),
                        ]
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Contact Info Details
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.email_outlined,
                        title: 'Email почта',
                        subtitle: user.email,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Телефон',
                        subtitle: user.phone.isNotEmpty ? user.phone : 'Не указан',
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Дата регистрации',
                        subtitle: DateFormat('dd.MM.yyyy').format(user.createdAt),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 6. Security and Preferences Card
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.fingerprint,
                        title: 'Вход по биометрии',
                        subtitle: user.isBiometricEnabled ? 'Включена' : 'Выключена',
                        trailing: Switch(
                          value: user.isBiometricEnabled,
                          onChanged: (val) {
                            context.read<AuthBloc>().add(
                                  AuthUpdateSettingsRequested(
                                      isBiometricEnabled: val),
                                );
                          },
                          activeThumbColor: AppColors.sagePrimary,
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.lock_outline,
                        title: 'Изменить ПИН-код',
                        subtitle: 'Настройка быстрого входа в приложение',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PinCodeScreen(mode: PinMode.setup),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      // Currency choice
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.creamBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.monetization_on_outlined, color: AppColors.sageDark, size: 20),
                        ),
                        title: Text('Валюта расчетов', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                        subtitle: Text(
                          _preferredCurrency == '₸'
                              ? 'Казахстанский Тенге (₸)'
                              : _preferredCurrency == '₽'
                                  ? 'Российский Рубль (₽)'
                                  : 'Доллар США (\$)',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: DropdownButton<String>(
                          value: _preferredCurrency,
                          dropdownColor: AppColors.creamBackground,
                          underline: const SizedBox.shrink(),
                          items: _currencies.map((curr) {
                            return DropdownMenuItem<String>(
                              value: curr,
                              child: Text(curr, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _preferredCurrency = val;
                              });
                              _savePreference('preferred_currency', val);
                              // Force re-fetch stats calculations
                              context.read<CalculatorBloc>().add(const FetchCalculatorSummaryEvent());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 7. Danger Zone
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Удалить аккаунт',
                        subtitle: 'Безвозвратное удаление всех данных хозяйства',
                        textColor: AppColors.errorSoft,
                        onTap: _showDeleteAccountDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorSoft,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Выйти из системы'),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'AgroLedger v1.4.2 Premium',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatMiniCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.sageLight.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFarmInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
      ],
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.sagePrimary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.sageDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.sagePrimary : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? textColor;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? AppColors.sageDark, size: 20),
      ),
      title: Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: trailing,
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/widgets/category_selector_card.dart';
import 'package:agroledger/features/calculator/presentation/widgets/add_expense_sheet.dart';
import 'package:agroledger/features/calculator/presentation/widgets/add_yield_sheet.dart';
import 'package:agroledger/features/calculator/presentation/widgets/expenses_breakdown_chart.dart';
import 'package:agroledger/features/calculator/presentation/widgets/earnings_sources_section.dart';
import 'package:agroledger/features/calculator/domain/services/report_export_service.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/features/calculator/presentation/widgets/add_asset_sheet.dart';
import 'package:agroledger/features/calculator/data/models/predictive_forecast_model.dart';
import 'package:agroledger/features/calculator/presentation/widgets/premium_paywall_sheet.dart';

class CalculatorDashboardScreen extends StatefulWidget {
  const CalculatorDashboardScreen({super.key});

  @override
  State<CalculatorDashboardScreen> createState() =>
      _CalculatorDashboardScreenState();
}

class _CalculatorDashboardScreenState extends State<CalculatorDashboardScreen> {
  String? _selectedCategory;
  int? _selectedAssetId;
  CalculatorSummaryLoaded? _cachedLoadedState;

  final _currencyFormat = NumberFormat('#,##0', 'ru_RU');
  final _dateFormat = DateFormat('dd.MM.yyyy');
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    context.read<CalculatorBloc>().add(const FetchCalculatorSummaryEvent());
  }

  void _reloadSummary({int? assetId}) {
    context.read<CalculatorBloc>().add(
          FetchCalculatorSummaryEvent(assetId: assetId),
        );
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _selectedAssetId = null;
    });
    _reloadSummary();
  }

  void _onAssetTap(LivestockAssetModel asset) {
    setState(() => _selectedAssetId = asset.id);
    _reloadSummary(assetId: asset.id);
  }

  List<LivestockAssetModel> _filterAssets(List<LivestockAssetModel> assets) {
    if (_selectedCategory == null) return assets;
    return assets.where((asset) => asset.category == _selectedCategory).toList();
  }

  String _formatMoney(double value) => '${_currencyFormat.format(value)} ₸';

  String _quantityLabel(LivestockAssetModel asset) {
    if (asset.category == LivestockCategories.poultryLayers || 
        asset.category == LivestockCategories.poultryBroilers ||
        asset.category == LivestockCategories.rabbits) {
      return '${asset.quantity} шт.';
    }
    if (asset.category == LivestockCategories.bees) {
      return '${asset.quantity} семей';
    }
    return '${asset.quantity} голов';
  }

  String _categoryLabel(String category) {
    switch (category) {
      case LivestockCategories.cattleMilk:
        return 'Молочный КРС';
      case LivestockCategories.cattleMeat:
        return 'Мясной КРС';
      case LivestockCategories.sheep:
        return 'Овцы';
      case LivestockCategories.goats:
        return 'Козы';
      case LivestockCategories.poultryLayers:
        return 'Птица (Яйцо)';
      case LivestockCategories.poultryBroilers:
        return 'Птица (Мясо)';
      case LivestockCategories.horses:
        return 'Лошади';
      case LivestockCategories.pigs:
        return 'Свиньи';
      case LivestockCategories.rabbits:
        return 'Кролики';
      case LivestockCategories.camels:
        return 'Верблюды';
      case LivestockCategories.bees:
        return 'Пчелы';
      default:
        return category;
    }
  }

  void _openExpenseSheet(List<LivestockAssetModel> assets) {
    AddExpenseSheet.show(
      context,
      assets: assets,
      preselectedAssetId: _selectedAssetId,
    );
  }

  void _openYieldSheet(List<LivestockAssetModel> assets) {
    AddYieldSheet.show(
      context,
      assets: assets,
      preselectedAssetId: _selectedAssetId,
    );
  }

  void _showPremiumPaywall(BuildContext context, {required String title, required String message}) {
    PremiumPaywallSheet.show(context, title: title, message: message);
  }

  Future<void> _exportReport(CalculatorSummaryModel summary) async {
    final authState = context.read<AuthBloc>().state;
    final isPremium = authState.user?.isPremium ?? false;

    if (!isPremium) {
      _showPremiumPaywall(
        context,
        title: 'Экспорт отчётов',
        message: 'Брендированные PDF-отчеты с печатью доступны только в Premium версии. В бесплатной версии доступен базовый CSV экспорт.',
      );
      await sl<ReportExportService>().exportToCsv(summary);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Выберите формат экспорта', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.errorSoft),
              title: const Text('Premium PDF Отчёт'),
              subtitle: const Text('Красивое оформление и таблицы'),
              onTap: () {
                Navigator.pop(context);
                sl<ReportExportService>().exportToPdf(summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: Colors.green),
              title: const Text('CSV Таблица'),
              subtitle: const Text('Для Excel и анализа данных'),
              onTap: () {
                Navigator.pop(context);
                sl<ReportExportService>().exportToCsv(summary);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Умный калькулятор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Добавить группу',
            onPressed: () => AddAssetSheet.show(context),
          ),
          BlocBuilder<CalculatorBloc, CalculatorState>(
            builder: (context, state) {
              final summary = state is CalculatorSummaryLoaded
                  ? state.summary
                  : _cachedLoadedState?.summary;
              return IconButton(
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.sagePrimary,
                        ),
                      )
                    : const Icon(Icons.ios_share_rounded),
                tooltip: 'Экспорт отчёта',
                onPressed: summary == null || _isExporting
                    ? null
                    : () => _exportReport(summary),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить',
            onPressed: () => _reloadSummary(assetId: _selectedAssetId),
          ),
        ],
      ),
      body: BlocConsumer<CalculatorBloc, CalculatorState>(
        listenWhen: (previous, current) =>
            current is CalculatorActionSuccess || current is CalculatorError || current is CalculatorFreeLimitReachedState || current is CalculatorPremiumLockedState,
        listener: (context, state) {
          if (state is CalculatorActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.sagePrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          } else if (state is CalculatorFreeLimitReachedState) {
            _showPremiumPaywall(
              context,
              title: 'Лимит групп достигнут',
              message: 'В бесплатной версии можно вести учет до 2-х групп одновременно. Перейдите на Premium, чтобы добавить больше!',
            );
          } else if (state is CalculatorPremiumLockedState) {
            _showPremiumPaywall(
              context,
              title: 'Доступ ограничен',
              message: 'Функция "${state.featureName}" доступна только владельцам Premium-подписки.',
            );
          }
        },
        builder: (context, state) {
          if (state is CalculatorSummaryLoaded) {
            _cachedLoadedState = state;
          }

          if (state is CalculatorLoading && _cachedLoadedState == null) {
            return const _LoadingView();
          }

          if (state is CalculatorError && _cachedLoadedState == null) {
            return _ErrorView(
              message: state.message,
              onRetry: () => _reloadSummary(assetId: _selectedAssetId),
            );
          }

          if (state is CalculatorError && _cachedLoadedState != null) {
            return Stack(
              children: [
                _buildLoadedContent(_cachedLoadedState!),
                _ErrorBanner(
                  message: state.message,
                  onRetry: () => _reloadSummary(assetId: _selectedAssetId),
                ),
              ],
            );
          }

          final loadedState = state is CalculatorSummaryLoaded
              ? state
              : _cachedLoadedState;

          if (loadedState != null) {
            return Stack(
              children: [
                _buildLoadedContent(loadedState),
                if (state is CalculatorLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                      color: AppColors.sagePrimary,
                    ),
                  ),
              ],
            );
          }

          return const _LoadingView();
        },
      ),
    );
  }

  Widget _buildLoadedContent(CalculatorSummaryLoaded state) {
    final filteredAssets = _filterAssets(state.assets);
    final summary = state.summary;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FinancialSummaryCard(
                    summary: summary,
                    formatMoney: _formatMoney,
                    selectedAssetId: _selectedAssetId,
                  ),
                  const SizedBox(height: 20),
                  if (_selectedAssetId != null) _PredictiveForecastSection(assetId: _selectedAssetId!),
                  const SizedBox(height: 28),
                  Text(
                    'Структура расходов',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 14),
                  ExpensesBreakdownChart(
                    key: ValueKey(
                      '${summary.assetId}_${summary.operatingExpenses}_${summary.feedCost}',
                    ),
                    summary: summary,
                  ),
                  const SizedBox(height: 24),
                  EarningsSourcesSection(
                    earningsByProduct: summary.earningsByProduct,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Категория хозяйства',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CategorySelectorCard(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Активные группы',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.sageDark,
                        ),
                      ),
                      Text(
                        '${filteredAssets.length} шт.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (filteredAssets.isEmpty)
                    _EmptyAssetsPlaceholder(
                      hasCategoryFilter: _selectedCategory != null,
                    )
                  else
                    ...filteredAssets.map(
                      (asset) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AssetListTile(
                          asset: asset,
                          isSelected: _selectedAssetId == asset.id,
                          quantityLabel: _quantityLabel(asset),
                          categoryLabel: _categoryLabel(asset.category),
                          dateLabel: asset.createdAt != null
                              ? _dateFormat.format(asset.createdAt!)
                              : '—',
                          onTap: () => _onAssetTap(asset),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _BottomActionBar(
            onRecordExpense: () => _openExpenseSheet(state.assets),
            onRecordYield: () => _openYieldSheet(state.assets),
          ),
        ],
      ),
    );
  }
}

class _PredictiveForecastSection extends StatelessWidget {
  final int assetId;
  const _PredictiveForecastSection({required this.assetId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      buildWhen: (prev, curr) => curr is PredictiveForecastLoadedState || curr is CalculatorLoading || curr is CalculatorPremiumLockedState,
      builder: (context, state) {
        if (state is PredictiveForecastLoadedState) {
          final f = state.forecast;
          return SoftCard(
            color: AppColors.sagePrimary.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: AppColors.sagePrimary, size: 20),
                    const SizedBox(width: 8),
                    Text('Аналитический прогноз', style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                  ],
                ),
                const SizedBox(height: 16),
                _PredictiveChart(progress: 1.0),
                const SizedBox(height: 16),
                if (f.fcr != null) _ForecastRow('Конверсия корма (FCR)', f.fcr!.toStringAsFixed(2), Icons.scale_outlined),
                if (f.breakEvenDate != null) _ForecastRow('Дата окупаемости', DateFormat('dd.MM.yyyy').format(f.breakEvenDate!), Icons.event_available_rounded),
                _ForecastRow('Ожидаемая прибыль/мес', '${NumberFormat('#,##0').format(f.estimatedMonthlyProfit)} ₸', Icons.trending_up_rounded),
                const Divider(height: 24),
                Text(f.advice, style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic, color: AppColors.sageDark)),
              ],
            ),
          );
        }
        
        return GestureDetector(
          onTap: () => context.read<CalculatorBloc>().add(FetchPredictiveForecastEvent(assetId)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                SoftCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_graph_rounded, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Аналитический прогноз', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text('Расчет окупаемости и ROI', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.white12,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_person_outlined, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 8),
                            Text('Доступно в Premium', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PredictiveChart extends StatefulWidget {
  final double progress;
  const _PredictiveChart({required this.progress});
  @override
  State<_PredictiveChart> createState() => _PredictiveChartState();
}

class _PredictiveChartState extends State<_PredictiveChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CustomPaint(painter: _ForecastPainter(_controller.value)),
      ),
    );
  }
}

class _ForecastPainter extends CustomPainter {
  final double progress;
  _ForecastPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sagePrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.sagePrimary.withValues(alpha: 0.2),
          AppColors.sagePrimary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.4, 
      size.height * 0.8, 
      size.width * 0.65, 
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.8, 
      size.height * 0.1, 
      size.width * 0.9, 
      size.height * 0.05, 
      size.width, 
      size.height * 0.02,
    );

    final extractPath = _createAnimatedPath(path, progress);
    
    final fillPath = Path.from(extractPath)
      ..lineTo(size.width * progress, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(extractPath, paint);

    // Draw accent dots
    if (progress > 0.6) {
      final p1 = Paint()..color = AppColors.accentGold..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), 5, p1);
    }
  }

  Path _createAnimatedPath(Path source, double progress) {
    final path = Path();
    final metrics = source.computeMetrics();
    for (final metric in metrics) {
      path.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ForecastRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ForecastRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sagePrimary)),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.sagePrimary,
        strokeWidth: 3,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _ErrorPanel(message: message, onRetry: onRetry),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 100,
      child: _ErrorPanel(message: message, onRetry: onRetry),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.errorSoft.withValues(alpha: 0.08),
      borderRadius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: AppColors.errorSoft.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
          Text(
            'Не удалось загрузить данные',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMax.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.errorSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Повторить попытку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorSoft,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final CalculatorSummaryModel summary;
  final String Function(double) formatMoney;
  final int? selectedAssetId;

  const _FinancialSummaryCard({
    required this.summary,
    required this.formatMoney,
    required this.selectedAssetId,
  });

  @override
  Widget build(BuildContext context) {
    final isProfitPositive = summary.netProfit >= 0;
    final profitColor =
        isProfitPositive ? AppColors.accentGold : AppColors.errorSoft;

    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sagePrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.sagePrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedAssetId != null
                          ? 'Аналитика по группе'
                          : 'Итоги хозяйства',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.sageDark,
                      ),
                    ),
                    Text(
                      '${summary.assetsCount} активных групп',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ROI: ${summary.roi.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.sageDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Чистая прибыль',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatMoney(summary.netProfit),
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              color: profitColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Общие расходы',
                  value: formatMoney(summary.totalCosts),
                  icon: Icons.trending_down_rounded,
                  iconColor: AppColors.errorSoft.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryMetric(
                  label: 'Общий доход',
                  value: formatMoney(summary.totalEarnings),
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.sagePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetListTile extends StatelessWidget {
  final LivestockAssetModel asset;
  final bool isSelected;
  final String quantityLabel;
  final String categoryLabel;
  final String dateLabel;
  final VoidCallback onTap;

  const _AssetListTile({
    required this.asset,
    required this.isSelected,
    required this.quantityLabel,
    required this.categoryLabel,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.sagePrimary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          borderRadius: 20,
          color: isSelected
              ? AppColors.sagePrimary.withValues(alpha: 0.04)
              : AppColors.creamSurface,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sageLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForCategory(asset.category),
                  color: AppColors.sagePrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.breed} — $quantityLabel',
                      style: AppTextStyles.bodyMax.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.sageDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryLabel · $dateLabel',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: isSelected ? AppColors.sagePrimary : AppColors.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case LivestockCategories.cattleMilk:
        return Icons.water_drop_outlined;
      case LivestockCategories.cattleMeat:
        return Icons.grass_outlined;
      case LivestockCategories.sheep:
        return Icons.pets_outlined;
      case LivestockCategories.goats:
        return Icons.gesture_outlined;
      case LivestockCategories.poultryLayers:
        return Icons.egg_outlined;
      case LivestockCategories.poultryBroilers:
        return Icons.restaurant_menu_outlined;
      case LivestockCategories.horses:
        return Icons.directions_run_outlined;
      case LivestockCategories.camels:
        return Icons.landscape_outlined;
      case LivestockCategories.pigs:
        return Icons.savings_outlined;
      case LivestockCategories.rabbits:
        return Icons.cruelty_free_outlined;
      case LivestockCategories.bees:
        return Icons.hive_outlined;
      default:
        return Icons.agriculture_outlined;
    }
  }
}

class _EmptyAssetsPlaceholder extends StatelessWidget {
  final bool hasCategoryFilter;

  const _EmptyAssetsPlaceholder({required this.hasCategoryFilter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AddAssetSheet.show(context),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.add_business_outlined,
              size: 48,
              color: AppColors.sagePrimary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              hasCategoryFilter
                  ? 'В этой категории пока нет групп. Нажмите, чтобы добавить.'
                  : 'Добавьте первую группу поголовья, чтобы начать учет.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onRecordExpense;
  final VoidCallback onRecordYield;

  const _BottomActionBar({
    required this.onRecordExpense,
    required this.onRecordYield,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRecordExpense,
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                label: const Text('Записать расход'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sagePrimary,
                  side: const BorderSide(color: AppColors.sagePrimary, width: 1.5),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRecordYield,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Записать доход'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

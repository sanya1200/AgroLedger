import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/calculator/presentation/widgets/category_selector_card.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';

class CategoryTemplate {
  final String category;
  final String title;
  final String breedDefault;
  final double duration;
  final double quantity;
  final double purchasePricePerHead;
  final double dailyFeedPerHead;
  final double feedPricePerKg;
  final double dailyHayPerHead;
  final double hayPricePerKg;
  final double yieldPerHead;
  final String yieldUnit;
  final double sellingPricePerUnit;
  final double mortality;
  final double otherCostPerHead;

  const CategoryTemplate({
    required this.category,
    required this.title,
    required this.breedDefault,
    required this.duration,
    required this.quantity,
    required this.purchasePricePerHead,
    required this.dailyFeedPerHead,
    required this.feedPricePerKg,
    this.dailyHayPerHead = 0.0,
    this.hayPricePerKg = 0.0,
    required this.yieldPerHead,
    required this.yieldUnit,
    required this.sellingPricePerUnit,
    required this.mortality,
    required this.otherCostPerHead,
  });
}

class QuickCalculatorTab extends StatefulWidget {
  final VoidCallback onSimulationSaved;

  const QuickCalculatorTab({super.key, required this.onSimulationSaved});

  @override
  State<QuickCalculatorTab> createState() => _QuickCalculatorTabState();
}

class _QuickCalculatorTabState extends State<QuickCalculatorTab> {
  String _selectedCategory = LivestockCategories.poultryBroilers;

  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _purchaseController = TextEditingController();
  final _dailyFeedController = TextEditingController();
  final _feedPriceController = TextEditingController();
  final _dailyHayController = TextEditingController();
  final _hayPriceController = TextEditingController();
  final _yieldController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _mortalityController = TextEditingController();
  final _otherCostController = TextEditingController();

  final _currencyFormat = NumberFormat('#,##0', 'ru_RU');

  final List<CategoryTemplate> _templates = const [
    CategoryTemplate(
      category: LivestockCategories.poultryBroilers,
      title: 'Птица (Мясо)',
      breedDefault: 'Кобб-500',
      quantity: 30,
      duration: 45,
      purchasePricePerHead: 1000,
      dailyFeedPerHead: 0.078,
      feedPricePerKg: 297.14,
      yieldPerHead: 2.2,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 2200,
      mortality: 3.33,
      otherCostPerHead: 0.0,
    ),
    CategoryTemplate(
      category: LivestockCategories.poultryLayers,
      title: 'Птица (Яйцо)',
      breedDefault: 'Ломан Браун',
      quantity: 50,
      duration: 365,
      purchasePricePerHead: 1500,
      dailyFeedPerHead: 0.12,
      feedPricePerKg: 250,
      yieldPerHead: 300,
      yieldUnit: 'шт. яиц',
      sellingPricePerUnit: 60,
      mortality: 4.0,
      otherCostPerHead: 200,
    ),
    CategoryTemplate(
      category: LivestockCategories.pigs,
      title: 'Свиноводство',
      breedDefault: 'Дюрок',
      quantity: 10,
      duration: 180,
      purchasePricePerHead: 18000,
      dailyFeedPerHead: 2.8,
      feedPricePerKg: 180,
      yieldPerHead: 85.0,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 2400,
      mortality: 2.0,
      otherCostPerHead: 1500,
    ),
    CategoryTemplate(
      category: LivestockCategories.cattleMilk,
      title: 'Молочный КРС',
      breedDefault: 'Голштинская',
      quantity: 5,
      duration: 365,
      purchasePricePerHead: 480000,
      dailyFeedPerHead: 4.0,
      feedPricePerKg: 170,
      dailyHayPerHead: 15.0,
      hayPricePerKg: 65,
      yieldPerHead: 7300.0,
      yieldUnit: 'л молока',
      sellingPricePerUnit: 280,
      mortality: 0.5,
      otherCostPerHead: 12000,
    ),
    CategoryTemplate(
      category: LivestockCategories.cattleMeat,
      title: 'Мясной КРС',
      breedDefault: 'Герефорд',
      quantity: 8,
      duration: 365,
      purchasePricePerHead: 320000,
      dailyFeedPerHead: 3.5,
      feedPricePerKg: 170,
      dailyHayPerHead: 12.0,
      hayPricePerKg: 65,
      yieldPerHead: 260.0,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 2600,
      mortality: 1.5,
      otherCostPerHead: 9000,
    ),
    CategoryTemplate(
      category: LivestockCategories.sheep,
      title: 'Овцеводство',
      breedDefault: 'Гиссарская',
      quantity: 25,
      duration: 180,
      purchasePricePerHead: 38000,
      dailyFeedPerHead: 0.4,
      feedPricePerKg: 160,
      dailyHayPerHead: 2.0,
      hayPricePerKg: 65,
      yieldPerHead: 24.0,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 2500,
      mortality: 3.0,
      otherCostPerHead: 1000,
    ),
    CategoryTemplate(
      category: LivestockCategories.goats,
      title: 'Козоводство',
      breedDefault: 'Зааненская',
      quantity: 15,
      duration: 365,
      purchasePricePerHead: 45000,
      dailyFeedPerHead: 0.5,
      feedPricePerKg: 160,
      dailyHayPerHead: 2.2,
      hayPricePerKg: 65,
      yieldPerHead: 800.0,
      yieldUnit: 'л молока',
      sellingPricePerUnit: 450,
      mortality: 2.5,
      otherCostPerHead: 1500,
    ),
    CategoryTemplate(
      category: LivestockCategories.rabbits,
      title: 'Кролиководство',
      breedDefault: 'Шиншилла',
      quantity: 40,
      duration: 90,
      purchasePricePerHead: 2500,
      dailyFeedPerHead: 0.15,
      feedPricePerKg: 200,
      dailyHayPerHead: 0.1,
      hayPricePerKg: 65,
      yieldPerHead: 2.0,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 3200,
      mortality: 6.0,
      otherCostPerHead: 300,
    ),
    CategoryTemplate(
      category: LivestockCategories.horses,
      title: 'Коневодство',
      breedDefault: 'Мугалжарская',
      quantity: 4,
      duration: 365,
      purchasePricePerHead: 650000,
      dailyFeedPerHead: 5.0,
      feedPricePerKg: 160,
      dailyHayPerHead: 13.0,
      hayPricePerKg: 65,
      yieldPerHead: 220.0,
      yieldUnit: 'кг мяса',
      sellingPricePerUnit: 2700,
      mortality: 1.0,
      otherCostPerHead: 8000,
    ),
    CategoryTemplate(
      category: LivestockCategories.camels,
      title: 'Верблюды',
      breedDefault: 'Дромедар',
      quantity: 2,
      duration: 365,
      purchasePricePerHead: 880000,
      dailyFeedPerHead: 3.5,
      feedPricePerKg: 170,
      dailyHayPerHead: 16.0,
      hayPricePerKg: 65,
      yieldPerHead: 3285.0,
      yieldUnit: 'л шубата',
      sellingPricePerUnit: 950,
      mortality: 1.0,
      otherCostPerHead: 12000,
    ),
    CategoryTemplate(
      category: LivestockCategories.bees,
      title: 'Пчеловодство',
      breedDefault: 'Карпатка',
      quantity: 12,
      duration: 150,
      purchasePricePerHead: 25000,
      dailyFeedPerHead: 0.1,
      feedPricePerKg: 400,
      yieldPerHead: 38.0,
      yieldUnit: 'кг меда',
      sellingPricePerUnit: 3500,
      mortality: 4.0,
      otherCostPerHead: 2000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applyTemplate(_selectedCategory);
    
    // Add recalculation listeners to all controllers
    _quantityController.addListener(_rebuild);
    _durationController.addListener(_rebuild);
    _purchaseController.addListener(_rebuild);
    _dailyFeedController.addListener(_rebuild);
    _feedPriceController.addListener(_rebuild);
    _dailyHayController.addListener(_rebuild);
    _hayPriceController.addListener(_rebuild);
    _yieldController.addListener(_rebuild);
    _sellingPriceController.addListener(_rebuild);
    _mortalityController.addListener(_rebuild);
    _otherCostController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _durationController.dispose();
    _purchaseController.dispose();
    _dailyFeedController.dispose();
    _feedPriceController.dispose();
    _dailyHayController.dispose();
    _hayPriceController.dispose();
    _yieldController.dispose();
    _sellingPriceController.dispose();
    _mortalityController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _applyTemplate(String category) {
    final t = _templates.firstWhere((element) => element.category == category);
    _quantityController.text = _formatValue(t.quantity);
    _durationController.text = _formatValue(t.duration);
    _purchaseController.text = _formatValue(t.purchasePricePerHead);
    _dailyFeedController.text = t.dailyFeedPerHead.toString();
    _feedPriceController.text = _formatValue(t.feedPricePerKg);
    _dailyHayController.text = t.dailyHayPerHead.toString();
    _hayPriceController.text = _formatValue(t.hayPricePerKg);
    _yieldController.text = t.yieldPerHead.toString();
    _sellingPriceController.text = _formatValue(t.sellingPricePerUnit);
    _mortalityController.text = t.mortality.toString();
    _otherCostController.text = _formatValue(t.otherCostPerHead);
  }

  String _formatValue(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  bool _isRuminant(String category) {
    return category == LivestockCategories.cattleMilk ||
        category == LivestockCategories.cattleMeat ||
        category == LivestockCategories.sheep ||
        category == LivestockCategories.goats ||
        category == LivestockCategories.horses ||
        category == LivestockCategories.camels ||
        category == LivestockCategories.rabbits;
  }

  String _getYieldUnitText() {
    final t = _templates.firstWhere((element) => element.category == _selectedCategory);
    return t.yieldUnit;
  }

  // Live Math Calculations
  double get _quantity => double.tryParse(_quantityController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _duration => double.tryParse(_durationController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _purchasePricePerHead => double.tryParse(_purchaseController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _dailyFeed => double.tryParse(_dailyFeedController.text) ?? 0.0;
  double get _feedPrice => double.tryParse(_feedPriceController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _dailyHay => double.tryParse(_dailyHayController.text) ?? 0.0;
  double get _hayPrice => double.tryParse(_hayPriceController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _yieldPerHead => double.tryParse(_yieldController.text) ?? 0.0;
  double get _sellingPrice => double.tryParse(_sellingPriceController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;
  double get _mortality => double.tryParse(_mortalityController.text) ?? 0.0;
  double get _otherCost => double.tryParse(_otherCostController.text.replaceAll(RegExp(r'\s+'), '')) ?? 0.0;

  double get _purchaseCost => _quantity * _purchasePricePerHead;
  double get _feedCost => _quantity * _duration * _dailyFeed * _feedPrice;
  double get _hayCost => _isRuminant(_selectedCategory) ? _quantity * _duration * _dailyHay * _hayPrice : 0.0;
  double get _vetCost => _quantity * _otherCost;

  double get _totalCosts => _purchaseCost + _feedCost + _hayCost + _vetCost;

  double get _totalFeedWeight => _quantity * _duration * _dailyFeed;
  double get _totalHayWeight => _isRuminant(_selectedCategory) ? _quantity * _duration * _dailyHay : 0.0;

  double get _survivalFactor => (100.0 - _mortality) / 100.0;
  double get _survivedQuantity {
    final count = _quantity * _survivalFactor;
    return count < 0 ? 0.0 : count;
  }

  double get _expectedYield => _survivedQuantity * _yieldPerHead;
  double get _totalRevenue => _expectedYield * _sellingPrice;
  double get _netProfit => _totalRevenue - _totalCosts;
  double get _roi => _totalCosts > 0 ? (_netProfit / _totalCosts) * 100 : 0.0;

  double get _fcr {
    final totalEaten = _totalFeedWeight + _totalHayWeight;
    if (_expectedYield > 0 && _getYieldUnitText().contains('кг')) {
      return totalEaten / _expectedYield;
    }
    return 0.0;
  }

  String _formatMoney(double v) => '${_currencyFormat.format(v)} ₸';

  void _showSaveAssetDialog() {
    final t = _templates.firstWhere((element) => element.category == _selectedCategory);
    final breedController = TextEditingController(text: t.breedDefault);
    final groupNameController = TextEditingController(
      text: '${t.title} - ${DateFormat('MMMM', 'ru_RU').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.creamSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Сохранить симуляцию', style: AppTextStyles.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Создайте группу в вашем хозяйстве на основе проведенных расчетов. Начальные расходы будут записаны автоматически.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  labelText: 'Название группы',
                  filled: true,
                  fillColor: AppColors.creamBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: breedController,
                decoration: InputDecoration(
                  labelText: 'Порода / Кросс',
                  filled: true,
                  fillColor: AppColors.creamBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final breed = breedController.text.trim();
                final name = groupNameController.text.trim();
                if (breed.isNotEmpty && name.isNotEmpty) {
                  Navigator.pop(context);
                  
                  // Construct model and dispatch BLoC
                  final asset = LivestockAssetModel(
                    id: 0,
                    category: _selectedCategory,
                    breed: '$name ($breed)',
                    quantity: _quantity,
                    purchasePrice: _purchaseCost,
                    createdAt: DateTime.now(),
                  );

                  context.read<CalculatorBloc>().add(
                    SaveSimulatedGroupEvent(
                      asset: asset,
                      feedCost: _feedCost + _hayCost,
                      otherCost: _vetCost,
                    ),
                  );
                  widget.onSimulationSaved();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseBreakdown() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Детализация расходов', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBreakdownRow('Покупка поголовья:', _purchaseCost),
            const Divider(),
            _buildBreakdownRow('Корм (комбикорм):', _feedCost),
            if (_isRuminant(_selectedCategory)) ...[
              const Divider(),
              _buildBreakdownRow('Сено / Грубый корм:', _hayCost),
            ],
            const Divider(),
            _buildBreakdownRow('Ветпрепараты и прочее:', _vetCost),
            const Divider(thickness: 2),
            _buildBreakdownRow('Итого расходов:', _totalCosts, isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(_formatMoney(val), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: isBold ? AppColors.sagePrimary : AppColors.textDark)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ruminant = _isRuminant(_selectedCategory);
    final bagsCount = _totalFeedWeight / 25.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategorySelectorCard(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) {
              if (cat != null) {
                setState(() {
                  _selectedCategory = cat;
                });
                _applyTemplate(cat);
              }
            },
          ),
          const SizedBox(height: 20),
          
          // Result Card resembling photo
          SoftCard(
            padding: const EdgeInsets.all(22),
            color: AppColors.sagePrimary.withValues(alpha: 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('БЫСТРЫЙ РАСЧЕТ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sagePrimary)),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppColors.sagePrimary, size: 20),
                      tooltip: 'Показать детали расходов',
                      onPressed: _showExpenseBreakdown,
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Доход:', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(_formatMoney(_totalRevenue), style: AppTextStyles.h2.copyWith(fontSize: 22, color: AppColors.sageDark)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Прибыль:', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_netProfit >= 0 ? Colors.green : AppColors.errorSoft).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatMoney(_netProfit),
                                style: AppTextStyles.bodyMax.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _netProfit >= 0 ? Colors.green[800] : AppColors.errorSoft,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultIndicator('Окупаемость (ROI)', '${_roi.toStringAsFixed(1)}%'),
                    ),
                    if (_fcr > 0)
                      Expanded(
                        child: _buildResultIndicator('Конверсия корма (FCR)', _fcr.toStringAsFixed(2)),
                      )
                    else
                      Expanded(
                        child: _buildResultIndicator(
                          'Всего корма',
                          '${_totalFeedWeight.toStringAsFixed(0)} кг (${bagsCount.toStringAsFixed(1)} меш.)',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text('Параметры симулятора', style: AppTextStyles.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 16),

          // Two-column input fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _quantityController,
                      label: 'Кол-во (шт/гол)',
                      icon: Icons.numbers,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _purchaseController,
                      label: 'Цена закупки (₸/шт)',
                      icon: Icons.shopping_basket_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _dailyFeedController,
                      label: 'Расход корма/день (кг)',
                      icon: Icons.scale_outlined,
                    ),
                    if (ruminant) ...[
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _dailyHayController,
                        label: 'Расход сена/день (кг)',
                        icon: Icons.grass_outlined,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _yieldController,
                      label: 'Выход на 1 гол (${_getYieldUnitText()})',
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _otherCostController,
                      label: 'Ветпрепараты/гол (₸)',
                      icon: Icons.medical_services_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _durationController,
                      label: 'Срок (дней)',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _mortalityController,
                      label: 'Смертность (%)',
                      icon: Icons.percent_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _feedPriceController,
                      label: 'Цена корма (₸/кг)',
                      icon: Icons.payments_outlined,
                    ),
                    if (ruminant) ...[
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _hayPriceController,
                        label: 'Цена сена (₸/кг)',
                        icon: Icons.monetization_on_outlined,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _sellingPriceController,
                      label: 'Цена продажи (₸/ед)',
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _quantity > 0 ? _showSaveAssetDialog : null,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Сохранить как группу'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.sagePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIndicator(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 11),
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.sagePrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sageDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppColors.creamSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.sageLight.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.sageLight.withValues(alpha: 0.15)),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_expense_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<LivestockAssetModel> assets;
  final int? preselectedAssetId;

  const AddExpenseSheet({
    super.key,
    required this.assets,
    this.preselectedAssetId,
  });

  static Future<void> show(
    BuildContext context, {
    required List<LivestockAssetModel> assets,
    int? preselectedAssetId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: AddExpenseSheet(
          assets: assets,
          preselectedAssetId: preselectedAssetId,
        ),
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  int? _selectedAssetId;
  String _mainCategory = 'feed'; // feed, vet, utility, other
  dynamic _subCategory;

  bool _isSubmitting = false;
  String? _assetError;

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.preselectedAssetId;
    if (_selectedAssetId == null && widget.assets.length == 1) {
      _selectedAssetId = widget.assets.first.id;
    }
    _subCategory = FeedSubType.compoundFeed;
  }

  void _onMainCategoryChanged(String cat) {
    setState(() {
      _mainCategory = cat;
      switch (cat) {
        case 'feed': _subCategory = FeedSubType.compoundFeed; break;
        case 'vet': _subCategory = VetSubType.vaccination; break;
        case 'utility': _subCategory = UtilitySubType.electricityIncubation; break;
        case 'other': _subCategory = OtherSubType.logistics; break;
      }
    });
  }

  void _submit() {
    setState(() => _assetError = null);
    if (_selectedAssetId == null) {
      setState(() => _assetError = 'Выберите группу поголовья');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final expense = LivestockExpenseModel(
      assetId: _selectedAssetId!,
      feedSubType: _mainCategory == 'feed' ? _subCategory : null,
      vetSubType: _mainCategory == 'vet' ? _subCategory : null,
      utilitySubType: _mainCategory == 'utility' ? _subCategory : null,
      otherSubType: _mainCategory == 'other' ? _subCategory : null,
      amount: parseFormDouble(_amountController.text) ?? 0,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      date: DateTime.now().toUtc(),
    );

    context.read<CalculatorBloc>().add(RecordExpenseEvent(expense));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (context, state) {
        if (state is CalculatorActionSuccess && _isSubmitting) {
          Navigator.of(context).pop();
        } else if (state is CalculatorError && _isSubmitting) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CalculatorSheetHandle(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Записать расход', style: AppTextStyles.h1.copyWith(fontSize: 24)),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AssetDropdownField(
                          assets: widget.assets,
                          selectedAssetId: _selectedAssetId,
                          errorText: _assetError,
                          onChanged: (v) => setState(() {
                            _selectedAssetId = v;
                            _assetError = null;
                          }),
                        ),
                        const SizedBox(height: 28),
                        Text('Категория', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                        const SizedBox(height: 14),
                        _buildMainCategorySelector(),
                        const SizedBox(height: 24),
                        Text('Тип затрат', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                        const SizedBox(height: 12),
                        _buildSubCategoryChips(),
                        const SizedBox(height: 28),
                        AnimatedInputField(
                          controller: _amountController,
                          label: 'Сумма (₸)',
                          prefixIcon: Icons.payments_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: validateRequiredDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _descController,
                          label: 'Комментарий',
                          prefixIcon: Icons.notes_rounded,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sagePrimary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(64),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text('Подтвердить операцию', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategorySelector() {
    return Row(
      children: [
        _catButton('feed', Icons.grass_outlined, 'Корм'),
        const SizedBox(width: 10),
        _catButton('vet', Icons.medical_services_outlined, 'Вет.'),
        const SizedBox(width: 10),
        _catButton('utility', Icons.bolt_outlined, 'Комм.'),
        const SizedBox(width: 10),
        _catButton('other', Icons.more_horiz_rounded, 'Пр.'),
      ],
    );
  }

  Widget _catButton(String id, IconData icon, String label) {
    final isSelected = _mainCategory == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onMainCategoryChanged(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sagePrimary : AppColors.creamSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.15), width: 1.5),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.sagePrimary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.sagePrimary, size: 22),
              const SizedBox(height: 6),
              Text(label, style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.sageDark, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChips() {
    List<dynamic> options = [];
    if (_mainCategory == 'feed') options = FeedSubType.values.where((e) => e != FeedSubType.unknown).toList();
    else if (_mainCategory == 'vet') options = VetSubType.values.where((e) => e != VetSubType.unknown).toList();
    else if (_mainCategory == 'utility') options = UtilitySubType.values.where((e) => e != UtilitySubType.unknown).toList();
    else options = OtherSubType.values.where((e) => e != OtherSubType.unknown).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation), child: child)),
      child: Container(
        key: ValueKey(_mainCategory),
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final opt = options[index];
            final isSelected = _subCategory == opt;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(_getLabel(opt)),
                selected: isSelected,
                onSelected: (val) => setState(() => _subCategory = opt),
                selectedColor: AppColors.sagePrimary.withValues(alpha: 0.1),
                backgroundColor: AppColors.creamSurface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.sagePrimary : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.15)),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getLabel(dynamic opt) {
    if (opt is FeedSubType) {
      switch(opt) {
        case FeedSubType.roughageHay: return 'Сено/Грубые';
        case FeedSubType.silage: return 'Силос/Сенаж';
        case FeedSubType.concentrates: return 'Концентраты';
        case FeedSubType.prestarter: return 'Престартер';
        case FeedSubType.compoundFeed: return 'Комбикорм';
        default: return '';
      }
    }
    if (opt is VetSubType) {
      switch(opt) {
        case VetSubType.vaccination: return 'Вакцинация';
        case VetSubType.antibiotics: return 'Лечение';
        case VetSubType.insemination: return 'Осеменение';
        case VetSubType.vitamins: return 'Витамины';
        case VetSubType.vetVisit: return 'Вызов врача';
        default: return '';
      }
    }
    if (opt is UtilitySubType) {
      switch(opt) {
        case UtilitySubType.electricityIncubation: return 'Свет/Инкубация';
        case UtilitySubType.waterSupply: return 'Вода';
        case UtilitySubType.heating: return 'Отопление';
        case UtilitySubType.ventilation: return 'Вентиляция';
        default: return '';
      }
    }
    if (opt is OtherSubType) {
      switch(opt) {
        case OtherSubType.logistics: return 'Транспорт';
        case OtherSubType.tagsChips: return 'Бирки/Чипы';
        case OtherSubType.slaughterShearing: return 'Убой/Стрижка';
        case OtherSubType.bedding: return 'Подстилка';
        default: return '';
      }
    }
    return '';
  }
}

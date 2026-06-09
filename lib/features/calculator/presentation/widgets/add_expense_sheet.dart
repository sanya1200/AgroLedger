import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_expense_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';

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
  final _feedController = TextEditingController();
  final _vetController = TextEditingController();
  final _utilityController = TextEditingController();
  final _otherController = TextEditingController();

  final _currencyFormat = NumberFormat('#,##0.##', 'ru_RU');

  int? _selectedAssetId;
  double _totalExpenses = 0;
  bool _isSubmitting = false;
  String? _assetError;

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.preselectedAssetId;
    if (_selectedAssetId == null && widget.assets.length == 1) {
      _selectedAssetId = widget.assets.first.id;
    }
    for (final controller in [
      _feedController,
      _vetController,
      _utilityController,
      _otherController,
    ]) {
      controller.addListener(_recalculateTotal);
    }
  }

  @override
  void dispose() {
    _feedController.dispose();
    _vetController.dispose();
    _utilityController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _recalculateTotal() {
    final total = (parseFormDouble(_feedController.text) ?? 0) +
        (parseFormDouble(_vetController.text) ?? 0) +
        (parseFormDouble(_utilityController.text) ?? 0) +
        (parseFormDouble(_otherController.text) ?? 0);
    setState(() => _totalExpenses = total);
  }

  double _fieldValue(TextEditingController controller) {
    return parseFormDouble(controller.text) ?? 0;
  }

  void _submit() {
    setState(() => _assetError = null);

    if (_selectedAssetId == null) {
      setState(() => _assetError = 'Выберите группу поголовья');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final total = _totalExpenses;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Укажите хотя бы одну статью расхода'),
          backgroundColor: AppColors.errorSoft,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final expense = LivestockExpenseModel(
      assetId: _selectedAssetId!,
      feedCost: _fieldValue(_feedController),
      vetCost: _fieldValue(_vetController),
      utilityCost: _fieldValue(_utilityController),
      otherCost: _fieldValue(_otherController),
      date: DateTime.now().toUtc(),
    );

    context.read<CalculatorBloc>().add(RecordExpenseEvent(expense));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listenWhen: (previous, current) =>
          current is CalculatorActionSuccess || current is CalculatorError,
      listener: (context, state) {
        if (state is CalculatorActionSuccess && _isSubmitting) {
          Navigator.of(context).pop();
        } else if (state is CalculatorError && _isSubmitting) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorSoft,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CalculatorSheetHandle(),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: _formKey,
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
                                Icons.receipt_long_outlined,
                                color: AppColors.sagePrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Записать расход',
                                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    'Учёт затрат на содержание',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                              color: AppColors.textLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AssetDropdownField(
                          assets: widget.assets,
                          selectedAssetId: _selectedAssetId,
                          errorText: _assetError,
                          onChanged: (value) {
                            if (_isSubmitting) return;
                            setState(() {
                              _selectedAssetId = value;
                              _assetError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        AnimatedInputField(
                          controller: _feedController,
                          label: 'Корма',
                          prefixIcon: Icons.grass_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateOptionalDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _vetController,
                          label: 'Ветеринария и вакцины',
                          prefixIcon: Icons.medical_services_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateOptionalDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _utilityController,
                          label: 'Коммунальные услуги / обогрев',
                          prefixIcon: Icons.bolt_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateOptionalDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _otherController,
                          label: 'Прочее',
                          prefixIcon: Icons.more_horiz_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateOptionalDouble,
                        ),
                        const SizedBox(height: 24),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sagePrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.sagePrimary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Итого расходов',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sageDark,
                                ),
                              ),
                              Text(
                                '${_currencyFormat.format(_totalExpenses)} ₸',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.sagePrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || widget.assets.isEmpty
                                ? null
                                : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Сохранить расход'),
                          ),
                        ),
                        if (widget.assets.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Сначала добавьте группу поголовья',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.errorSoft,
                              ),
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
}

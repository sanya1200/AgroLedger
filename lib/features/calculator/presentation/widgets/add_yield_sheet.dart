import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_yield_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';

class AddYieldSheet extends StatefulWidget {
  final List<LivestockAssetModel> assets;
  final int? preselectedAssetId;

  const AddYieldSheet({
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
        child: AddYieldSheet(
          assets: assets,
          preselectedAssetId: preselectedAssetId,
        ),
      ),
    );
  }

  @override
  State<AddYieldSheet> createState() => _AddYieldSheetState();
}

class _AddYieldSheetState extends State<AddYieldSheet> {
  final _formKey = GlobalKey<FormState>();
  final _volumeController = TextEditingController();
  final _earningsController = TextEditingController();

  int? _selectedAssetId;
  String? _selectedProductType;
  bool _isSubmitting = false;
  String? _assetError;

  LivestockAssetModel? get _selectedAsset {
    if (_selectedAssetId == null) return null;
    for (final asset in widget.assets) {
      if (asset.id == _selectedAssetId) return asset;
    }
    return null;
  }

  List<ProductTypeOption> get _productOptions {
    return ProductTypes.forCategory(_selectedAsset?.category);
  }

  String get _volumeUnit {
    for (final option in _productOptions) {
      if (option.value == _selectedProductType) return option.unit;
    }
    return _productOptions.isNotEmpty ? _productOptions.first.unit : 'ед.';
  }

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.preselectedAssetId;
    if (_selectedAssetId == null && widget.assets.length == 1) {
      _selectedAssetId = widget.assets.first.id;
    }
    _syncProductTypeForAsset();
  }

  void _syncProductTypeForAsset() {
    final options = _productOptions;
    if (options.isEmpty) {
      _selectedProductType = null;
      return;
    }
    if (_selectedProductType == null ||
        !options.any((option) => option.value == _selectedProductType)) {
      _selectedProductType = options.first.value;
    }
  }

  void _onAssetChanged(int? assetId) {
    setState(() {
      _selectedAssetId = assetId;
      _assetError = null;
      _syncProductTypeForAsset();
    });
  }

  void _submit() {
    setState(() => _assetError = null);

    if (_selectedAssetId == null) {
      setState(() => _assetError = 'Выберите группу поголовья');
      return;
    }

    if (_selectedProductType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Выберите тип продукции'),
          backgroundColor: AppColors.errorSoft,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final yieldData = LivestockYieldModel(
      assetId: _selectedAssetId!,
      productType: _selectedProductType!,
      volume: parseFormDouble(_volumeController.text) ?? 0,
      earnings: parseFormDouble(_earningsController.text) ?? 0,
      date: DateTime.now().toUtc(),
    );

    context.read<CalculatorBloc>().add(RecordYieldEvent(yieldData));
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _earningsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listenWhen: (previous, current) =>
          current is CalculatorActionSuccess ||
          current is CalculatorError,
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
                                color: AppColors.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.payments_outlined,
                                color: AppColors.accentGold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Зафиксировать доход',
                                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    'Продажа продукции и молодняка',
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
                            _onAssetChanged(value);
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Тип продукции',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.sageDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: _productOptions.isEmpty
                              ? Text(
                                  'Сначала выберите группу',
                                  key: const ValueKey('empty_products'),
                                  style: AppTextStyles.caption,
                                )
                              : Wrap(
                                  key: ValueKey(_selectedAssetId),
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _productOptions.map((option) {
                                    final isSelected =
                                        _selectedProductType == option.value;
                                    return GestureDetector(
                                      onTap: _isSubmitting
                                          ? null
                                          : () => setState(
                                                () => _selectedProductType =
                                                    option.value,
                                              ),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.accentGold
                                                  .withValues(alpha: 0.15)
                                              : AppColors.creamSurface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.accentGold
                                                : AppColors.sageLight
                                                    .withValues(alpha: 0.25),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          option.label,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppColors.sageDark
                                                : AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedInputField(
                          controller: _volumeController,
                          label: 'Объём реализации ($_volumeUnit)',
                          prefixIcon: Icons.scale_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateRequiredDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _earningsController,
                          label: 'Полученный доход (₸)',
                          prefixIcon: Icons.account_balance_wallet_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: validateRequiredDouble,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || widget.assets.isEmpty
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Зафиксировать доход'),
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

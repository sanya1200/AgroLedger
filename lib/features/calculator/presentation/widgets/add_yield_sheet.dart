import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_yield_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';

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
  ProductSubType? _selectedProductType;
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
    if (_selectedProductType == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final yieldData = LivestockYieldModel(
      assetId: _selectedAssetId!,
      productSubType: _selectedProductType!,
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
                            Text('Записать доход', style: AppTextStyles.h1.copyWith(fontSize: 24, color: AppColors.sageDark)),
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
                          onChanged: _onAssetChanged,
                        ),
                        const SizedBox(height: 28),
                        Text('Реализованная продукция', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                        const SizedBox(height: 14),
                        _buildProductChips(),
                        const SizedBox(height: 28),
                        AnimatedInputField(
                          controller: _volumeController,
                          label: 'Объём реализации ($_volumeUnit)',
                          prefixIcon: Icons.scale_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: validateRequiredDouble,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _earningsController,
                          label: 'Полученная выручка (₸)',
                          prefixIcon: Icons.account_balance_wallet_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: validateRequiredDouble,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || widget.assets.isEmpty ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(64),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text('Зафиксировать прибыль', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildProductChips() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        key: ValueKey(_selectedAssetId),
        height: 54,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _productOptions.length,
          itemBuilder: (context, index) {
            final option = _productOptions[index];
            final isSelected = _selectedProductType == option.value;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(option.label, style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.sageDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    Text(option.unit, style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textLight,
                    )),
                  ],
                ),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedProductType = option.value),
                selectedColor: AppColors.sagePrimary,
                backgroundColor: AppColors.creamSurface,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.15)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

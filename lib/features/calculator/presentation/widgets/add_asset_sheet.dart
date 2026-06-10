import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';
import 'package:agroledger/features/calculator/presentation/widgets/category_selector_card.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: const AddAssetSheet(),
      ),
    );
  }

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  
  String? _selectedCategory = LivestockCategories.cattleMilk;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _breedController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите категорию')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final asset = LivestockAssetModel(
      category: _selectedCategory!,
      breed: _breedController.text.trim(),
      quantity: double.parse(_quantityController.text),
      purchasePrice: double.parse(_costController.text),
    );

    context.read<CalculatorBloc>().add(CreateAssetEvent(asset));
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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                            Text('Новая группа', style: AppTextStyles.h1.copyWith(fontSize: 24)),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Категория хозяйства', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark)),
                        const SizedBox(height: 14),
                        CategorySelectorCard(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (val) => setState(() => _selectedCategory = val),
                        ),
                        const SizedBox(height: 32),
                        AnimatedInputField(
                          controller: _breedController,
                          label: 'Порода или название группы',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => v!.isEmpty ? 'Введите название' : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedInputField(
                                controller: _quantityController,
                                label: 'Количество',
                                prefixIcon: Icons.numbers_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: validateRequiredDouble,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedInputField(
                                controller: _costController,
                                label: 'Цена закупа (₸)',
                                prefixIcon: Icons.payments_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: validateRequiredDouble,
                              ),
                            ),
                          ],
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
                                : const Text('Создать учетную группу', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Данные будут использоваться для расчета ROI',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
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
      status: 'active',
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CalculatorSheetHandle(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Новая группа поголовья', style: AppTextStyles.h2),
                        const SizedBox(height: 24),
                        Text('Выберите категорию', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        CategorySelectorCard(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (val) => setState(() => _selectedCategory = val),
                        ),
                        const SizedBox(height: 24),
                        AnimatedInputField(
                          controller: _breedController,
                          label: 'Порода / Название группы',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => v!.isEmpty ? 'Введите название' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedInputField(
                                controller: _quantityController,
                                label: 'Количество',
                                prefixIcon: Icons.numbers_rounded,
                                keyboardType: TextInputType.number,
                                validator: validateRequiredDouble,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedInputField(
                                controller: _costController,
                                label: 'Стоимость закуп.',
                                prefixIcon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                validator: validateRequiredDouble,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Создать группу'),
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

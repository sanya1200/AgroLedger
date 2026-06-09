import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRetailController = TextEditingController();
  final _priceWholesaleController = TextEditingController();
  final _minQtyController = TextEditingController();
  final _stockController = TextEditingController();
  
  String _selectedCategory = 'meat';
  final List<Map<String, String>> _categories = [
    {'id': 'meat', 'label': 'Мясо'},
    {'id': 'eggs', 'label': 'Яйца'},
    {'id': 'milk', 'label': 'Молоко'},
    {'id': 'feed', 'label': 'Корма'},
    {'id': 'animals', 'label': 'Животные'},
    {'id': 'equipment', 'label': 'Оборудование'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceRetailController.dispose();
    _priceWholesaleController.dispose();
    _minQtyController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(title: const Text('Новое объявление')),
      body: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
            Navigator.pop(context);
          } else if (state is MarketplaceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.errorSoft, behavior: SnackBarBehavior.floating),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AnimatedInputField(
                        controller: _titleController,
                        label: 'Название товара',
                        prefixIcon: Icons.shopping_bag_outlined,
                        validator: (v) => v!.isEmpty ? 'Введите название' : null,
                      ),
                      const SizedBox(height: 16),
                      AnimatedInputField(
                        controller: _descriptionController,
                        label: 'Описание',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Категория',
                          prefixIcon: const Icon(Icons.category_outlined, color: AppColors.sagePrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: AppColors.creamBackground.withValues(alpha: 0.5),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(
                          value: c['id'],
                          child: Text(c['label']!),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedInputField(
                              controller: _priceRetailController,
                              label: 'Цена розница',
                              prefixIcon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Укажите' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedInputField(
                              controller: _stockController,
                              label: 'На складе',
                              prefixIcon: Icons.inventory_2_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Укажите' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedInputField(
                              controller: _priceWholesaleController,
                              label: 'Цена опт',
                              prefixIcon: Icons.sell_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedInputField(
                              controller: _minQtyController,
                              label: 'Мин. опт',
                              prefixIcon: Icons.shopping_cart_checkout_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<MarketplaceBloc, MarketplaceState>(
                  builder: (context, state) {
                    final isLoading = state is MarketplaceLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Опубликовать товар'),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'price_retail': double.tryParse(_priceRetailController.text) ?? 0.0,
        'stock_quantity': double.tryParse(_stockController.text) ?? 0.0,
      };

      if (_priceWholesaleController.text.isNotEmpty) {
        productData['price_wholesale'] = double.tryParse(_priceWholesaleController.text) ?? 0.0;
      }
      if (_minQtyController.text.isNotEmpty) {
        productData['wholesale_min_qty'] = double.tryParse(_minQtyController.text) ?? 0.0;
      }

      context.read<MarketplaceBloc>().add(CreateProductRequested(productData));
    }
  }
}

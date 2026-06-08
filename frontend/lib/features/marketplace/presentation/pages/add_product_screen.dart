import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';

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
      appBar: AppBar(title: const Text('Разместить товар')),
      body: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is MarketplaceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Название товара'),
                  validator: (v) => v!.isEmpty ? 'Введите название' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c['id'],
                    child: Text(c['label']!),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceRetailController,
                        decoration: const InputDecoration(labelText: 'Цена розница (₸)', suffixText: '₸'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Обязательно' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'На складе'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Обязательно' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceWholesaleController,
                        decoration: const InputDecoration(labelText: 'Цена опт (₸)', suffixText: '₸'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _minQtyController,
                        decoration: const InputDecoration(labelText: 'Мин. кол-во для опта'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                BlocBuilder<MarketplaceBloc, MarketplaceState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is MarketplaceLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is MarketplaceLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Опубликовать объявление', style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
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
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'price_retail': double.parse(_priceRetailController.text),
        'stock_quantity': double.parse(_stockController.text),
      };

      if (_priceWholesaleController.text.isNotEmpty) {
        productData['price_wholesale'] = double.parse(_priceWholesaleController.text);
      }
      if (_minQtyController.text.isNotEmpty) {
        productData['wholesale_min_qty'] = double.parse(_minQtyController.text);
      }

      context.read<MarketplaceBloc>().add(CreateProductRequested(productData));
    }
  }
}

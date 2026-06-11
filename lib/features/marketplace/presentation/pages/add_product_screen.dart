import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/features/marketplace/data/datasources/marketplace_remote_data_source.dart';

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
  
  File? _imageFile;
  bool _isUploadingImage = false;
  String? _imageUrl;
  
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploadingImage = true;
      });
      try {
        final url = await sl<MarketplaceRemoteDataSource>().uploadImage(pickedFile.path);
        setState(() {
          _imageUrl = url;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingImage = false);
        }
      }
    }
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
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.creamBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.sagePrimary.withValues(alpha: 0.3)),
                          ),
                          child: _isUploadingImage
                              ? const Center(child: CircularProgressIndicator(color: AppColors.sagePrimary))
                              : _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.sagePrimary, size: 40),
                                        SizedBox(height: 8),
                                        Text('Добавить фото', style: TextStyle(color: AppColors.sagePrimary)),
                                      ],
                                    ),
                        ),
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
                              labelAbove: true,
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
                              labelAbove: true,
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
                              labelAbove: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedInputField(
                              controller: _minQtyController,
                              label: 'Мин. опт',
                              prefixIcon: Icons.shopping_cart_checkout_outlined,
                              keyboardType: TextInputType.number,
                              labelAbove: true,
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

      if (_imageUrl != null) {
        productData['image_url'] = _imageUrl;
      }

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

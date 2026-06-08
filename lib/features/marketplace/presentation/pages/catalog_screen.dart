import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:agroledger/features/marketplace/presentation/pages/add_product_screen.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String? _selectedCategory;
  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'Все'},
    {'id': 'meat', 'label': 'Мясо'},
    {'id': 'eggs', 'label': 'Яйца'},
    {'id': 'milk', 'label': 'Молоко'},
    {'id': 'feed', 'label': 'Корма'},
    {'id': 'animals', 'label': 'Животные'},
    {'id': 'equipment', 'label': 'Оборудование'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<MarketplaceBloc>().add(const LoadProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маркетплейс'),
        centerTitle: true,
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated && authState.user.role == 'business') {
            return FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              backgroundColor: Colors.green[800],
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
              builder: (context, state) {
                if (state is MarketplaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductsLoadSuccess) {
                  if (state.products.isEmpty) {
                    return const Center(child: Text('Товары не найдены'));
                  }
                  return _buildProductGrid(state.products);
                } else if (state is MarketplaceFailure) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = (_selectedCategory == cat['id']) || 
                           (_selectedCategory == null && cat['id'] == 'all');
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat['id'] == 'all' ? null : cat['id'];
                });
                context.read<MarketplaceBloc>().add(
                  LoadProductsRequested(category: _selectedCategory),
                );
              },
              selectedColor: Colors.green[800],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.inventory_2_outlined, size: 50, color: Colors.green[800]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.priceRetail.toStringAsFixed(0)} ₸',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (product.priceWholesale != null)
                  Text(
                    'Опт от ${product.wholesaleMinQty}: ${product.priceWholesale!.toStringAsFixed(0)} ₸',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'В наличии: ${product.stockQuantity}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (product.isActive)
                      const Icon(Icons.check_circle, size: 16, color: Colors.green)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

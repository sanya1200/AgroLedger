import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:agroledger/features/marketplace/presentation/pages/add_product_screen.dart';
import 'package:agroledger/features/marketplace/presentation/pages/product_details_screen.dart';
import 'package:agroledger/features/home/presentation/pages/business_setup_screen.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String? _selectedCategory;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
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
    _fetchProducts();
  }

  void _fetchProducts() {
    context.read<MarketplaceBloc>().add(LoadProductsRequested(
      category: _selectedCategory,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    ));
  }

  void _onAddProductPressed(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    if (user != null && user.hasBusinessProfile) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddProductScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Нужен профиль хозяйства'),
          content: const Text(
            'Чтобы выставлять товары на продажу, пожалуйста, укажите название и местоположение вашего хозяйства в профиле.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusinessSetupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Настроить сейчас', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Поиск товаров...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  setState(() => _searchQuery = val);
                  _fetchProducts();
                },
              )
            : const Text('Маркетплейс'),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                  _fetchProducts();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddProductPressed(context),
        backgroundColor: AppColors.sagePrimary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Продать',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
              builder: (context, state) {
                if (state is MarketplaceLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.sagePrimary),
                  );
                } else if (state is ProductsLoadSuccess) {
                  if (state.products.isEmpty) {
                    return _buildEmptyPlaceholder();
                  }
                  return RefreshIndicator(
                    color: AppColors.sagePrimary,
                    onRefresh: () async {
                      _fetchProducts();
                    },
                    child: _buildProductGrid(state.products),
                  );
                } else if (state is MarketplaceFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.errorSoft),
                        const SizedBox(height: 16),
                        Text('Ошибка: ${state.message}', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<MarketplaceBloc>().add(const LoadProductsRequested()),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
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
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = (_selectedCategory == cat['id']) || 
                           (_selectedCategory == null && cat['id'] == 'all');
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat['id'] == 'all' ? null : cat['id'];
                });
                _fetchProducts();
              },
              selectedColor: AppColors.sagePrimary,
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.sageDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Bottom padding for FAB
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
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

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.sageLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Товары не найдены',
            style: AppTextStyles.h2.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте выбрать другую категорию',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final minController = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Фильтры'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minController,
                decoration: const InputDecoration(labelText: 'Мин. цена (₸)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxController,
                decoration: const InputDecoration(labelText: 'Макс. цена (₸)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minPrice = null;
                  _maxPrice = null;
                });
                Navigator.pop(context);
                _fetchProducts();
              },
              child: const Text('Сбросить'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _minPrice = double.tryParse(minController.text);
                  _maxPrice = double.tryParse(maxController.text);
                });
                Navigator.pop(context);
                _fetchProducts();
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: SoftCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.sageLight.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: product.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryLabel(product.category),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.sagePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMax.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.priceRetail.toStringAsFixed(0)} ₸',
                    style: AppTextStyles.bodyMax.copyWith(
                      color: AppColors.sagePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.priceWholesale != null)
                    Text(
                      'Опт от ${product.wholesaleMinQty.toInt()} ед: ${product.priceWholesale!.toStringAsFixed(0)} ₸',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    )
                  else
                    const SizedBox(height: 14), // Spacer
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stockQuantity > 0 
                              ? AppColors.sagePrimary.withValues(alpha: 0.1)
                              : AppColors.errorSoft.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.stockQuantity > 0 ? 'В наличии' : 'Нет в наличии',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            color: product.stockQuantity > 0 ? AppColors.sagePrimary : AppColors.errorSoft,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: AppColors.accentGold.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        _getIconForCategory(product.category),
        size: 40,
        color: AppColors.sagePrimary.withValues(alpha: 0.4),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'meat': return Icons.restaurant_rounded;
      case 'eggs': return Icons.egg_rounded;
      case 'milk': return Icons.water_drop_rounded;
      case 'feed': return Icons.grass_rounded;
      case 'animals': return Icons.pets_rounded;
      case 'equipment': return Icons.agriculture_rounded;
      default: return Icons.inventory_2_outlined;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'meat': return 'Мясо';
      case 'eggs': return 'Яйца';
      case 'milk': return 'Молоко';
      case 'feed': return 'Корма';
      case 'animals': return 'Животные';
      case 'equipment': return 'Оборудование';
      default: return 'Прочее';
    }
  }
}

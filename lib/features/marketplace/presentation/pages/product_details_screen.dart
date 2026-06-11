import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_event.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_state.dart';
import 'package:agroledger/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  Future<void> _contactSeller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri whatsappUri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri telUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'ru_RU');

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: AppColors.sagePrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl != null
                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.sageLight.withValues(alpha: 0.1),
                      child: Icon(
                        _getIconForCategory(product.category),
                        size: 100,
                        color: AppColors.sagePrimary.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.sagePrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCategoryLabel(product.category),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.sagePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        product.createdAt != null
                            ? DateFormat('dd.MM.yyyy').format(product.createdAt!)
                            : '',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(product.title, style: AppTextStyles.h1),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${currencyFormat.format(product.priceRetail)} ₸',
                        style: AppTextStyles.h1.copyWith(color: AppColors.sagePrimary, fontSize: 32),
                      ),
                      const SizedBox(width: 8),
                      Text('за ед.', style: AppTextStyles.caption),
                    ],
                  ),
                  if (product.priceWholesale != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sell_outlined, color: AppColors.accentGold, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Оптовая цена: ${currencyFormat.format(product.priceWholesale)} ₸',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.sageDark,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'от ${product.wholesaleMinQty.toInt()} шт.',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('Описание', style: AppTextStyles.h2.copyWith(fontSize: 20)),
                  const SizedBox(height: 12),
                  Text(
                    product.description ?? 'Описание отсутствует',
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 32),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.sagePrimary.withValues(alpha: 0.1),
                          child: const Icon(Icons.storefront_outlined, color: AppColors.sagePrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Продавец верифицирован', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(product.sellerName ?? 'АгроЛеджер Продавец', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_user_rounded, color: AppColors.accentGold),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding for button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatRoomCreated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          roomId: state.room.id,
                          title: 'Чат по товару #${product.id}',
                        ),
                      ),
                    );
                  } else if (state is ChatFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is ChatLoading;
                  return ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            // Если sellerId нет в product (что странно), fallback на whatsapp
                            if (product.sellerId != null) {
                              context.read<ChatBloc>().add(
                                CreateRoomRequested(product.id, product.sellerId!),
                              );
                            } else {
                              _contactSeller(product.sellerPhone);
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(isLoading ? 'Загрузка...' : 'Написать продавцу'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sagePrimary,
                      minimumSize: const Size.fromHeight(56),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B24),
          ),
        ),
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = state.items;
          if (favorites.isEmpty) {
            return const _EmptyFavoriteState();
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = favorites[index];
              return ProductCard(
                product: product,
                onTap: () => _openProductDetails(
                  context,
                  product: product,
                  relatedProducts: favorites,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openProductDetails(
    BuildContext context, {
    required ProductModel product,
    required List<ProductModel> relatedProducts,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailView(
          product: product,
          relatedProducts: relatedProducts,
        ),
      ),
    );
  }
}

class _EmptyFavoriteState extends StatelessWidget {
  const _EmptyFavoriteState();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAD3E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.favorite_border,
                  size: 46,
                  color: accent.withValues(alpha: 0.95),
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'No favorite products yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: accent.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

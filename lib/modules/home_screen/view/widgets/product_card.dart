import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/utils/country_flag_utils.dart';

import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;
  final String? countryLabel; // e.g. 'Cambodia 🇰🇭'

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.onTap,
    this.countryLabel,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[300]),
                    ),
                  ),
                  // Discount Badge
                  if (widget.product.discountPercent != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Country Flag Badge
                  if (widget.product.countryOfOrigin != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CountryFlagBadge(
                        countryOfOrigin: widget.product.countryOfOrigin!,
                        size: 26,
                      ),
                    ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        widget.onFavoriteTap?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? const Color(0xFFEC407A)
                              : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.countryLabel != null) ...
                    [
                      const SizedBox(height: 3),
                      Text(
                        widget.countryLabel!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$ ${widget.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEC407A),
                              ),
                            ),
                            if (widget.product.originalPrice != null)
                              Text(
                                '\$ ${widget.product.originalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          final quantity = cartState.quantityFor(
                            widget.product.id,
                          );
                          return Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minHeight: 24,
                                  minWidth: 24,
                                ),
                                onPressed: () async {
                                  if (UserSession.isGuest) {
                                    await showAuthRequiredDialog(context);
                                    return;
                                  }
                                  if (!context.mounted) return;
                                  context.read<CartBloc>().add(
                                    AddToCart(widget.product),
                                  );
                                },
                                icon: Icon(
                                  quantity > 0
                                      ? Icons.shopping_cart
                                      : Icons.add_shopping_cart,
                                  color: const Color(0xFFEC407A),
                                  size: 18,
                                ),
                              ),
                              if (quantity > 0)
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    color: Color(0xFFEC407A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          );
                        },
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
}

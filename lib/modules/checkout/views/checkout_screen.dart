import 'dart:async';

import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/modules/address/blocs/address_bloc.dart';
import 'package:e_commerce_mobile_app/modules/address/blocs/address_event.dart';
import 'package:e_commerce_mobile_app/modules/address/blocs/address_state.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/cubits/checkout_cubit.dart';
import 'package:e_commerce_mobile_app/modules/checkout/cubits/checkout_state.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/order_pricing_section.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/product_order_section.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_bloc.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/blocs/shop_state.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _promoController = TextEditingController();

  static const double _deliveryFee = 1.59;
  static const double _packageFees = 0.10;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  ShopOption? _selectedShop(BuildContext context) {
    final shopState = context.read<ShopBloc>().state;
    if (shopState is ShopsLoaded) {
      final selectedId = _selectedShopId(context);
      try {
        return shopState.shops.firstWhere((s) => s.shopId == selectedId);
      } catch (_) {
        return shopState.shops.isNotEmpty ? shopState.shops.first : null;
      }
    }
    return null;
  }

  String _selectedShopId(BuildContext context) {
    return UserSession.selectedShopId;
  }

  void _loadDirections(BuildContext context) {
    final shop = _selectedShop(context);
    final addr = context.read<AddressBloc>().state.selectedAddress;
    if (shop?.latitude == null || shop?.longitude == null || addr == null) {
      return;
    }
    context.read<CheckoutCubit>().loadDirections(
      LatLng(shop!.latitude!, shop.longitude!),
      LatLng(addr.latitude, addr.longitude),
    );
    _moveCameraToFit(context);
  }

  Future<void> _selectAddress(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).pushNamed<DeliveryAddress>(AppRoutes.receivingAddress);
    if (result != null && context.mounted) {
      context.read<AddressBloc>().add(SelectAddress(result));
      _loadDirections(context);
      _moveCameraToFit(context);
    }
  }

  void _moveCameraToFit(BuildContext context) async {
    final shop = _selectedShop(context);
    final addr = context.read<AddressBloc>().state.selectedAddress;
    if (shop?.latitude == null || addr == null) return;

    // Waits for map to be created — safe to call before map is ready
    final controller = await _mapController.future;
    if (!mounted) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        [shop!.latitude!, addr.latitude].reduce((a, b) => a < b ? a : b),
        [shop.longitude!, addr.longitude].reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        [shop.latitude!, addr.latitude].reduce((a, b) => a > b ? a : b),
        [shop.longitude!, addr.longitude].reduce((a, b) => a > b ? a : b),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  void initState() {
    super.initState();
    // Directions + camera fit are triggered via _onMapReady when the map is
    // fully created, so we avoid a timing race with the Completer.
  }

  void _onMapReady() {
    _loadDirections(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (prev, curr) =>
          curr.status == CheckoutStatus.success &&
          prev.status != CheckoutStatus.success,
      listener: (context, state) {
        final order = state.completedOrder!;
        context.read<CartBloc>().add(ClearCart());
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _OrderSuccessDialog(
            orderNumber: order.orderNumber,
            onTrackOrder: () {
              Navigator.of(context)
                ..pop()
                ..pushReplacementNamed(AppRoutes.orderTrack, arguments: order);
            },
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Check Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        body: _CheckoutBody(
          mapController: _mapController,
          promoController: _promoController,
          deliveryFee: _deliveryFee,
          packageFees: _packageFees,
          selectedShop: (ctx) => _selectedShop(ctx),
          onSelectAddress: _selectAddress,
          onMapReady: _onMapReady,
        ),
        bottomNavigationBar: _PlaceOrderButton(
          deliveryFee: _deliveryFee,
          packageFees: _packageFees,
          selectedShop: (ctx) => _selectedShop(ctx),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.mapController,
    required this.promoController,
    required this.deliveryFee,
    required this.packageFees,
    required this.selectedShop,
    required this.onSelectAddress,
    required this.onMapReady,
  });

  final Completer<GoogleMapController> mapController;
  final TextEditingController promoController;
  final double deliveryFee;
  final double packageFees;
  final ShopOption? Function(BuildContext) selectedShop;
  final Future<void> Function(BuildContext) onSelectAddress;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _MapSection(
            mapController: mapController,
            selectedShop: selectedShop,
            onMapReady: onMapReady,
          ),
        ),
        SliverToBoxAdapter(child: _AddressBar()),
        SliverToBoxAdapter(
          child: _DeliveryInfoRow(onSelectAddress: onSelectAddress),
        ),
        SliverToBoxAdapter(child: _ShopNameRow(selectedShop: selectedShop)),
        SliverToBoxAdapter(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) =>
                ProductOrderSection(items: state.items),
          ),
        ),
        SliverToBoxAdapter(child: _PromoCodeRow(controller: promoController)),
        SliverToBoxAdapter(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, checkoutState) {
                  final subtotal = cartState.totalAmount;
                  final total =
                      subtotal +
                      deliveryFee +
                      packageFees -
                      checkoutState.promoDiscount;
                  return OrderPricingSection(
                    paymentMethod: 'Cash on Delivery',
                    deliveryFee: deliveryFee,
                    subtotal: subtotal,
                    packageFees: packageFees,
                    discount: 0.0,
                    promoDiscount: checkoutState.promoDiscount,
                    total: total,
                  );
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ─── Map ──────────────────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.mapController,
    required this.selectedShop,
    required this.onMapReady,
  });

  final Completer<GoogleMapController> mapController;
  final ShopOption? Function(BuildContext) selectedShop;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    final shop = selectedShop(context);
    final addressState = context.watch<AddressBloc>().state;
    final checkoutState = context.watch<CheckoutCubit>().state;

    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    LatLng initialCamera = const LatLng(11.5564, 104.9282); // Phnom Penh

    if (shop?.latitude != null && shop?.longitude != null) {
      final shopLatLng = LatLng(shop!.latitude!, shop.longitude!);
      initialCamera = shopLatLng;
      markers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: shopLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: InfoWindow(title: shop.storeName),
        ),
      );
    }

    final addr = addressState.selectedAddress;
    if (addr != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(addr.latitude, addr.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: addr.nameAddress),
        ),
      );
    }

    if (checkoutState.polylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: AppColors.primary,
          width: 4,
          points: checkoutState.polylinePoints,
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.38,
      child: GoogleMap(
        onMapCreated: (c) {
          if (!mapController.isCompleted) {
            mapController.complete(c);
            // Use addPostFrameCallback so the cubit context is ready
            WidgetsBinding.instance.addPostFrameCallback((_) => onMapReady());
          }
        },
        initialCameraPosition: CameraPosition(target: initialCamera, zoom: 13),
        markers: markers,
        polylines: polylines,
        // Ensure map drag works inside the surrounding scroll view.
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}

// ─── Address Bar ──────────────────────────────────────────────────────────────

class _AddressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        final address = state.selectedAddress?.address ?? '';
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: Colors.black45),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'No delivery address selected' : address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: address.isEmpty ? Colors.black38 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Delivery Info Row ────────────────────────────────────────────────────────

class _DeliveryInfoRow extends StatelessWidget {
  const _DeliveryInfoRow({required this.onSelectAddress});

  final Future<void> Function(BuildContext) onSelectAddress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Text(
            'Delivery Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          BlocBuilder<AddressBloc, AddressState>(
            builder: (context, state) {
              final addr = state.selectedAddress;
              if (addr == null) {
                return GestureDetector(
                  onTap: () => onSelectAddress(context),
                  child: const Text(
                    'Select address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => onSelectAddress(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${addr.nameAddress} , ${addr.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black45,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Shop Name Row ────────────────────────────────────────────────────────────

class _ShopNameRow extends StatelessWidget {
  const _ShopNameRow({required this.selectedShop});

  final ShopOption? Function(BuildContext) selectedShop;

  @override
  Widget build(BuildContext context) {
    final shop = selectedShop(context);
    final name = shop?.storeName ?? '';
    if (name.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// ─── Promo Code Row ───────────────────────────────────────────────────────────

class _PromoCodeRow extends StatelessWidget {
  const _PromoCodeRow({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promote Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: (v) =>
                        context.read<CheckoutCubit>().updatePromoCode(v),
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code here',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.read<CheckoutCubit>().applyPromo(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Place Order Button ───────────────────────────────────────────────────────

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({
    required this.deliveryFee,
    required this.packageFees,
    required this.selectedShop,
  });

  final double deliveryFee;
  final double packageFees;
  final ShopOption? Function(BuildContext) selectedShop;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkoutState) {
        final isLoading = checkoutState.status == CheckoutStatus.placingOrder;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _onPlaceOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPlaceOrder(BuildContext context) {
    final addr = context.read<AddressBloc>().state.selectedAddress;
    if (addr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address first')),
      );
      return;
    }
    final cartItems = context.read<CartBloc>().state.items;
    final shop = selectedShop(context);
    final shopName = shop?.storeName ?? 'Supermarket';

    context.read<CheckoutCubit>().placeOrder(
      items: cartItems,
      deliveryAddress: addr,
      shopName: shopName,
      storeLatitude: shop?.latitude,
      storeLongitude: shop?.longitude,
    );
  }
}

// ─── Order Success Dialog ─────────────────────────────────────────────────────

class _OrderSuccessDialog extends StatelessWidget {
  const _OrderSuccessDialog({
    required this.orderNumber,
    required this.onTrackOrder,
  });

  final String orderNumber;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order #$orderNumber has been placed\nsuccessfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onTrackOrder,
                child: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

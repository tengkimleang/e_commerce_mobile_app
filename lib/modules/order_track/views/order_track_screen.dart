import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/maps/map_marker_icons.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/checkout/repositories/orders_repository.dart';
import 'package:e_commerce_mobile_app/modules/checkout/services/directions_service.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/order_pricing_section.dart';
import 'package:e_commerce_mobile_app/modules/checkout/widgets/product_order_section.dart';
import 'package:e_commerce_mobile_app/modules/order_track/widgets/order_step_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class OrderTrackScreen extends StatefulWidget {
  const OrderTrackScreen({
    super.key,
    required this.order,
    this.returnToOrderHistoryOnBack = false,
  });

  final OrderSummary order;
  final bool returnToOrderHistoryOnBack;

  @override
  State<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen> {
  static const _dateFormat = 'dd-MMM-yyyy, h:mm a';

  final _mapController = Completer<GoogleMapController>();
  final _directionsService = DirectionsService();
  final _ordersRepository = OrdersRepository(di<Dio>());
  Timer? _pollingTimer;
  late OrderSummary _order;
  List<LatLng> _polylinePoints = [];
  BitmapDescriptor _shopMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRose,
  );

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadShopMarkerIcon();
    _startOrderPolling();
  }

  Future<void> _loadShopMarkerIcon() async {
    final icon = await MapMarkerIcons.pinkShopMarker();
    if (!mounted) return;
    setState(() => _shopMarkerIcon = icon);
  }

  void _onMapReady() {
    final o = _order;
    if (o.shopLatitude == null || o.shopLongitude == null) return;
    _loadDirections();
  }

  Future<void> _loadDirections() async {
    final o = _order;
    if (o.shopLatitude == null || o.shopLongitude == null) return;
    final shopLatLng = LatLng(o.shopLatitude!, o.shopLongitude!);
    final deliveryLatLng = LatLng(
      o.deliveryAddress.latitude,
      o.deliveryAddress.longitude,
    );
    final points = await _directionsService.getRoutePoints(
      shopLatLng,
      deliveryLatLng,
    );
    final finalPoints = points.isNotEmpty
        ? points
        : [shopLatLng, deliveryLatLng];
    if (!mounted) return;
    setState(() => _polylinePoints = finalPoints);
    _moveCameraToFit(shopLatLng, deliveryLatLng);
  }

  Future<void> _refreshOrderDetail() async {
    final orderId = _order.orderId.trim();
    if (orderId.isEmpty) return;
    try {
      final latest = await _ordersRepository.fetchOrderDetail(orderId: orderId);
      if (!mounted) return;
      final shouldReloadRoute =
          latest.shopLatitude != _order.shopLatitude ||
          latest.shopLongitude != _order.shopLongitude ||
          latest.deliveryAddress.latitude != _order.deliveryAddress.latitude ||
          latest.deliveryAddress.longitude != _order.deliveryAddress.longitude;
      setState(() => _order = latest);
      if (shouldReloadRoute) {
        _loadDirections();
      }
    } catch (_) {
      // Keep current UI state when backend detail refresh fails.
    }
  }

  void _startOrderPolling() {
    _refreshOrderDetail();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshOrderDetail(),
    );
  }

  Future<void> _moveCameraToFit(LatLng a, LatLng b) async {
    final bounds = LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _handleBackPressed() {
    final navigator = Navigator.of(context);
    if (!widget.returnToOrderHistoryOnBack && navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushNamedAndRemoveUntil(AppRoutes.orders, (route) => false);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final order = _order;
    final formattedDate = DateFormat(_dateFormat).format(order.orderDate);

    LatLng? shopLatLng;
    if (order.shopLatitude != null && order.shopLongitude != null) {
      shopLatLng = LatLng(order.shopLatitude!, order.shopLongitude!);
    }
    final deliveryLatLng = LatLng(
      order.deliveryAddress.latitude,
      order.deliveryAddress.longitude,
    );

    final Set<Marker> markers = {};
    if (shopLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: shopLatLng,
          icon: _shopMarkerIcon,
          infoWindow: InfoWindow(title: order.displayShopName),
        ),
      );
    }
    markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: deliveryLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: order.deliveryAddress.nameAddress),
      ),
    );

    final Set<Polyline> polylines = {};
    if (_polylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: primary,
          width: 4,
          points: _polylinePoints,
        ),
      );
    }

    final initialCamera = shopLatLng ?? deliveryLatLng;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Map + title overlay ──────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    onMapCreated: (c) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(c);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _onMapReady(),
                        );
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: initialCamera,
                      zoom: 13,
                    ),
                    markers: markers,
                    polylines: polylines,
                    // Keep map draggable/zoomable even with surrounding content.
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
                // Title row overlaid on map
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black87,
                            ),
                            onPressed: _handleBackPressed,
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Order Track',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Address bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                order.deliveryAddress.address,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          OrderStepBar(
                            currentStep: _resolveOrderStep(
                              order.trackStep,
                              order.statusCode,
                            ),
                          ),
                          Divider(height: 1, thickness: 0.5),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Order meta
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.displayShopName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order Date: $formattedDate',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order: # ${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Delivery info + products + pricing
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              const Text(
                                'Delivery Info',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.bookmark, color: primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${order.deliveryAddress.nameAddress} , ${order.deliveryAddress.phoneNumber}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        ProductOrderSection(
                          items: order.items,
                          showPickedCount: false,
                          showUnitPrice: true,
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        OrderPricingSection(
                          paymentMethod: order.paymentMethod,
                          deliveryFee: order.deliveryFee,
                          subtotal: order.subtotal,
                          packageFees: order.packageFees,
                          discount: order.discount,
                          promoDiscount: order.promoDiscount,
                          total: order.total,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OrderStep _resolveOrderStep(String trackStep, String statusCode) {
    final value = (trackStep.trim().isNotEmpty ? trackStep : statusCode)
        .trim()
        .toUpperCase();
    switch (value) {
      case 'REQUESTING':
        return OrderStep.requesting;
      case 'PICKING':
        return OrderStep.picking;
      case 'DELIVERING':
        return OrderStep.delivering;
      case 'DELIVERED':
        return OrderStep.delivered;
      case 'CANCELED':
      default:
        return OrderStep.requesting;
    }
  }
}

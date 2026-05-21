import 'package:e_commerce_mobile_app/modules/home_screen/view/search_products.dart';
import 'package:flutter/material.dart';

class PriceCheckingView extends StatelessWidget {
  final bool selectionMode;

  const PriceCheckingView({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    return SearchProducts(selectionMode: selectionMode);
  }
}

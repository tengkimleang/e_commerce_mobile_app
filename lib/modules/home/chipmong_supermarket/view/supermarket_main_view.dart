
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/controller/supermarket_category_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/controller/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/controller/supermarket_category_state.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/model/category_model.dart';
import 'loyalty_view.dart';
import 'become_partner_view.dart';

class SupermarketMainView extends StatefulWidget {
  const SupermarketMainView({super.key});

  @override
  State<SupermarketMainView> createState() => _SupermarketMainViewState();
}

class _SupermarketMainViewState extends State<SupermarketMainView> {
  final PageController _controller = PageController();
  int _current = 0;
  late final Timer _timer;
  late final PageController _partnerController;
  int _partnerCurrent = 0;

  final List<String> _images = [
    'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg'
  ];

  final List<String> _partnerImages = [
    'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
  ];

  @override
  void initState() {
    _partnerController = PageController(viewportFraction: 0.95);
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_current + 1) % _images.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupermarketCategoryBloc()..add(LoadCategories()),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Chip Mong Supermarket'),
        backgroundColor: const Color(0xFFEC407A),
      ),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,
                      itemCount: _images.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _current == i ? 12 : 8,
                            height: _current == i ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _current == i ? Colors.white : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Loyalty', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('01-28 Feb 2026 — Special promotions and bundles.'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<SupermarketCategoryBloc, SupermarketCategoryState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading || state is CategoriesInitial) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is CategoriesError) {
                      return SizedBox(
                        height: 80,
                        child: Center(child: Text('Error: ${state.message}')),
                      );
                    }
                    if (state is CategoriesLoaded) {
                      final cats = state.categories;
                      return Row(
                        children: cats.map((c) => _buildCategoryCard(context, c)).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Partner Privileges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _partnerController,
                  itemCount: _partnerImages.length,
                  onPageChanged: (i) => setState(() => _partnerCurrent = i),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: _partnerImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (c, s) => Container(color: Colors.grey[200]),
                          errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_partnerImages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _partnerCurrent == i ? 12 : 8,
                      height: _partnerCurrent == i ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _partnerCurrent == i ? Colors.black87 : Colors.black26,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BecomePartnerView())),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                              gradient: const LinearGradient(colors: [Color(0xFFEC407A), Color(0xFFEA2E6D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Wholesale Price', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 6),
                                Text('High quality products\nwith special price', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                          child: Image.asset(
                            'assets/images/woman.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            // errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 120, height: 120),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel c) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: InkWell(
          onTap: () {
            if (c.id == 'loyalty') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoyaltyView()));
            } else if (c.id == 'partner') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BecomePartnerView()));
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: c.imageUrl,
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(c.subtitle, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

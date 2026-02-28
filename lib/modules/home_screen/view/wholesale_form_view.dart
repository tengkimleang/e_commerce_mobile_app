import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/price_checking_view.dart';

class WholesaleFormView extends StatefulWidget {
  const WholesaleFormView({super.key});

  @override
  State<WholesaleFormView> createState() => _WholesaleFormViewState();
}

class _WholesaleFormViewState extends State<WholesaleFormView> {
  final List<Map<String, String>> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesale Form'),
        backgroundColor: const Color(0xFFEC407A),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Customer Name',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildField(initial: ''),
                      const SizedBox(height: 16),

                      const Text(
                        'Phone number',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildField(initial: ''),
                      const SizedBox(height: 16),

                      const Text('Remark', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildField(initial: '', maxLines: 4),
                      const SizedBox(height: 16),

                      // Search product (navigates to product list)
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .push<Map<String, String>>(
                                MaterialPageRoute(
                                  builder: (_) => const PriceCheckingView(
                                    selectionMode: true,
                                  ),
                                ),
                              );
                          if (result != null) {
                            setState(() {
                              // avoid duplicates by id
                              if (!_selected.any(
                                (e) => e['id'] == result['id'],
                              )) {
                                _selected.add(result);
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Search product',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              Icon(Icons.search, color: Color(0xFFEC407A)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selected products list
                      ..._selected.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildSelectedCard(p),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Submit bar
              Container(
                width: double.infinity,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEC407A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCard(Map<String, String> p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Image.network(
              p['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(p['title'] ?? '', style: const TextStyle(fontSize: 14)),
          ),
          IconButton(
            onPressed: () {
              setState(() => _selected.removeWhere((e) => e['id'] == p['id']));
            },
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildField({String initial = '', int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

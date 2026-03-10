import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/views/price_checking_view.dart';

class WholesaleFormView extends StatefulWidget {
  const WholesaleFormView({super.key});

  @override
  State<WholesaleFormView> createState() => _WholesaleFormViewState();
}

class _WholesaleFormViewState extends State<WholesaleFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _remarkController;
bool _isSubmitting = false;

@override
void initState() {
  super.initState();
  _nameController = TextEditingController();
  _phoneController = TextEditingController();
  _remarkController = TextEditingController();
}

@override
void dispose() {
  _nameController.dispose();
  _phoneController.dispose();
  _remarkController.dispose();
  super.dispose();
}
  final List<Map<String, String>> _selected = [];

  @override
  Widget build(BuildContext context) {
    Future<void> _submit() async {
      final customerName = _nameController.text.trim();
      final phoneNumber = _phoneController.text.trim();
      final remark = _remarkController.text.trim();

      if (customerName.isEmpty || phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and phone')));
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5058')); // <- server root
        final payload = {
          'customerName': customerName,
          'phoneNumber': phoneNumber, // <- use this key
          'remark': remark,
        };

        final resp = await dio.post('/partnership/create', data: payload); // <- endpoint path
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted successfully')));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.data?.toString() ?? 'Submission failed')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit failed: ${e.toString()}')));
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
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
                      _buildField(controller: _nameController),
                      const SizedBox(height: 16),

                      const Text(
                        'Phone number',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildField(controller: _phoneController),
                      const SizedBox(height: 16),

                      const Text('Remark', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildField(controller: _remarkController, maxLines: 4),
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
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  Widget _buildField({TextEditingController? controller, String initial = '', int maxLines = 1}) {
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
      controller: controller,
      initialValue: controller == null ? initial : null,
      maxLines: maxLines,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: InputBorder.none,
      ),
    ),
  );
}
}
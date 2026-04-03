import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/price_checking/views/price_checking_view.dart';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/blocs/wholesale_form_bloc.dart';

class WholesaleFormView extends StatefulWidget {
  const WholesaleFormView({super.key});

  @override
  State<WholesaleFormView> createState() => _WholesaleFormViewState();
}

class _WholesaleFormViewState extends State<WholesaleFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _remarkController;

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

  Future<void> _submit(BuildContext context) async {
    final bloc = context.read<WholesaleFormBloc>();
    final customerName = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final remark = _remarkController.text.trim();

    if (customerName.isEmpty || phoneNumber.isEmpty) {
      _showErrorDialog(
        title: 'Invalid Input',
        message: 'Please enter name and phone.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
      return;
    }

    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(normalizedPhone)) {
      _showErrorDialog(
        title: 'Invalid Phone',
        message: 'Please enter a valid phone number.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
      return;
    }

    bloc.add(const SetSubmitting(true));
    try {
      final selected = bloc.state.selectedProducts;
      final dio = Dio(BaseOptions(baseUrl: ApiUrl.baseUrl));
      final payload = {
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'remark': remark,
        if (selected.isNotEmpty)
          'productImageUrl': selected
              .map((p) => p['image'] ?? '')
              .where((s) => s.isNotEmpty)
              .toList(),
      };

      final resp = await dio.post('/partnership/create', data: payload);
      if (!mounted) return;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _showSuccessDialog(onDismiss: () => Navigator.of(context).pop());
      } else {
        _showErrorDialog(
          title: 'Submission Failed',
          message:
              resp.data?.toString() ??
              'Something went wrong. Please try again.',
          icon: Icons.cloud_off_rounded,
          iconColor: Colors.redAccent,
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        _showErrorDialog(
          title: 'No Connection',
          message:
              'No internet connection. Please check your network and try again.',
          icon: Icons.wifi_off_rounded,
          iconColor: Colors.orangeAccent,
        );
      } else if (e.response != null) {
        _showErrorDialog(
          title: 'Server Error',
          message:
              e.response?.data?['errorMsg'] ??
              'Server error. Please try again later.',
          icon: Icons.cloud_off_rounded,
          iconColor: Colors.redAccent,
        );
      } else {
        _showErrorDialog(
          title: 'Something Went Wrong',
          message: 'Unable to reach the server. Please try again.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        title: 'Submission Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
      );
    } finally {
      if (mounted) bloc.add(const SetSubmitting(false));
    }
  }

  void _showSuccessDialog({VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your wholesale request has been submitted successfully. Our team will contact you shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEC407A),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WholesaleFormBloc(),
      child: Builder(
        builder: (context) => Scaffold(
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
                          // Phone field: only rebuilds when isPhoneValid changes
                          BlocBuilder<WholesaleFormBloc, WholesaleFormState>(
                            buildWhen: (prev, curr) =>
                                prev.isPhoneValid != curr.isPhoneValid,
                            builder: (context, state) => TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: 'Enter phone number',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 1.8,
                                  ),
                                ),
                                errorText:
                                    !state.isPhoneValid &&
                                        _phoneController.text.isNotEmpty
                                    ? 'Please enter a valid phone number'
                                    : null,
                                errorStyle: const TextStyle(fontSize: 12),
                              ),
                              onChanged: (v) {
                                final isValid = RegExp(
                                  r'^0\d{8,9}$',
                                ).hasMatch(v.trim());
                                final bloc = context.read<WholesaleFormBloc>();
                                if (isValid != bloc.state.isPhoneValid) {
                                  bloc.add(SetPhoneValid(isValid));
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text('Remark', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _remarkController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),

                          // Search product (navigates to product list)
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PriceCheckingView(
                                    selectionMode: true,
                                    products: ProductData.allProducts,
                                  ),
                                ),
                              );

                              if (result == null) return;

                              final List<Map<String, String>> items = [];
                              if (result is List) {
                                for (final r in result) {
                                  if (r is Map) {
                                    items.add(Map<String, String>.from(r));
                                  }
                                }
                              } else if (result is Map) {
                                items.add(Map<String, String>.from(result));
                              }

                              if (context.mounted && items.isNotEmpty) {
                                context.read<WholesaleFormBloc>().add(
                                  AddSelectedProducts(items),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
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

                          // Selected products — only rebuilds when the list changes
                          BlocBuilder<WholesaleFormBloc, WholesaleFormState>(
                            buildWhen: (prev, curr) =>
                                prev.selectedProducts != curr.selectedProducts,
                            builder: (context, state) => Column(
                              children: state.selectedProducts
                                  .map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: _buildSelectedCard(context, p),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Submit bar — only rebuilds when isSubmitting changes
                  BlocBuilder<WholesaleFormBloc, WholesaleFormState>(
                    buildWhen: (prev, curr) =>
                        prev.isSubmitting != curr.isSubmitting,
                    builder: (context, state) => Container(
                      width: double.infinity,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC407A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: TextButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => _submit(context),
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCard(BuildContext context, Map<String, String> p) {
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
            onPressed: () => context.read<WholesaleFormBloc>().add(
              RemoveSelectedProduct(p['id'] ?? ''),
            ),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    TextEditingController? controller,
    String initial = '',
    int maxLines = 1,
  }) {
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

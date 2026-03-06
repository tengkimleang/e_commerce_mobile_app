import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';

class OtpView extends StatefulWidget {
  final String phoneNumber;
  const OtpView({super.key, required this.phoneNumber});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _showPin = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_isComplete) return;
    setState(() => _isSubmitting = true);
    // simulate verify
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IndexView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset('assets/images/woman.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Enter your PIN Code',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Please enter the PIN Code to Login.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _controllers.length,
                  (index) => Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        obscureText: !_showPin,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => _onChanged(index, v),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showPin = !_showPin),
                  child: Text(
                    _showPin ? 'Hide PIN' : 'Show PIN',
                    style: const TextStyle(color: Color(0xFFEC407A)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Implement forgot PIN flow if needed
                  },
                  child: const Text('Forgot the PIN code?', style: TextStyle(color: Color(0xFFEC407A))),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_isComplete ? _submit : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('SUBMIT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePinOldPinView extends StatefulWidget {
  const ChangePinOldPinView({super.key});

  @override
  State<ChangePinOldPinView> createState() => _ChangePinOldPinViewState();
}

class _ChangePinOldPinViewState extends State<ChangePinOldPinView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool get _isPinComplete =>
      _controllers.every((controller) => controller.text.length == 1);

  void _onDigitChanged(int index, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.chevron_left,
                  size: 34,
                  color: Color(0xFF7A7A7A),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/woman.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Input Old PIN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1B22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Current PIN',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 28),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Old PIN',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFEC407A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        _controllers.length,
                        (index) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == _controllers.length - 1 ? 0 : 12,
                            ),
                            child: _PinDigitField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textInputAction: index == _controllers.length - 1
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              autofocus: index == 0,
                              onChanged: (value) =>
                                  _onDigitChanged(index, value),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isPinComplete ? () {} : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xFFA6A6A8);
                }
                return const Color(0xFFEC407A);
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
            child: const Text(
              'SUBMIT',
              style: TextStyle(fontSize: 15, letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDigitField extends StatelessWidget {
  const _PinDigitField({
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.autofocus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:64,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 224, 224),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        textInputAction: textInputAction,
        textAlign: TextAlign.center,
        obscureText: true,
        obscuringCharacter: '•',
        enableSuggestions: false,
        autocorrect: false,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1B22),
        ),
        maxLength: 1,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

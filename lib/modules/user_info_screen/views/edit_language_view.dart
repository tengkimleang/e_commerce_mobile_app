import 'package:flutter/material.dart';

Future<String?> showLanguageBottomSheet(
  BuildContext context, {
  required String selectedLanguageCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) => _LanguageBottomSheet(
      selectedLanguageCode: selectedLanguageCode,
      sheetContext: sheetContext,
    ),
  );
}

class _LanguageBottomSheet extends StatelessWidget {
  const _LanguageBottomSheet({
    required this.selectedLanguageCode,
    required this.sheetContext,
  });

  final String selectedLanguageCode;
  final BuildContext sheetContext;

  static const _options = <_LanguageOption>[
    _LanguageOption(code: 'en', label: 'English'),
    _LanguageOption(code: 'km', label: 'Khmer'),
  ];

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.5;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(
                      Icons.highlight_off,
                      color: Color(0xFF8A8A8A),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _options.length; i++) ...[
                _LanguageTile(
                  option: _options[i],
                  isSelected: selectedLanguageCode == _options[i].code,
                  onTap: () => Navigator.of(sheetContext).pop(_options[i].code),
                ),
                if (i != _options.length - 1) const SizedBox(height: 14),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC0C6E);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _FlagView(code: option.code),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ),
              if (isSelected)
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: accent,
                  child: Icon(Icons.check, color: Colors.white, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagView extends StatelessWidget {
  const _FlagView({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    if (code == 'km') return const _KhFlag();
    return const _UkFlag();
  }
}

class _UkFlag extends StatelessWidget {
  const _UkFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 44,
        height: 28,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFF1B4AA5))),
            Align(
              alignment: Alignment.center,
              child: Container(width: 10, color: Colors.white),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(height: 10, color: Colors.white),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(width: 6, color: const Color(0xFFD4152A)),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(height: 6, color: const Color(0xFFD4152A)),
            ),
          ],
        ),
      ),
    );
  }
}

class _KhFlag extends StatelessWidget {
  const _KhFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 44,
        height: 28,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFF0D3DAA))),
            Align(
              alignment: Alignment.center,
              child: Container(height: 14, color: const Color(0xFFC8192B)),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({required this.code, required this.label});

  final String code;
  final String label;
}

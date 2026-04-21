import 'package:flutter/material.dart';

/// Maps a country name string to its Unicode flag emoji.
/// Returns null if no mapping is found, so UI can hide the badge gracefully.
String? countryFlag(String? countryOfOrigin) {
  if (countryOfOrigin == null || countryOfOrigin.isEmpty) return null;
  const map = {
    'cambodia': '🇰🇭',
    'usa': '🇺🇸',
    'united states': '🇺🇸',
    'us': '🇺🇸',
    'japan': '🇯🇵',
    'china': '🇨🇳',
    'korea': '🇰🇷',
    'south korea': '🇰🇷',
    'thailand': '🇹🇭',
    'vietnam': '🇻🇳',
    'indonesia': '🇮🇩',
    'malaysia': '🇲🇾',
    'singapore': '🇸🇬',
    'australia': '🇦🇺',
    'france': '🇫🇷',
    'germany': '🇩🇪',
    'uk': '🇬🇧',
    'united kingdom': '🇬🇧',
    'italy': '🇮🇹',
    'spain': '🇪🇸',
    'india': '🇮🇳',
    'philippines': '🇵🇭',
    'taiwan': '🇹🇼',
    'new zealand': '🇳🇿',
    'canada': '🇨🇦',
  };
  return map[countryOfOrigin.toLowerCase().trim()];
}

/// A small circular flag badge widget.
/// Displays the country flag emoji in a white circle.
class CountryFlagBadge extends StatelessWidget {
  final String countryOfOrigin;
  final double size;

  const CountryFlagBadge({
    super.key,
    required this.countryOfOrigin,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final flag = countryFlag(countryOfOrigin);
    if (flag == null) return const SizedBox.shrink();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        flag,
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// High quality recipe imagery with intelligent food matching,
/// smooth cached network loading, and rich gradient fallbacks.
class RecipeImage extends StatelessWidget {
  final String? imageUrl;
  final String? seed;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const RecipeImage({
    super.key,
    this.seed,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
  });

  static final Map<String, String> _curatedFoodImages = {
    'toast': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800&q=80',
    'egg': 'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=800&q=80',
    'sandwich': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800&q=80',
    'rice': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&q=80',
    'pasta': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&q=80',
    'salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
    'curry': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800&q=80',
    'soup': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&q=80',
    'bowl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
    'taco': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800&q=80',
    'burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
    'pizza': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
    'chicken': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=800&q=80',
    'fish': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800&q=80',
    'pancake': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&q=80',
    'oat': 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=800&q=80',
    'default': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&q=80',
  };

  String get _resolvedImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    final s = (seed ?? '').toLowerCase();
    for (final entry in _curatedFoodImages.entries) {
      if (s.contains(entry.key)) {
        return entry.value;
      }
    }
    return _curatedFoodImages['default']!;
  }

  static const _gradients = [
    [Color(0xFFE0653A), Color(0xFFE8A93A)],
    [Color(0xFF6E8B5D), Color(0xFFA7C09B)],
    [Color(0xFFC44E27), Color(0xFFE8A93A)],
    [Color(0xFF4C8C5A), Color(0xFF6E8B5D)],
    [Color(0xFFE8A93A), Color(0xFFFBEEDF)],
    [Color(0xFF2B2622), Color(0xFFC44E27)],
  ];

  static const _emojis = ['🍝', '🍛', '🥗', '🍲', '🍳', '🌮', '🍜', '🥙', '🥘', '🍱', '🥞', '🍔'];

  int get _hash {
    final s = (seed != null && seed!.isNotEmpty) ? seed! : 'recipe';
    return s.codeUnits.fold(0, (acc, c) => acc + c);
  }

  @override
  Widget build(BuildContext context) {
    final targetUrl = _resolvedImageUrl;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: CachedNetworkImage(
          imageUrl: targetUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _placeholder(),
          errorWidget: (context, url, error) => _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    final gradient = _gradients[_hash % _gradients.length];
    final emoji = _emojis[_hash % _emojis.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
        ],
      ),
    );
  }
}

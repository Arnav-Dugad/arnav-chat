import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../utils/media_url.dart';

/// Circular avatar with cached image, gradient-initials fallback and an
/// optional presence dot.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.url, this.size = 48, this.online = false, this.heroTag});

  final String name;
  final String? url;
  final double size;
  final bool online;
  final Object? heroTag;

  static const _gradients = [
    [Color(0xFF2F5BEA), Color(0xFF27B4D9)],
    [Color(0xFF0E8C94), Color(0xFF3CCFB4)],
    [Color(0xFFD9861C), Color(0xFFF2C14E)],
    [Color(0xFFE0525F), Color(0xFFF59E6C)],
    [Color(0xFF15946A), Color(0xFF7BCB5A)],
    [Color(0xFF4B5BD7), Color(0xFF8A7CF0)],
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final g = _gradients[name.hashCode.abs() % _gradients.length];
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final px = (size * dpr).round();
    Widget fallback() => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: size * 0.38, letterSpacing: -0.3),
            ),
          ),
        );

    Widget circle = SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: url == null || url!.isEmpty
            ? fallback()
            : CachedNetworkImage(
                imageUrl: MediaUrl.thumb(url!, px),
                memCacheWidth: px,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 220),
                placeholder: (_, _) => ColoredBox(color: p.surfaceRaised),
                errorWidget: (_, _, _) => fallback(),
              ),
      ),
    );
    if (heroTag != null) circle = Hero(tag: heroTag!, child: circle);

    return Semantics(
      label: name,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            circle,
            Positioned(
              right: size * 0.02,
              bottom: size * 0.02,
              child: AnimatedScale(
                scale: online ? 1 : 0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Container(
                  width: size * 0.27,
                  height: size * 0.27,
                  decoration: BoxDecoration(
                    color: p.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.bg, width: size * 0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

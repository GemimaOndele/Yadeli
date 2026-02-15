import 'package:flutter/material.dart';

/// Drapeau du Congo — image officielle (triangle vert, bande jaune diagonale, triangle rouge)
class CongoFlag extends StatelessWidget {
  final double width;
  final double height;

  const CongoFlag({super.key, this.width = 36, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/images/drapeau_congo.png',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackFlag(width: width, height: height),
      ),
    );
  }
}

/// Fallback si l'image n'est pas chargée
class _FallbackFlag extends StatelessWidget {
  final double width;
  final double height;

  const _FallbackFlag({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF008E43), const Color(0xFFFBDE00), const Color(0xFFDC241F)],
        ),
      ),
    );
  }
}

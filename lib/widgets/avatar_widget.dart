import 'package:flutter/material.dart';
import '../src/file_utils.dart';
import '../src/file_image_provider.dart';

/// Avatar avec photo ou silhouette selon le genre (morphologie homme/femme)
class AvatarWidget extends StatelessWidget {
  final String? photoPath;
  final String gender;
  final double radius;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.photoPath,
    this.gender = 'homme',
    this.radius = 28,
    this.onTap,
  });

  Color get _defaultColor => gender == 'femme' ? Colors.pink : Colors.blue;

  bool get _hasValidPhoto {
    if (photoPath == null || photoPath!.isEmpty) return false;
    if (photoPath!.startsWith('assets/')) return true;
    return fileExists(photoPath!);
  }

  ImageProvider? get _imageProvider {
    if (!_hasValidPhoto) return null;
    if (photoPath!.startsWith('assets/')) return AssetImage(photoPath!);
    return fileImageProvider(photoPath!);
  }

  /// Icône silhouette selon le genre (morphologie différente homme/femme)
  IconData get _genderIcon => gender == 'femme' ? Icons.female : Icons.male;

  @override
  Widget build(BuildContext context) {
    final child = CircleAvatar(
      radius: radius,
      backgroundColor: _hasValidPhoto ? Colors.transparent : _defaultColor.withOpacity(0.2),
      backgroundImage: _hasValidPhoto ? _imageProvider : null,
      child: !_hasValidPhoto
          ? Icon(_genderIcon, color: _defaultColor, size: radius * 1.4)
          : null,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image with consistent loading and error states across the app.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.iconSize = 28,
  });

  final String url;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return _Fallback(iconSize: iconSize);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, _) => _Fallback(iconSize: iconSize),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: iconSize,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

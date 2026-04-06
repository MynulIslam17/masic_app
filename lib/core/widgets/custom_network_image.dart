import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackAsset;
  final double? height;
  final double? width;
  final Border? border;
  final double? borderRadius;
  final BoxShape boxShape;
  final Color? backgroundColor;
  final Widget? child;
  final ColorFilter? colorFilter;
  final List<BoxShadow>? boxShadow;
  final bool elevation;
  final BoxFit? fit;

  const CustomNetworkImage({
    super.key,
    this.child,
    this.colorFilter,
    this.imageUrl,
    this.fallbackAsset,
    this.backgroundColor,
    this.height,
    this.width,
    this.border,
    this.borderRadius,
    this.boxShape = BoxShape.rectangle,
    this.boxShadow,
    this.elevation = false,
    this.fit,
  });

  BoxDecoration _buildDecoration({ImageProvider? imageProvider}) {
    return BoxDecoration(
      boxShadow: boxShadow ??
          (elevation
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ]
              : null),
      border: border,
      borderRadius: borderRadius != null
          ? BorderRadius.circular(borderRadius ?? 0)
          : null,
      shape: boxShape,
      color: backgroundColor,
      image: imageProvider != null
          ? DecorationImage(
        image: imageProvider,
        fit: fit ?? BoxFit.cover,
        colorFilter: colorFilter,
      )
          : null,
    );
  }

  Widget _buildFallback() {
    if (fallbackAsset != null) {
      return Container(
        height: height,
        width: width,
        decoration: _buildDecoration(
          imageProvider: AssetImage(fallbackAsset!,),
        ),
        child: child,
      );
    }
    // fallbackAsset না থাকলে grey placeholder দেখাবে
    return Container(
      height: height,
      width: width,
      decoration: _buildDecoration(),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // imageUrl null বা empty হলে সরাসরি fallback দেখাও
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    return CachedNetworkImage(
      fit: fit ?? BoxFit.cover,
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        width: width,
        decoration: _buildDecoration(imageProvider: imageProvider),
        child: child,
      ),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            boxShadow: boxShadow ??
                (elevation
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    spreadRadius: 6,
                  ),
                ]
                    : null),
            border: border,
            color: Colors.grey.withOpacity(0.6),
            borderRadius: borderRadius != null
                ? BorderRadius.circular(borderRadius ?? 0)
                : null,
            shape: boxShape,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallback(),
    );
  }
}
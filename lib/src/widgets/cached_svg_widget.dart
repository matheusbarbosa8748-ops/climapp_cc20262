import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CachedSvgWidget extends StatelessWidget {
  const CachedSvgWidget({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || !url.startsWith('http')) {
      return errorWidget ??
          Icon(
            Icons.wb_sunny_outlined,
            size: width ?? 32,
            color: Colors.white70,
          );
    }

    return FutureBuilder<File>(
      future: DefaultCacheManager().getSingleFile(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SvgPicture.file(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        } else if (snapshot.hasError) {
          return errorWidget ??
              SvgPicture.network(
                url,
                width: width,
                height: height,
                fit: fit,
                placeholderBuilder: (context) =>
                    placeholder ??
                    Icon(
                      Icons.wb_cloudy_outlined,
                      size: width ?? 32,
                      color: Colors.white70,
                    ),
              );
        } else {
          return placeholder ??
              SizedBox(
                width: width ?? 32,
                height: height ?? 32,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              );
        }
      },
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ShowFullImage extends StatelessWidget {
  const ShowFullImage(
      {super.key, this.imageLink, this.isNetworkImage = true, this.imageFile})
      : assert(isNetworkImage ? imageLink != null : imageFile != null,
            'If isNetworkImage is true, imageLink must be provided. If isNetworkImage is false, imageFile must be provided.');

  final String? imageLink;
  final bool isNetworkImage;
  final File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InteractiveViewer(
          maxScale: 3.0,
          minScale: 0.4,
          // boundaryMargin: const EdgeInsets.all(double.infinity),
          child: isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: imageLink!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  cacheManager: CacheManager(Config('customCacheKey',
                      stalePeriod: const Duration(days: 7))),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      image: DecorationImage(image: FileImage(imageFile!))),
                ),
        ),
      ),
    );
  }
}

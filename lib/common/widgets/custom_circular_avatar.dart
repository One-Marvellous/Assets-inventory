import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCircularAvatar extends StatelessWidget {
  final String? imageUrl;

  const CustomCircularAvatar({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: imageUrl != null
          ? CachedNetworkImageProvider(
              imageUrl!,
              cacheManager: CacheManager(Config('customCacheKey',
                  stalePeriod: const Duration(days: 7))),
            )
          : const AssetImage("assets/images/no_image.png") as ImageProvider,
    );
  }
}

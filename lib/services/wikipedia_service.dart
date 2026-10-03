import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

class WikipediaService {
  static Future<WikipediaCuriosity?> findRandomNearby(LatLng location) async {
    final uri = Uri.https(
      AppConfig.wikipediaApiHost,
      AppConfig.wikipediaApiPath,
      {
        'action': 'query',
        'generator': 'geosearch',
        'ggscoord': '${location.latitude}|${location.longitude}',
        'ggsradius': AppConfig.wikipediaSearchRadius.toString(),
        'ggslimit': AppConfig.wikipediaSearchLimit.toString(),
        'prop': 'extracts|info|pageimages',
        'inprop': 'url',
        'exintro': '1',
        'explaintext': '1',
        'exchars': AppConfig.wikipediaExtractCharacters.toString(),
        'piprop': 'thumbnail|name',
        'pithumbsize': AppConfig.wikipediaThumbnailSize.toString(),
        'pilicense': 'free',
        'format': 'json',
        'origin': '*',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Api-User-Agent': AppConfig.wikipediaApiUserAgent},
    );

    if (response.statusCode != 200) {
      throw Exception('Wikipedia request failed.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final query = data['query'] as Map<String, dynamic>?;

    if (query == null) {
      return null;
    }

    final pages = query['pages'] as Map<String, dynamic>?;

    if (pages == null || pages.isEmpty) {
      return null;
    }

    final candidates = pages.values.whereType<Map<String, dynamic>>().where((
      page,
    ) {
      final extract = page['extract'];

      return extract is String && extract.trim().isNotEmpty;
    }).toList();

    if (candidates.isEmpty) {
      return null;
    }

    final candidatesWithImages = candidates.where((page) {
      final thumbnail = page['thumbnail'];

      if (thumbnail is! Map<String, dynamic>) {
        return false;
      }

      final source = thumbnail['source'];

      return source is String && source.isNotEmpty;
    }).toList();

    final pool = candidatesWithImages.isNotEmpty
        ? candidatesWithImages
        : candidates;

    final page = pool[Random().nextInt(pool.length)];

    final thumbnail = page['thumbnail'] as Map<String, dynamic>?;

    return WikipediaCuriosity(
      title: page['title'] as String,
      extract: page['extract'] as String,
      url: (page['fullurl'] as String?) ?? 'https://en.wikipedia.org/',
      imageUrl: thumbnail?['source'] as String?,
    );
  }
}

class WikipediaCuriosity {
  const WikipediaCuriosity({
    required this.title,
    required this.extract,
    required this.url,
    this.imageUrl,
  });

  final String title;
  final String extract;
  final String url;
  final String? imageUrl;
}

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class WikipediaService {
  static Future<WikipediaCuriosity?> findRandomNearby(LatLng location) async {
    final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'geosearch',
      'ggscoord': '${location.latitude}|${location.longitude}',
      'ggsradius': '10000',
      'ggslimit': '10',
      'prop': 'extracts|info',
      'inprop': 'url',
      'exintro': '1',
      'explaintext': '1',
      'exchars': '500',
      'format': 'json',
      'origin': '*',
    });

    final response = await http.get(
      uri,
      headers: {'Api-User-Agent': 'OpenStreetMap Explorer/1.0'},
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

    final page = candidates[Random().nextInt(candidates.length)];

    return WikipediaCuriosity(
      title: page['title'] as String,
      extract: page['extract'] as String,
      url: (page['fullurl'] as String?) ?? 'https://en.wikipedia.org/',
    );
  }
}

class WikipediaCuriosity {
  const WikipediaCuriosity({
    required this.title,
    required this.extract,
    required this.url,
  });

  final String title;
  final String extract;
  final String url;
}

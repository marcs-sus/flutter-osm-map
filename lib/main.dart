import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenStreetMap Explorer',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialCenter = LatLng(0, 0);
  static const double _initialZoom = 2;

  LatLng? _selectedLocation;
  bool _isLoading = false;

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  Future<void> _discover() async {
    final location = _selectedLocation;

    if (location == null || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final curiosity = await WikipediaService.findRandomNearby(location);

      if (!mounted) {
        return;
      }

      if (curiosity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Wikipedia articles were found nearby.'),
          ),
        );
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curiosity.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      curiosity.extract,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Source: English Wikipedia',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      curiosity.url,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not retrieve a Wikipedia curiosity.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap Explorer'), elevation: 2),
      body: FlutterMap(
        options: MapOptions(
          cameraConstraint: const CameraConstraint.containLatitude(),
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.osm_map',
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin, size: 40),
                ),
              ],
            ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedLocation == null || _isLoading ? null : _discover,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isLoading ? 'Discovering...' : 'Discover'),
      ),
    );
  }
}

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

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/wikipedia_service.dart';

class Epsg3857NoRepeat extends Epsg3857 {
  const Epsg3857NoRepeat();

  @override
  bool get replicatesWorldLongitude => false;
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
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          crs: const Epsg3857NoRepeat(),
          cameraConstraint: const CameraConstraint.containLatitude(),
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

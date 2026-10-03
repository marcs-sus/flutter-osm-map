import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
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
  static const LatLng _initialCenter = LatLng(
    AppConfig.mapInitialLatitude,
    AppConfig.mapInitialLongitude,
  );
  static const double _initialZoom = AppConfig.mapInitialZoom;

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
                    if (curiosity.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          curiosity.imageUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    if (curiosity.imageUrl != null) const SizedBox(height: 16),
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
            urlTemplate: AppConfig.osmTileUrl,
            userAgentPackageName: AppConfig.osmUserAgentPackageName,
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
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () async {
                  await launchUrl(
                    Uri.parse(AppConfig.osmCopyrightUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
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

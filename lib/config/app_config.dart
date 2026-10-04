import 'package:flutter/material.dart';

// Change these values to customize the app's appearance and behavior
class AppConfig {
  static const appTitle = 'OpenStreetMap Explorer';
  static const appColorScheme = Colors.green;

  static const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';
  static const osmUserAgentPackageName = 'com.example.osm_map';

  static const wikipediaApiHost = 'en.wikipedia.org';
  static const wikipediaApiPath = '/w/api.php';
  static const wikipediaApiUserAgent = 'OpenStreetMap Explorer/1.0';
  static const wikipediaSearchRadius = 10000;
  static const wikipediaSearchLimit = 10;
  static const wikipediaExtractCharacters = 500;
  static const wikipediaThumbnailSize = 500;

  static const mapInitialLatitude = 0.0;
  static const mapInitialLongitude = 0.0;
  static const mapInitialZoom = 2.0;
}

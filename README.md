# flutter_osm_map

A small Flutter application that uses OpenStreetMap to let users select a point on the map and discover nearby Wikipedia articles.

## Features

- Interactive OpenStreetMap map
- Location selection by tapping the map
- A **Discover** action that finds a nearby Wikipedia article
- Short Wikipedia introduction and thumbnail image
- Links to OpenStreetMap attribution and the source Wikipedia article
- Supports Android, Linux, and Web

## Technologies

- [Flutter](https://flutter.dev/)
- [flutter_map](https://pub.dev/packages/flutter_map)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Wikipedia](https://www.wikipedia.org/)
- [`http`](https://pub.dev/packages/http) for API requests
- [`latlong2`](https://pub.dev/packages/latlong2) for geographic coordinates
- [`url_launcher`](https://pub.dev/packages/url_launcher) for external links

### Requirements

Install Flutter and configure the desired Android, Linux, and/or Web development tools.

### Install dependencies

To install dependencies, from the project directory:

```bash
flutter pub get
```

To run the application

For Web:

```bash
flutter run -d chrome
```

For Linux:

```bash
flutter run -d linux
```

For Android, connect an emulator or device and run:

```bash
flutter run
```

## Project structure

```text
lib/
├── app.dart
├── config/
│   └── app_config.dart
├── main.dart
├── pages/
│   └── map_page.dart
└── services/
    └── wikipedia_service.dart
```

- `main.dart` starts the application.
- `app.dart` contains the app-level configuration.
- `map_page.dart` contains the map, selection, and user interface.
- `wikipedia_service.dart` handles the Wikipedia API request and response model.
- `app_config.dart` keeps external URLs and adjustable API/map settings in one place.

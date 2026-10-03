import 'package:flutter/material.dart';

import 'pages/map_page.dart';

import '../config/app_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConfig.appColorScheme,
      ),
      home: const MapPage(),
    );
  }
}

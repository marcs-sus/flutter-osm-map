import 'package:flutter/material.dart';

import 'pages/map_page.dart';

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

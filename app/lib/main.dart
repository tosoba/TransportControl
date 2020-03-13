import 'package:flutter/material.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/pages/home/home_page.dart';
import 'package:transport_control/pages/search/search_page.dart';

void main() {
  configureInjection(Env.dev);
  runApp(TransportControlApp());
}

class TransportControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Transport Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      );
}

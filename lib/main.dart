
import 'package:flutter/material.dart';
import 'package:vehicle_task/screens/detail_fill_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Car Pickup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: DetailsPage(),
    );
  }
}

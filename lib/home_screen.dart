import 'package:flutter/material.dart';

///GPS -> current location->Lat long
/// GPS ->services permission=>yes
/// GPS->service on/of=>YEs
/// get data from gps
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("My location"),
      ),
      body: const Center(
        child: Text("My location"),
      ),
    );
  }
}

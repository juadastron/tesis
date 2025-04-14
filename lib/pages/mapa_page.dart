import 'package:flutter/material.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa en tiempo real')),
      body: const Center(child: Text('Aquí se visualizará el mapa con los dispositivos')),
    );
  }
}

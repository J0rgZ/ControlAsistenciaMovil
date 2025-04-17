import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SedesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Sede {
  final String nombre;
  final String direccion;
  final String descripcion;

  Sede({required this.nombre, required this.direccion, required this.descripcion});
}

class SedesScreen extends StatelessWidget {
  SedesScreen({super.key});

  final List<Sede> sedes = [
     Sede(
      nombre: 'Sede Central',
      direccion: 'Av. Siempre Viva 742',
      descripcion: 'Ubicación principal de la empresa con oficinas administrativas.',
    ),
    Sede(
      nombre: 'Sede Sur',
      direccion: 'Calle Falsa 123',
      descripcion: 'Sucursal ubicada en la zona sur para atención al cliente.',
    ),
    Sede(
      nombre: 'Sede Norte',
      direccion: 'Jr. Progreso 456',
      descripcion: 'Punto estratégico para distribución y logística.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Sedes')),
      body: ListView.builder(
        itemCount: sedes.length,
        itemBuilder: (context, index) {
          final sede = sedes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(sede.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dirección: ${sede.direccion}'),
                  const SizedBox(height: 4),
                  Text(sede.descripcion),
                ],
              ),
              leading: const Icon(Icons.location_city),
            ),
          );
        },
      ),
    );
  }
}

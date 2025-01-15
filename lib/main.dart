import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'proveedores/proveedor_asientos.dart';
import 'pantallas/pantalla_asientos.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProveedorAsientos(),
      child: MaterialApp(
        title: 'Reserva de Asientos Biblioteca',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PantallaAsientos(),
      ),
    );
  }
}

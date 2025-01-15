import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import '../proveedores/proveedor_asientos.dart';

class PantallaAsientos extends StatelessWidget {
  const PantallaAsientos({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<ProveedorAsientos>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva de Asientos Biblioteca'),
      ),
      body: proveedor.estaCargando
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // Número de columnas
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(10),
        itemCount: proveedor.asientos.length * proveedor.asientos[0].length,
        itemBuilder: (context, indice) {
          final fila = indice ~/ 5;
          final columna = indice % 5;
          final estadoAsiento = proveedor.asientos[fila][columna];

          return GestureDetector(
            onTap: estadoAsiento == 'libre'
                ? () => proveedor.reservarAsiento(fila, columna)
                : null,
            child: Container(
              color: estadoAsiento == 'libre'
                  ? Colors.green
                  : estadoAsiento == 'reservado'
                  ? Colors.red
                  : Colors.grey,
              child: Center(
                child: Text('$fila-$columna'),
              ),
            ),
          );
        },
      ),
    );
  }
}

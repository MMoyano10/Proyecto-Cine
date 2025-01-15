import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Asientos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AsientosPage(),
    );
  }
}

class AsientosPage extends StatefulWidget {
  @override
  _AsientosPageState createState() => _AsientosPageState();
}

class _AsientosPageState extends State<AsientosPage> {
  List<List<String>> asientos = [];
  String selectedSection = '1'; // Sección por defecto
  final Map<String, String> sectionNames = {
    '1': 'Infantil',
    '2': 'Juvenil',
    '3': 'Adultos',
    '4': 'Preferencia',
  }; // Mapa de secciones con nombres visibles
  int? selectedFila;
  int? selectedColumna;

  @override
  void initState() {
    super.initState();
    fetchAsientos();
  }

  Future<void> fetchAsientos() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:3000/api/asientos/$selectedSection"));
      if (response.statusCode == 200) {
        setState(() {
          // Mapeamos la respuesta JSON a la variable asientos
          asientos = List<List<String>>.from(
            json.decode(response.body).map((fila) => List<String>.from(fila)),
          );
        });
      } else {
        showSnackBar("Error al obtener los asientos: ${response.statusCode}");
      }
    } catch (e) {
      showSnackBar("Error de conexión: $e");
    }
  }

  Future<void> reservarAsiento(int fila, int columna) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/asientos/reservar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fila': fila,
        'columna': columna,
        'seccion': selectedSection,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        asientos[fila][columna] = 'ocupado';
        selectedFila = null;
        selectedColumna = null;
      });
      showSnackBar("Asiento reservado con éxito");
    } else {
      showSnackBar("Error al reservar el asiento");
      print('Respuesta del servidor: ${response.body}');
    }
  }

  Future<void> cancelarReserva(int fila, int columna) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/asientos/cancelar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fila': fila,
        'columna': columna,
        'seccion': selectedSection,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        asientos[fila][columna] = 'libre';
        selectedFila = null;
        selectedColumna = null;
      });
      showSnackBar("Reserva cancelada con éxito");
    } else {
      showSnackBar("Error al cancelar la reserva");
      print('Respuesta del servidor: ${response.body}');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva de Asientos'),
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar la sección
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedSection,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSection = newValue!;
                });
                fetchAsientos(); // Actualiza la lista de asientos cuando se cambia la sección
              },
              items: sectionNames.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),  // Mostrar el nombre de la sección
                );
              }).toList(),
            ),
          ),
          // Tabla de asientos
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 5 columnas
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 20, // 4 filas * 5 columnas
              itemBuilder: (context, index) {
                int fila = index ~/ 5; // Calcular la fila
                int columna = index % 5; // Calcular la columna
                String estado = asientos.isNotEmpty ? asientos[fila][columna] : "libre";

                return GestureDetector(
                  onTap: () {
                    if (estado == "libre") {
                      setState(() {
                        selectedFila = fila;
                        selectedColumna = columna;
                      });
                    } else if (estado == "reservado") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Cancelar Reserva'),
                            content: Text('¿Estás seguro de que quieres cancelar esta reserva?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  cancelarReserva(fila, columna);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Sí'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: estado == 'libre'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        estado == "libre" ? "Libre" : "Ocupado",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Botón para confirmar la reserva
          if (selectedFila != null && selectedColumna != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  reservarAsiento(selectedFila!, selectedColumna!);
                },
                child: Text('Confirmar Reserva'),
              ),
            ),
        ],
      ),
    );
  }
}

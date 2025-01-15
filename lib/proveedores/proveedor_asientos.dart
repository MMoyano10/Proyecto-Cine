import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProveedorAsientos with ChangeNotifier {
  List<List<dynamic>> _asientos = [];
  bool _cargando = true;

  List<List<dynamic>> get asientos => _asientos;
  bool get estaCargando => _cargando;

  final String urlApi = 'http://localhost:3000/api/asientos';
  // Cambiar por tu URL

  Future<void> obtenerAsientos() async {
    _cargando = true;
    notifyListeners();
    try {
      final respuesta = await http.get(Uri.parse(urlApi));
      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        if (datos is List) {
          _asientos = datos
              .map((fila) =>
          (fila is List) ? fila.map((col) => col.toString()).toList() : [])
              .toList();
        } else {
          throw Exception('Los datos recibidos no tienen el formato esperado');
        }
      } else {
        throw Exception('Error al cargar los asientos: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> reservarAsiento(int fila, int columna) async {
    final url = Uri.parse('$urlApi/reservar');
    final cuerpo = json.encode({'fila': fila, 'columna': columna});
    try {
      final respuesta = await http.post(
        url,
        body: cuerpo,
        headers: {'Content-Type': 'application/json'},
      );
      if (respuesta.statusCode == 200) {
        _asientos[fila][columna] = 'reservado';
        notifyListeners();
      } else {
        throw Exception('Error al reservar el asiento: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

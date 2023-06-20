import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://bancamovilserver.onrender.com/api/";
  static final Logger logger = Logger();

  Future<bool> login(String ci, String password) async {
    try {
      logger.d('API. ci: $ci');
      logger.d('API. password: $password');

      final response = await http.post(
          Uri.parse('https://bancamovilserver.onrender.com/api/login/'),
          body: {
            'ci': ci,
            'password': password,
          });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['token'];

        // Guardar el token de autenticación en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);

        logger.d(
            'Respuesta de la API: ${response.body}'); // Imprimir la respuesta

        return true;
      } else {
        logger.d(response.body);
        return false;
      }
    } catch (e) {
      logger.d('Error en la solicitud de login: $e');
      return false;
    }
  }

  Future<dynamic> getCuentas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://bancamovilserver.onrender.com/api/cuentas/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        logger.d('Respuesta de la API: $jsonResponse');
        return jsonResponse;
      } else {
        logger.d('Error en la solicitud GET: ${response.body}');
        return null;
      }
    } catch (e) {
      logger.d('Error en la solicitud GET: $e');
      return null;
    }
  }

  Future<dynamic> postPagar(nroCuentaOrigen, monto, nroDestino) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      logger.d('Respuesta de la API: ', nroCuentaOrigen);
      final response = await http.post(
        Uri.parse(
            'https://bancamovilserver.onrender.com/api/cuenta/$nroCuentaOrigen/pago'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
              'application/json', // Establecer el tipo de contenido como JSON
        },
        body: jsonEncode({
          'monto': monto,
          'tipomoneda_id': 1,
          'nroCuentaDestino': nroDestino,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        logger.d('Respuesta de la API: $jsonResponse');
        return jsonResponse;
      } else {
        logger.d('Error en la solicitud POST: ${response.body}');
        return null;
      }
    } catch (e) {
      logger.d('Error en la solicitud POST: $e');
      return null;
    }
  }

  Future<dynamic> obtenerMovimientos(nroCuenta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
            'https://bancamovilserver.onrender.com/api/cuenta/$nroCuenta/movimientos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        logger.d('Respuesta de la API: $jsonResponse');
        return jsonResponse;
      } else {
        logger.d('Error en la solicitud GET: ${response.body}');
        return null;
      }
    } catch (e) {
      logger.d('Error en la solicitud GET: $e');
      return null;
    }
  }
}

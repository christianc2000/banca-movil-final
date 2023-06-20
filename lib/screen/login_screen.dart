import 'package:flutter/material.dart';
import 'package:appbancocliente/api_service.dart';
import 'package:appbancocliente/screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController ciController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    final ci = ciController.text;
    final contrasena = contrasenaController.text;
    setState(() {
      isLoading = true; // Activa el indicador de carga
    });
    // Llamada a la API para el inicio de sesión
    ApiService apiService = ApiService();
    bool loginSuccess = await apiService.login(ci, contrasena);
    setState(() {
      isLoading = false; // Desactiva el indicador de carga
    });

    if (loginSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de inicio de sesión'),
          content: const Text('Las credenciales ingresadas son incorrectas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            child: Image.asset(
              'images/imageninicial.png',
              height: 150,
              width: 150,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: ciController,
                  decoration: const InputDecoration(
                    labelText: 'CI',
                  ),
                ),
                TextFormField(
                  controller: contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white, // Texto en color blanco
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

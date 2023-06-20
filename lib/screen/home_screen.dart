import 'package:flutter/material.dart';
import 'package:appbancocliente/screen/cobrar_screen.dart';
import 'package:appbancocliente/screen/pagar_screen.dart';
import 'package:appbancocliente/screen/movimiento_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildButton(
            context,
            'Cobrar',
            Icons.monetization_on,
            colorScheme.primary,
            () {
              // Navegar a la vista Cobrar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CobrarScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildButton(
            context,
            'Pagar',
            Icons.payment,
            colorScheme.primary,
            () {
              // Navegar a la vista Pagar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PagarScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildButton(
            context,
            'Movimientos',
            Icons.compare_arrows,
            colorScheme.primary,
            () {
              // Navegar a la vista Movimiento
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovimientoScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:appbancocliente/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class PagarScreen extends StatefulWidget {
  const PagarScreen({Key? key}) : super(key: key);

  @override
  _PagarScreenState createState() => _PagarScreenState();
}

class _PagarScreenState extends State<PagarScreen> {
  List<dynamic> cuentas = [];
  dynamic selectedOption;
  TextEditingController montoController = TextEditingController();
  TextEditingController cuentaDestinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiService = ApiService();
    final response = await apiService.getCuentas();

    if (response != null) {
      if (mounted) {
        setState(() {
          cuentas = response['cuentas'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccione una Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButton<dynamic>(
                value: selectedOption,
                hint: const Text('Selecciona una opción'),
                items: cuentas.map<DropdownMenuItem<dynamic>>(
                  (dynamic cuenta) {
                    final nro = cuenta['nro'];
                    final bancoId = cuenta['banco_id'];
                    final optionText = '$nro - $bancoId';

                    return DropdownMenuItem<dynamic>(
                      value: cuenta,
                      child: Text(optionText),
                    );
                  },
                ).toList(),
                onChanged: (dynamic value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                underline: Container(), // Remover la línea inferior
                icon: const Icon(
                    Icons.arrow_drop_down), // Icono del botón desplegable
                isExpanded: true, // Expandir el ancho del botón desplegable
              ),
            ),
            if (selectedOption != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saldo: ${selectedOption['saldo']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: montoController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                      r'^\d+\.?\d{0,2}$'), // Expresión regular para números con hasta 2 decimales
                ),
              ],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cuentaDestinoController,
              decoration: const InputDecoration(
                labelText: 'Cuenta Destino',
                border:
                    OutlineInputBorder(), // Agregar un borde al campo de texto
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Escanear el código QR
                String? qrResult = await scanner.scan();

                // Verificar si se obtuvo un resultado del escaneo
                if (qrResult != null) {
                  // Obtener los valores del código QR
                  final qrData = json.decode(qrResult);

                  // Verificar si los datos del código QR son válidos
                  if (qrData != null && qrData is Map<String, dynamic>) {
                    final montoFromQR = qrData['monto'] as String?;
                    final cuentaDestinoFromQR = qrData['nroCuentaDestino'];

                    if (montoFromQR != null && cuentaDestinoFromQR != null) {
                      // Asignar los valores del código QR a las variables correspondientes
                      setState(() {
                        montoController.text = montoFromQR;
                        cuentaDestinoController.text =
                            cuentaDestinoFromQR.toString();
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Código QR Escaneado'),
                          content: Text('¡Escaneo exitoso!'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'El código QR no contiene los datos esperados.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'El código QR no contiene los datos esperados.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Cerrar el diálogo
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text(
                'Leer QR',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Validar que todos los campos estén llenos
                if (selectedOption != null &&
                    montoController.text.isNotEmpty &&
                    cuentaDestinoController.text.isNotEmpty) {
                  // Realizar la acción de pago con los datos ingresados
                  final monto = montoController.text;
                  final cuentaDestino = cuentaDestinoController.text;
                  // Realizar la acción de pago utilizando los datos ingresados
                  final apiService = ApiService();
                  apiService
                      .postPagar(selectedOption['nro'], monto, cuentaDestino)
                      .then((response) {
                    // Manejar la respuesta del método posPagar
                    if (response != null) {
                      // Realizar las acciones necesarias con la respuesta
                      // por ejemplo, mostrar un mensaje de éxito, actualizar la interfaz, etc.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pago Realizado'),
                          content: const Text(
                              'El pago se ha realizado exitosamente.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                                Navigator.pop(
                                    context); // Volver a la pantalla anterior
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Manejar el caso de error en la solicitud posPagar
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Error al realizar el pago.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  });
                } else {
                  // Mostrar un mensaje de error indicando que todos los campos deben estar llenos
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content:
                          const Text('Todos los campos deben estar llenos.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text(
                'Realizar Pago',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

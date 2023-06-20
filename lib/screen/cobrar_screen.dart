import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appbancocliente/api_service.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CobrarScreen extends StatefulWidget {
  const CobrarScreen({Key? key}) : super(key: key);

  @override
  _CobrarScreenState createState() => _CobrarScreenState();
}

class _CobrarScreenState extends State<CobrarScreen> {
  List<dynamic> cuentas = [];
  dynamic selectedOption;
  TextEditingController montoController = TextEditingController();
  TextEditingController cuentaDestinoController = TextEditingController();
  bool showQrImage = false;
  String qrData = '';

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
        title: const Text('Cobrar'),
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
                  Icons.arrow_drop_down,
                ), // Icono del botón desplegable
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
            
            if (showQrImage) ...[
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 270.0,
                    gapless: false,
                    dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Theme.of(context).colorScheme.primary),
                    eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Validar que todos los campos estén llenos
                if (selectedOption != null && montoController.text.isNotEmpty) {
                  // Realizar la acción de pago con los datos ingresados
                  final dataQR = {
                    'nroCuentaDestino': selectedOption['nro'],
                    'monto': montoController.text,
                  };
                  final sdataQR = jsonEncode(dataQR);

                  setState(() {
                    qrData = sdataQR;
                    showQrImage = true;
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
                'Generar QR',
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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:taller_1_diplomado/util.dart';

class SignatureRequestPage extends StatefulWidget {
  const SignatureRequestPage({super.key});

  @override
  State<SignatureRequestPage> createState() => _SignatureRequestPageState();
}

class _SignatureRequestPageState extends State<SignatureRequestPage> {
  List<Map<String, dynamic>> requests = [];
  bool _isLoading = false;
  int? _selectedRequestIndex;
  PlatformFile? pemFile;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await Util.getValue('token');
      if (token == null) {
        Util.showAlert(context, 'Error', 'Token no disponible');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/lista_archivos_firmar'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          if (responseData.isNotEmpty) {
            requests = responseData
                .map((item) => {
                      "fileName": item['nombre_archivo'],
                      "fileHash": item['hash'],
                      "signedBy": item['firmaron'],
                    })
                .toList();
          } else {
            requests = [];
          }
        });
      } else {
        Util.showAlert(
            context, 'Error', 'No se pudieron cargar las solicitudes');
      }
    } catch (e) {
      Util.showAlert(context, 'Error', 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickPemFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem'],
    );

    if (result != null) {
      setState(() {
        pemFile = result.files.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo .pem seleccionado: ${pemFile!.name}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ningún archivo .pem')),
      );
    }
  }

  Future<void> _signFile() async {
    if (_selectedRequestIndex == null || pemFile == null) {
      Util.showAlert(context, 'Error',
          'Debe seleccionar un archivo y cargar la llave privada.');
      return;
    }

    final selectedRequest = requests[_selectedRequestIndex!];
    final fileName = selectedRequest['fileName'];
    final fileHash = selectedRequest['fileHash'];

    final token = await Util.getValue('token');
    final currentUserEmail = await Util.getValue('email');

    if (token == null || currentUserEmail == null) {
      Util.showAlert(context, 'Error', 'Token o email no disponibles.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/firmar_archivo?hash_file=$fileHash'),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'privateKey',
          pemFile!.bytes!,
          filename: pemFile!.name,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        final message = jsonResponse['message'];
        Util.showAlert(context, 'Firma exitosa', message);

        List<String> signedFiles = [];
        final savedFiles = await Util.getValue('signedFiles_$currentUserEmail');
        if (savedFiles != null) {
          signedFiles = List<String>.from(jsonDecode(savedFiles));
        }
        signedFiles.add(fileName);

        await Util.saveValue(
            'signedFiles_$currentUserEmail', jsonEncode(signedFiles));

        setState(() {
          _selectedRequestIndex = null;
          pemFile = null;
        });
      } else {
        Util.showAlert(context, 'Error', 'Error al firmar el archivo.');
      }
    } catch (e) {
      Util.showAlert(context, 'Error', 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : requests.isEmpty
              ? const Text(
                  'No tiene solicitudes pendientes',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                )
              : Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: const EdgeInsets.all(26.0),
                  margin: const EdgeInsets.all(70.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Solicitudes de firmas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRequestTable(),
                        const SizedBox(height: 30),
                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _signFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple[800]!,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Firmar archivo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRequestTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.1),
        1: FlexColumnWidth(0.4),
        2: FlexColumnWidth(0.3),
      },
      border: TableBorder.all(
        color: Colors.deepPurple[800]!,
        width: 1.5,
        borderRadius: BorderRadius.circular(5),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
          ),
          children: [
            const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'NOMBRE DEL ARCHIVO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'CARGAR LLAVE PRIVADA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        ...requests.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> request = entry.value;
          return TableRow(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : Colors.deepPurple[50],
            ),
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Radio<int>(
                  value: index,
                  groupValue: _selectedRequestIndex,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedRequestIndex = value;
                    });
                  },
                ),
              ),
              Tooltip(
                message:
                    "Firmado por: ${request['signedBy'].replaceAll(',', ', ')}",
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Center(
                    child: Text(
                      request['fileName'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple[800],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: pemFile != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              pemFile!.name,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _pickPemFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[800]!,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.vpn_key_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

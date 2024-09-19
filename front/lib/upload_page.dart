// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taller_1_diplomado/util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  FileModel? selectedFile;
  List<UserModel> users = [];
  PlatformFile? fileBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await Util.getValue('token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('http://localhost:5000/lista_usuarios'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = jsonDecode(response.body);

          List<String> emails = responseData['email'].split(',');

          setState(() {
            users = emails
                .map((email) => UserModel(email: email, isChecked: false))
                .toList();
          });
        } else {
          Util.showAlert(
              context, 'Error', 'No se pudieron cargar los usuarios');
        }
      } else {
        Util.showAlert(context, 'Error', 'Token no disponible');
      }
    } catch (e) {
      Util.showAlert(context, 'Error', 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        selectedFile = FileModel(
          name: file.name,
          completed: false,
          progress: 0.0,
        );
        fileBytes = file;
      });

      simulateFileUpload(file.name);
    }
  }

  void simulateFileUpload(String fileName) async {
    for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        if (selectedFile != null && selectedFile!.name == fileName) {
          selectedFile!.progress = progress;

          if (progress.roundToDouble() >= 1.0) {
            selectedFile!.completed = true;
          }
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (selectedFile == null || !selectedFile!.completed || fileBytes == null) {
      Util.showAlert(context, 'Error', 'No se ha cargado ningún archivo.');
      return;
    }

    final selectedUsers = users
        .where((user) => user.isChecked)
        .map((user) => user.email)
        .toList();
    if (selectedUsers.isEmpty) {
      Util.showAlert(context, 'Error', 'No se ha seleccionado ningún usuario.');
      return;
    }

    final token = await Util.getValue('token');
    if (token == null) {
      Util.showAlert(context, 'Error', 'Token no disponible.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://localhost:5000/upload?codigos_usuario=${selectedUsers.join(",")}'),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes!.bytes!,
          filename: fileBytes!.name,
        ),
      );

      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Util.showAlert(context, 'Éxito', 'Solicitud enviada correctamente.');

        setState(() {
          selectedFile = null;
          fileBytes = null;
          for (var user in users) {
            user.isChecked = false;
          }
        });
      } else {
        Util.showAlert(context, 'Error', 'Error al enviar la solicitud.');
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
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.55,
          padding: const EdgeInsets.all(30.0),
          margin: const EdgeInsets.all(46.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Firmar archivos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              const SizedBox(height: 10),
              if (selectedFile != null) FileItem(file: selectedFile!),
              const SizedBox(height: 10),
              UploadButton(pickFiles: pickFiles),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : UserSelection(users: users),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[800]!,
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Realizar solicitud',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class FileModel {
  final String name;
  bool completed;
  double progress;

  FileModel({
    required this.name,
    required this.completed,
    required this.progress,
  });
}

class FileItem extends StatelessWidget {
  final FileModel file;

  const FileItem({required this.file, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            file.completed ? Icons.check_circle : Icons.insert_drive_file,
            color: file.completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (!file.completed)
            Expanded(
              child: LinearProgressIndicator(
                value: file.progress,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
            ),
          if (file.completed)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Cargado',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final VoidCallback pickFiles;

  const UploadButton({required this.pickFiles, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple[800]!, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Center(
        child: InkWell(
          onTap: pickFiles,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Colors.deepPurple[800]!,
              ),
              Text(
                'Cargar archivo',
                style: TextStyle(
                  color: Colors.deepPurple[800]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserModel {
  String email;
  bool isChecked;

  UserModel({required this.email, this.isChecked = false});
}

class UserSelection extends StatefulWidget {
  final List<UserModel> users;

  const UserSelection({required this.users, super.key});

  @override
  State<UserSelection> createState() => _UserSelectionState();
}

class _UserSelectionState extends State<UserSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona los usuarios que recibirán el archivo:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[800],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(
                    widget.users[index].email,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  value: widget.users[index].isChecked,
                  onChanged: (newValue) {
                    setState(() {
                      widget.users[index].isChecked = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

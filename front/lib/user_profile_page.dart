import 'package:flutter/material.dart';
import 'package:taller_1_diplomado/util.dart';
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? name;
  String? phone;
  String? email;
  List<String> signedDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSignedDocuments();
  }

  Future<void> _loadUserData() async {
    final currentUserEmail = await Util.getValue('email');

    if (currentUserEmail != null) {
      final loadedName = await Util.getValue('name_$currentUserEmail');
      final loadedPhone = await Util.getValue('phone_$currentUserEmail');

      setState(() {
        name = loadedName ?? 'No disponible';
        phone = loadedPhone ?? 'No disponible';
        email = currentUserEmail;
      });
    } else {
      setState(() {
        name = 'No disponible';
        phone = 'No disponible';
        email = 'No disponible';
      });
    }
  }

  Future<void> _loadSignedDocuments() async {
    final currentUserEmail = await Util.getValue('email');

    if (currentUserEmail != null) {
      final savedFiles = await Util.getValue('signedFiles_$currentUserEmail');
      if (savedFiles != null) {
        setState(() {
          signedDocuments = List<String>.from(jsonDecode(savedFiles));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple[800],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Perfil de usuario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            UserInfoField(
                              icon: Icons.person,
                              label: 'Nombre',
                              value: name ?? 'No disponible',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserInfoField(
                              icon: Icons.phone,
                              label: 'Teléfono',
                              value: phone ?? 'No disponible',
                            ),
                            const Divider(),
                            UserInfoField(
                              icon: Icons.email,
                              label: 'Email',
                              value: email ?? 'No disponible',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Documentos firmados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: signedDocuments.isNotEmpty
                                ? ListView.builder(
                                    itemCount: signedDocuments.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: Icon(Icons.description,
                                            color: Colors.deepPurple[800]),
                                        title: Text(signedDocuments[index]),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'No hay documentos firmados',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.deepPurple[800],
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

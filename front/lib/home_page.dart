// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taller_1_diplomado/login_page.dart';
import 'package:taller_1_diplomado/signature_request_page.dart';
import 'package:taller_1_diplomado/upload_page.dart';
import 'package:taller_1_diplomado/user_profile_page.dart';
import 'package:taller_1_diplomado/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UploadPage(),
    const SignatureRequestPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? "Subir Archivos"
              : _selectedIndex == 1
                  ? "Solicitudes de firmas"
                  : "Mi Perfil",
          style: const TextStyle(color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: Colors.deepPurple[800],
                    size: 20,
                  ),
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple[800],
      ),
      drawer: _buildDrawer(context),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[800],
            ),
            child: const Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildDrawerItem(
                      icon: Icons.upload_file_rounded,
                      text: 'Subir Archivos',
                      index: 0,
                    ),
                    _buildDrawerItem(
                      icon: Icons.edit_document,
                      text: 'Solicitudes de Firmas',
                      index: 1,
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      text: 'Mi Perfil',
                      index: 2,
                    ),
                  ],
                ),
                Column(
                  children: [
                    ListTile(
                        title: Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Colors.redAccent[700]),
                        ),
                        leading: Icon(
                          Icons.logout_outlined,
                          color: Colors.redAccent[700],
                          size: 20,
                        ),
                        onTap: () async {
                          await Util.removeValue('token');

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
  }) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: Colors.grey[700]),
      ),
      leading: Icon(
        icon,
        color: Colors.deepPurple[800],
        size: 20,
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}

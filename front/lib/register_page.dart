// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taller_1_diplomado/login_page.dart';
import 'package:taller_1_diplomado/util.dart';

final _formKeyName = GlobalKey<FormState>();
final _formKeyPhone = GlobalKey<FormState>();
final _formKeyEmail = GlobalKey<FormState>();
final _formKeyPassword = GlobalKey<FormState>();
final _formKeyConfirmPassword = GlobalKey<FormState>();
late TextEditingController _nameController;
late TextEditingController _phoneController;
late TextEditingController _emailController;
late TextEditingController _passwordController;
late TextEditingController _confirmPasswordController;
late bool _obscureTextState;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _obscureTextState = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final phone = _phoneController.text;
    final email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": name,
          "telefono": phone,
          "email": email,
          "password": _passwordController.text
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Util.saveValue('name_$email', name);
        Util.saveValue('phone_$email', phone);

        final responseData = jsonDecode(response.body);
        final privateKey = responseData['privateKey'];

        _showSuccessfulAlert(
            context, 'Registro exitoso', 'Se ha registrado correctamente');
        Util.downloadPrivateKey(privateKey, 'private_key');
      } else {
        Util.showAlert(
            context, 'Registro incorrecto', 'Por favor, inténtelo nuevamente');
      }
    } catch (e) {
      Util.showAlert(context, 'Error', 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessfulAlert(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro exitoso'),
          content: const Text('¡Te has registrado exitosamente!'),
          actions: [
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.deepPurple[800]!,
                  Colors.white,
                ],
                stops: const [0.5, 0.5],
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.55,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(36.0),
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
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Nombre',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _formKeyName,
                                        child: TextFormField(
                                          controller: _nameController,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            hintText: 'Ingrese su nombre',
                                            helperText: '',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 3),
                                              child: Icon(
                                                Icons.person_outline,
                                                color: Colors.deepPurple[800],
                                                size: 20,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor, ingrese su nombre';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Teléfono',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _formKeyPhone,
                                        child: TextFormField(
                                          controller: _phoneController,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            hintText: 'Ingrese su teléfono',
                                            helperText: '',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 3),
                                              child: Icon(
                                                Icons.phone_outlined,
                                                color: Colors.deepPurple[800],
                                                size: 20,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor, ingrese su teléfono';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'E-mail',
                              style: TextStyle(
                                  color: Colors.deepPurple[800],
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                  color: Colors.redAccent[700],
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKeyEmail,
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  hintText: 'Ingrese su e-mail',
                                  helperText: '',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 3),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: Colors.deepPurple[800],
                                      size: 20,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese su e-mail';
                                  }

                                  final emailRegex =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Por favor, ingresa un correo válido';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Contraseña',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _formKeyPassword,
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscureTextState,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            hintText: 'Ingrese su contraseña',
                                            helperText: '',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 3),
                                              child: Icon(
                                                Icons.vpn_key_outlined,
                                                color: Colors.deepPurple[800],
                                                size: 20,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                                icon: Icon(
                                                  !_obscureTextState
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.deepPurple[800],
                                                ),
                                                iconSize: 18,
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureTextState =
                                                        !_obscureTextState;
                                                  });
                                                }),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor, ingrese su contraseña';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Confirmar contraseña',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _formKeyConfirmPassword,
                                        child: TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: _obscureTextState,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            hintText:
                                                'Ingrese su contraseña nuevamente',
                                            helperText: '',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 3),
                                              child: Icon(
                                                Icons.password_rounded,
                                                color: Colors.deepPurple[800],
                                                size: 20,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                                icon: Icon(
                                                  !_obscureTextState
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.deepPurple[800],
                                                ),
                                                iconSize: 18,
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureTextState =
                                                        !_obscureTextState;
                                                  });
                                                }),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value !=
                                                _passwordController.text) {
                                              return 'Las contraseñas no coinciden';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 110),
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKeyName.currentState!.validate() &&
                                      _formKeyPhone.currentState!.validate() &&
                                      _formKeyEmail.currentState!.validate() &&
                                      _formKeyPassword.currentState!
                                          .validate() &&
                                      _formKeyConfirmPassword.currentState!
                                          .validate()) {
                                    _register();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade800,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 30),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Registrarse',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                              '¿Ya tienes una cuenta? Inicia sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

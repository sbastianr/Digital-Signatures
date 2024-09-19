// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:taller_1_diplomado/home_page.dart';
import 'package:taller_1_diplomado/register_page.dart';
import 'package:taller_1_diplomado/util.dart';

final _formKeyEmail = GlobalKey<FormState>();
final _formKeyPassword = GlobalKey<FormState>();
late TextEditingController _emailController;
late TextEditingController _passwordController;
late bool _obscureTextState;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _obscureTextState = true;
    _checkForQueryParams();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void removeUrlParams() {
    html.window.history.replaceState(null, '', html.window.location.pathname);
  }

  Future<void> _checkForQueryParams() async {
    final Uri uri = Uri.base;
    final String? token = uri.queryParameters['token'];
    final String? privateKey = uri.queryParameters['privateKey'];
    final String? userName = uri.queryParameters['nombre'];
    final String? userEmail = uri.queryParameters['email'];

    if (token != null) {
      await Util.saveValue('token', token);

      if (privateKey != null) {
        Util.downloadPrivateKey(privateKey, 'private_key');
      }

      if (userEmail != null && userName != null) {
        await Util.saveValue('email', userEmail);
        await Util.saveValue('name_$userEmail', userName);
      }

      removeUrlParams();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: const RouteSettings(name: "/inicio"),
        ),
      );
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/inicio_sesion'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final email = _emailController.text;

        Util.saveValue('token', token);
        Util.saveValue('email', email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: const RouteSettings(name: "/inicio"),
          ),
        );
      } else {
        Util.showAlert(
            context, 'Error al iniciar sesión', 'Inténtelo nuevamente');
      }
    } catch (e) {
      Util.showAlert(context, 'Error', 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      html.window.location.href = 'http://localhost:5000/login_google';
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
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
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
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
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, ingrese su contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () {
                                    if (_formKeyEmail.currentState!
                                            .validate() &&
                                        _formKeyPassword.currentState!
                                            .validate()) {
                                      _login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade800,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 30),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    'Ingresar',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                                ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    textStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  icon: Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 30,
                                    color: Colors.red[900],
                                  ),
                                  label: const Text(
                                    'Iniciar sesión con Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _loginGoogle,
                                ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                  settings:
                                      const RouteSettings(name: "/registro"),
                                ),
                              ),
                              child: const Text(
                                  "¿No tienes una cuenta? Regístrate"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[800],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[800],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      './assets/signature_image.png',
                                      width: 250,
                                      height: 250,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

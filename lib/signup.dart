import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login.dart';
import 'main.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controller per i campi di input
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confermaPasswordController = TextEditingController();

  bool _passwordVisible = false;  // Per controllare la visibilità della password
  bool _confermaPasswordVisible = false;  // Per controllare la visibilità della conferma password

  // Funzione per registrare l'utente
  void _registerUser(BuildContext context) async {
    final nome = nomeController.text;
    final cognome = cognomeController.text;
    final username = usernameController.text;
    final numeroTelefono = telefonoController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confermaPassword = confermaPasswordController.text;

    if (password != confermaPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le password non corrispondono",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.13:5001/api/utenti/registrazione');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nome': nome,
        'cognome': cognome,
        'numero_telefono': numeroTelefono,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registrazione effettuata con successo",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Errore nella registrazione: Assicurati che tutti i campi siano compilati correttamente",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: const <Widget>[
                  Text(
                    "Registrati",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF29E2FD),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Crea il tuo account con pochi passaggi",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(
                    label: "Nome",
                    controller: nomeController,
                    icon: Icons.person,
                  ),
                  inputFile(
                    label: "Cognome",
                    controller: cognomeController,
                    icon: Icons.person,
                  ),
                  inputFile(
                    label: "Username",
                    controller: usernameController,
                    icon: Icons.person,
                  ),
                  inputFile(
                    label: "Numero di Telefono",
                    controller: telefonoController,
                    icon: Icons.phone,
                  ),
                  inputFile(
                    label: "Email",
                    controller: emailController,
                    icon: Icons.email,
                  ),
                  inputFile(
                    label: "Password",
                    controller: passwordController,
                    icon: Icons.lock,
                    obscureText: !_passwordVisible,
                    isPassword: true,
                    togglePasswordVisibility: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    passwordVisible: _passwordVisible,
                  ),
                  inputFile(
                    label: "Conferma Password",
                    controller: confermaPasswordController,
                    icon: Icons.lock,
                    obscureText: !_confermaPasswordVisible,
                    isPassword: true,
                    togglePasswordVisibility: () {
                      setState(() {
                        _confermaPasswordVisible = !_confermaPasswordVisible;
                      });
                    },
                    passwordVisible: _confermaPasswordVisible,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    _registerUser(context);
                  },
                  color: const Color(0XFF29E2FD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "Registrati",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Hai già un account?",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      " Accedi",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget per i campi di input
Widget inputFile({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  bool obscureText = false,
  bool isPassword = false,
  bool passwordVisible = false,
  void Function()? togglePasswordVisibility,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.grey[300],
        ),
        cursorColor: Colors.grey[300],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          prefixIcon: Icon(icon, color: Colors.grey[300]), // Icona a sinistra
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[300],
            ),
            onPressed: togglePasswordVisibility,
          )
              : null, // Icona per la visibilità della password
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

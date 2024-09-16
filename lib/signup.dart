import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login.dart';
import 'main.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // Controller per i campi di input
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confermaPasswordController = TextEditingController();

  // Funzione per registrare l'utente
  void _registerUser(BuildContext context) async {
    // Ottieni i dati dai controller
    final nome = nomeController.text;
    final cognome = cognomeController.text;
    final username = usernameController.text;
    final numeroTelefono = telefonoController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confermaPassword = confermaPasswordController.text;

    if (password != confermaPassword) {
      // Mostra un errore se le password non corrispondono
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

    // Costruisci la richiesta HTTP
    final url = Uri.parse('http://10.0.2.2:5001/api/utenti/registrazione');
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
      // Mostra un messaggio di successo e naviga alla pagina di login
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
      // Mostra un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Errore nella registrazione: ${response.body}",
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
      resizeToAvoidBottomInset: true, // Permette alla pagina di adattarsi quando la tastiera appare
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
      body: SingleChildScrollView( // Avvolge il contenuto in uno scroll view
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
                  inputFile(label: "Nome", controller: nomeController),
                  inputFile(label: "Cognome", controller: cognomeController),
                  inputFile(label: "Username", controller: usernameController),
                  inputFile(label: "Numero di Telefono", controller: telefonoController),
                  inputFile(label: "Email", controller: emailController),
                  inputFile(label: "Password", obscureText: true, controller: passwordController),
                  inputFile(label: "Conferma Password", obscureText: true, controller: confermaPasswordController),
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
Widget inputFile({required String label, bool obscureText = false, required TextEditingController controller}) {
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
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Color(0XFF29E2FD))
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

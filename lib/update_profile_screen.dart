import 'package:app_iot/customNavBar.dart';
import 'package:app_iot/home.dart';
import 'package:app_iot/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? username;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        username = decodedToken['user'];
      });
    }
  }

  Future<void> _updateUser() async {
    final url = Uri.parse('http://192.168.1.5:5001/api/utenti/update/$username');

    // Crea un oggetto JSON dinamico che includa solo i campi non vuoti
    Map<String, dynamic> body = {};

    if (nomeController.text.isNotEmpty) {
      body['nome'] = nomeController.text;
    }
    if (cognomeController.text.isNotEmpty) {
      body['cognome'] = cognomeController.text;
    }
    if (emailController.text.isNotEmpty) {
      body['email'] = emailController.text;
    }
    if (telefonoController.text.isNotEmpty) {
      body['numero_telefono'] = telefonoController.text;
    }

    // Se non ci sono campi da aggiornare, esci dalla funzione
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nessun campo da aggiornare')),
      );
      return;
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Gestisci il successo dell'aggiornamento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utente aggiornato con successo')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (e) => CustomNavBar()));
    } else {
      // Gestisci gli errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'aggiornamento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Modifica Account",
          style: TextStyle(color: Colors.grey[300]),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.perm_identity,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: const Color(0XFF29E2FD),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50,),
                      input(icon: Icons.perm_identity, label: "Nome", controller: nomeController),
                      const SizedBox(height: 20,),
                      input(icon: Icons.perm_identity, label: "Cognome", controller: cognomeController),
                      const SizedBox(height: 20,),
                      input(icon: Icons.email_outlined, label: "Email", controller: emailController),
                      const SizedBox(height: 20,),
                      input(icon: Icons.phone, label: "Numero di Telefono", controller: telefonoController),
                      const SizedBox(height: 30,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF29E2FD),
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Modifica",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30,),
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

Widget input({required IconData icon, required String label, required TextEditingController controller}) {
  return Form(
    child: Column(
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.grey[300]),
          cursorColor: Colors.grey[300],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            floatingLabelStyle: const TextStyle(fontSize: 23, color: Color(0XFF29E2FD)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(width: 2, color: Color(0XFF29E2FD))
            ),
            label: Text(label, style: TextStyle(fontSize: 18, color: Colors.grey[300]),),
            prefixIcon: Icon(icon, color: const Color(0XFF29E2FD),),
          ),
        ),
      ],
    ),
  );
}

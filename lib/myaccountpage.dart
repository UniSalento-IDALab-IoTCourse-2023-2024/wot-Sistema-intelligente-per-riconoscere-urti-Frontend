import 'dart:convert';

import 'package:app_iot/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'main.dart';

class MyAccountPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String? nome;
  String? cognome;
  String? username;
  String? email;
  String? numeroTelefono;

  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _numeroTelefonoController;


  String? token;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController();
    _cognomeController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _numeroTelefonoController = TextEditingController();

    _loadToken();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _numeroTelefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token1 = prefs.getString('auth_token');

    if (token1 != null) {
      final decodedToken = JwtDecoder.decode(token1);
      decodedToken.forEach((key, value) {
        print('$key: $value');
      });

      setState(() {
        username = decodedToken['user'];
        token = token1;
      });

      if (username != null) {
        await _findUser();
      }
    }
  }

  Future<void> _findUser() async {
    final url = Uri.parse('http://192.168.1.22:5001/api/utenti/find_by_username/$username');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Dati ricevuti: $responseData');

        setState(() {
          nome = responseData['nome'];
          cognome = responseData['cognome'];
          email = responseData['email'];
          numeroTelefono = responseData['numero_telefono'];

          _nomeController.text = nome ?? '';
          _cognomeController.text = cognome ?? '';
          _usernameController.text = username ?? '';
          _emailController.text = email ?? '';
          _numeroTelefonoController.text = numeroTelefono ?? '';
        });
      } else {
        print('Errore nella richiesta: ${response.statusCode}');
        print('Messaggio di errore: ${response.body}');
      }
    } catch (error) {
      print('Errore nella richiesta: $error');
    }
  }

  Future<void> _deleteAccount() async {
    final url = Uri.parse('http://192.168.1.22:5001/api/utenti/delete/$username');
    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account eliminato con successo'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'eliminazione dell\'account: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella richiesta: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey[850],
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.redAccent),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Conferma Eliminazione',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Conferma',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _deleteAccount();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Annulla',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Account",
          style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
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
                              backgroundColor: Color(0XFF29E2FD),
                              child: Text(
                                "${nome?[0] ?? ''}${cognome?[0] ?? ''}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          /*Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0XFF29E2FD),
                              ),
                              child: Icon(
                                Icons.mode,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      const SizedBox(height: 50),
                      input(
                        controller: _nomeController,
                        icon: Icons.perm_identity,
                        label: "Nome",
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      input(
                        controller: _cognomeController,
                        icon: Icons.perm_identity,
                        label: "Cognome",
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      input(
                        controller: _usernameController,
                        icon: Icons.perm_identity,
                        label: "Username",
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      input(
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        label: "Email",
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      input(
                        controller: _numeroTelefonoController,
                        icon: Icons.phone,
                        label: "Numero di Telefono",
                        readOnly: true,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (e)=> UpdateProfileScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF29E2FD).withOpacity(0.3),
                                  elevation: 0,
                                  foregroundColor: Color(0XFF29E2FD),
                                  side: BorderSide.none,
                                  shape: const StadiumBorder()
                              ),
                              child: const Text("Modifica")
                          ),
                          ElevatedButton(
                            onPressed: () => _showDeleteAccountDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.3),
                              elevation: 0,
                              foregroundColor: Colors.red,
                              shape: const StadiumBorder(),
                              side: BorderSide.none,
                            ),
                            child: const Text("Elimina Account"),
                          )
                        ],
                      ),
                    ],
                  ),

                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget input({
  required TextEditingController controller,
  required IconData icon,
  required String label,
  bool readOnly = false,
}) {
  return Form(
    child: Column(
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.grey[300]),
          cursorColor: Colors.grey[300],
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            floatingLabelStyle:
            const TextStyle(fontSize: 23, color: Color(0XFF29E2FD)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(
                width: 2,
                color: Color(0XFF29E2FD),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(
                color: Color(0XFF29E2FD),
              ),
            ),
            label: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.grey[300]),
            ),
            prefixIcon: Icon(
              icon,
              color: Color(0XFF29E2FD),
            ),
          ),
        )
      ],
    ),
  );
}



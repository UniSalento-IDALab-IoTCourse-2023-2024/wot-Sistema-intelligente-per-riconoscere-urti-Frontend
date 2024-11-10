import 'dart:convert';
import 'dart:io'; // Importa la libreria dart:io
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccidentBrakingPage extends StatefulWidget {
  @override
  _AccidentBrakingPageState createState() => _AccidentBrakingPageState();
}

class _AccidentBrakingPageState extends State<AccidentBrakingPage> {
  List<String> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isListVisible = false; // Flag per mostrare o nascondere la lista
  String? username;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token1 = prefs.getString('auth_token');

    if (token1 != null) {
      final decodedToken = JwtDecoder.decode(token1);
      setState(() {
        username = decodedToken['user'];
        token = token1;
      });
    }
  }

  Future<void> _loadIncidents() async {
    if (_isListVisible) {
      // Se la lista è visibile, la nascondiamo
      setState(() {
        _isListVisible = false;
        _incidents = []; // Svuota la lista degli incidenti
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prepara l'header con il Bearer token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Opzionale, ma buona pratica
      };

      // Effettua la richiesta GET con l'header
      final response = await http.get(
        Uri.parse('http://192.168.1.22:5001/api/incidenti/get_incidenti_by_username/$username'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Incident Response body: ${response.body}');

        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _incidents = data.map((item) {
            if (item is Map<String, dynamic>) {
              return item['date'] as String? ?? 'No incident information';
            } else {
              return 'Invalid item format';
            }
          }).toList();

          _incidents.sort((a, b) {
            DateTime dateA = HttpDate.parse(a); // Usa HttpDate.parse()
            DateTime dateB = HttpDate.parse(b);
            return dateB.compareTo(dateA);
          });

          _isListVisible = true; // Mostra la lista
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load incidents: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching incidents: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Storico Incidenti',
          style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: _loadIncidents,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(_isListVisible ? 'Nascondi Incidenti' : 'Visualizza Incidenti', style: TextStyle(color: Colors.white, fontSize: 17),),
                      SizedBox(width: 7,),
                      Icon(_isListVisible ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined, color: Colors.white,)
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    backgroundColor: Color(0XFF29E2FD).withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: Colors.white,
                      width: 2
                    )
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
            else if (_isListVisible && _incidents.isNotEmpty)
                Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: _incidents.map((incident) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
                        ),
                        child: ListTile(
                          title: Text(
                            incident,
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

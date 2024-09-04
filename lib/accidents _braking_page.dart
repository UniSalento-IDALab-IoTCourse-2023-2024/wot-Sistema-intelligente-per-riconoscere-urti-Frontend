import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccidentBrakingPage extends StatefulWidget {
  @override
  _AccidentBrakingPageState createState() => _AccidentBrakingPageState();
}

class _AccidentBrakingPageState extends State<AccidentBrakingPage> {
  String? _selectedOption;
  List<String> _incidents = [];
  List<String> _brakes = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? username;

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

  Future<void> _loadIncidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.1.7:5001/api/incidenti/get_incidenti_by_username/$username'));

      if (response.statusCode == 200) {
        // Verifica il corpo della risposta
        print('Incident Response body: ${response.body}');

        // Decodifica la risposta JSON come lista
        final List<dynamic> data = json.decode(response.body);

        // Verifica il tipo di dati
        print('Decoded incident data: $data');

        // Assicurati che ogni elemento sia una mappa e estrai gli incidenti
        setState(() {
          _incidents = data.map((item) {
            if (item is Map<String, dynamic>) {
              return item['incident'] as String? ?? 'No incident information';
            } else {
              return 'Invalid item format';
            }
          }).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load incidents';
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

  Future<void> _loadBrakes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.1.7:5001/api/frenate/get_frenate_by_username/$username'));

      if (response.statusCode == 200) {
        // Verifica il corpo della risposta
        print('Brakes Response body: ${response.body}');

        // Decodifica la risposta JSON come lista
        final List<dynamic> data = json.decode(response.body);

        // Verifica il tipo di dati
        print('Decoded brake data: $data');

        // Assicurati che ogni elemento sia una mappa e estrai le frenate
        setState(() {
          _brakes = data.map((item) {
            if (item is Map<String, dynamic>) {
              return item['date'] as String? ?? 'No brake information';
            } else {
              return 'Invalid item format';
            }
          }).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load brakes';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching brakes: $e';
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
          'Storico Incidenti e Frenate',
          style: TextStyle(color: Colors.grey[300]),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButton<String>(
                  value: _selectedOption,
                  hint: Text(
                    'Seleziona un\'opzione',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  dropdownColor: Colors.grey[850],
                  icon: Icon(Icons.arrow_downward, color: Colors.grey[300]),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'incidents',
                      child: Text('Incidenti', style: TextStyle(color: Colors.grey[300])),
                    ),
                    DropdownMenuItem(
                      value: 'brakes',
                      child: Text('Frenate', style: TextStyle(color: Colors.grey[300])),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value;
                      if (value == 'incidents') {
                        _loadIncidents();
                      } else if (value == 'brakes') {
                        _loadBrakes();
                      }
                    });
                  },
                ),
              ),
            ),
            if (_selectedOption != null)
              Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _selectedOption == 'incidents'
                    ? _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                    : ListView(
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
                )
                    : _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                    : ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: _brakes.map((brake) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
                      ),
                      child: ListTile(
                        title: Text(
                          brake,
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

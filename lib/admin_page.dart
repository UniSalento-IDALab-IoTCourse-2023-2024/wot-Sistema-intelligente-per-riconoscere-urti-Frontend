import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'main.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, String>> _incidents = [];
  List<String> _users = [];
  String? _selectedUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showList = false;

  int userCount = 0;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    fetchUserCount();
    fetchUsers();
  }

  Future<void> fetchUserCount() async {
    final response = await http.get(Uri.parse('http://192.168.7.89:5001/api/utenti/'));
    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      setState(() {
        userCount = users.length;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://192.168.7.89:5001/api/utenti/'));
    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      setState(() {
        // Aggiungi "Tutti" alla lista degli utenti
        _users = ['Tutti'] + users.map<String>((user) => user['username'].toString()).toList();
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load users';
      });
    }
  }

  Future<void> _loadIncidents([String? username]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String apiUrl = username == null || username == 'Tutti'
          ? 'http://192.168.7.89:5001/api/incidenti/'
          : 'http://192.168.7.89:5001/api/incidenti/get_incidenti_by_username/$username';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _incidents = data.map<Map<String, String>>((item) {
            if (item is Map<String, dynamic>) {
              return {
                'cliente_incidentato': item['cliente_incidentato'] ?? 'No client',
                'date': item['date'] ?? 'No date',
              };
            } else {
              return {
                'cliente_incidentato': 'Invalid item format',
                'date': 'Invalid item format',
              };
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

  Widget _buildLineChart() {
    if (_incidents.isEmpty) {
      return Center(child: Text('Nessun dato disponibile', style: TextStyle(color: Colors.white)));
    }

    List<double> yValues = _incidents.map((incident) {
      return HttpDate.parse(incident['date']!).millisecondsSinceEpoch.toDouble();
    }).toList();

    double minY = yValues.reduce((a, b) => a < b ? a : b);
    double maxY = yValues.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(
                    '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _incidents.asMap().entries.map((entry) {
                final incidentDate = HttpDate.parse(entry.value['date']!).millisecondsSinceEpoch.toDouble();
                return FlSpot(entry.key.toDouble(), incidentDate);
              }).toList(),
              isCurved: true,
              color: Color(0XFF29E2FD),
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          minX: 0,
          maxX: (_incidents.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Admin', style: TextStyle(color: Colors.grey[300])),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, color: Colors.red,))
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20.0)
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('INFORMAZIONI APPLICAZIONE', style: TextStyle(color: Color(0XFF29E2FD)),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Numero utenti registrati: ', style: TextStyle(color: Colors.grey[300]),),
                        Text('$userCount', style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Numero incidenti avvenuti: ', style: TextStyle(color: Colors.grey[300]),),
                        Text('${_incidents.length}', style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12), // Padding interno
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Colore di sfondo del dropdown
                  borderRadius: BorderRadius.circular(12), // Bordi arrotondati
                  border: Border.all(color: Colors.white, width: 1), // Bordo bianco sottile
                ),
                child: DropdownButton<String>(
                  value: _selectedUser,
                  hint: Text(
                    "Seleziona un utente",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  dropdownColor: Colors.grey[850], // Colore più scuro per il dropdown
                  icon: Icon(Icons.arrow_downward, color: Colors.white),
                  underline: Container(), // Rimuove la linea sottostante
                  style: TextStyle(color: Colors.white), // Colore del testo degli elementi
                  items: _users.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Text(value, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUser = newValue;
                      _loadIncidents(_selectedUser);
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Grafico Andamento Incidenti', style: TextStyle(fontSize: 20, color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 2,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: _buildLineChart(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showList = !_showList;
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0XFF29E2FD), // Colore del testo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Arrotondamento degli angoli
                  side: BorderSide(color: Colors.white, width: 2), // Bordo del pulsante
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding interno
              ),
              child: Text(_showList ? 'Nascondi Lista' : 'Mostra Lista',),
            ),
            SizedBox(height: 20),
            if (_showList)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _incidents.length,
                itemBuilder: (context, index) {
                  final incident = _incidents.reversed.toList()[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Aggiunge un po' di spazio attorno a ogni incidente
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1), // Bordi bianchi di spessore 1
                      borderRadius: BorderRadius.circular(8), // Arrotondamento degli angoli
                    ),
                    child: ListTile(
                      title: Text('Data: ${incident['date']}', style: TextStyle(color: Colors.grey[300])),
                      subtitle: Text('Cliente: ${incident['cliente_incidentato']}', style: TextStyle(color: Colors.grey[500])),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              SizedBox(width: 10),
              Expanded( // Usa Expanded per assicurarti che il titolo sia dinamico
                child: Text(
                  'Conferma Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView( // Aggiungi uno scroll per gestire lo spazio disponibile
            child: Column(
              mainAxisSize: MainAxisSize.min, // Riduci lo spazio occupato dal contenuto
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sei sicuro di voler uscire dall\'app?',
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
                Navigator.of(context).pop(); // Chiude il dialogo
                Navigator.push(context, MaterialPageRoute(builder: (e) => HomePage())); // Chiude l'app o ritorna alla schermata precedente
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
                Navigator.of(context).pop(); // Chiude il dialogo
              },
            ),
          ],
        );
      },
    );
  }
}
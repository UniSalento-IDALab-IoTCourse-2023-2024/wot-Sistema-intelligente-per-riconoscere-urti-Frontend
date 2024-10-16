import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';



class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  static const EventChannel accelerometerChannel = EventChannel('accelerometer_channel');
  static const EventChannel gyroscopeChannel = EventChannel('gyroscope_channel');
  static const MethodChannel usernameChannel = MethodChannel('username_channel');

  late MqttServerClient _client;
  late FlutterTts _flutterTts;
  String accelerometerData = 'Aspettando i dati...';
  String gyroscopeData = 'Aspettando i dati...';
  String? latestMessage;
  String? incidentId;

  String? username;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String recognizedWord = '';


  @override
  void initState() {
    super.initState();
    _initializeMqttClient();
    _listenToAccelerometer();
    _listenToGyroscope();
    _loadToken();

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  // Funzione per chiedere tramite messaggio vocale se è avvenuto un incidente
  Future<void> _speakAndListen() async {
    await _flutterTts.speak("Hai fatto un incidente??");  // Riproduci il messaggio vocale

    _flutterTts.setCompletionHandler(() {  // Quando il messaggio termina, avvia il riconoscimento vocale
      _startListening();
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });

      // Imposta il tempo di ascolto a 5 secondi
      _speech.listen(
        onResult: (val) {
          setState(() {
            recognizedWord = val.recognizedWords;
          });
          _handleRecognizedWord(recognizedWord);  // Invia i risultati alla funzione _handleRecognizedWord
        },
        listenFor: Duration(seconds: 5),  // Ascolta per 5 secondi
        pauseFor: Duration(seconds: 5),   // Se vuoi mettere in pausa per altri 5 secondi dopo l'ascolto
      );

      // Chiudi automaticamente l'ascolto dopo 5 secondi
      Future.delayed(Duration(seconds: 5), () {
        _speech.stop();  // Ferma l'ascolto
        setState(() {
          _isListening = false;
        });
        print('Ascolto terminato automaticamente dopo 5 secondi');
      });
    }
  }


  void _handleRecognizedWord(String word) {
    // Se viene rilevata la parola NO vado a togliere l'incidente dal database
    if (word.toLowerCase() == 'no') {
      _showIncidentDialog(incidentId!);
    }
   /* else {
      // Se non è "no", invia l'email
      if (username != null && incidentId != null) {
        _sendEmail('recprojectdurantepaglialonga@gmail.com', username!);
      }
    }*/
  }

  void _showIncidentDialog(String id) {
    // Chiama sempre la funzione di eliminazione dell'incidente
    _deleteIncident(id);

    // Mostra il dialogo con la notifica dell'eliminazione
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Timer per chiudere automaticamente il dialogo dopo 5 secondi
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();  // Chiude il dialogo automaticamente
          }
        });

        return AlertDialog(
          title: Text('Incidente eliminato'),
        );
      },
    );
  }

  // Funzione per inviare la richiesta DELETE all'API
  Future<void> _deleteIncident(String id) async {
    final url = Uri.parse('http://192.168.7.89:5001/api/incidenti/delete/$id');  // Modifica con il tuo URL del server

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Incidente eliminato con successo');
      } else if (response.statusCode == 404) {
        print('Incidente non trovato');
      } else {
        print('Errore durante l\'eliminazione dell\'incidente: ${response.body}');
      }
    } catch (e) {
      print('Errore di connessione all\'API: $e');
    }
  }

  // Funzione per inviare l'email tramite l'API
  /*Future<void> _sendEmail(String emailReceiver, String username) async {
    // URL dell'API per inviare l'email, sostituisci con il tuo indirizzo IP/server
    final url = Uri.parse('http://192.168.103.187:5001/api/send_email/$emailReceiver/$username');

    try {
      // Richiesta POST
      final response = await http.post(url);

      if (response.statusCode == 200) {
        print('Email inviata con successo');
      } else if (response.statusCode == 500) {
        print('Errore durante l\'invio dell\'email: ${response.body}');
      } else {
        print('Errore sconosciuto: ${response.body}');
      }
    } catch (e) {
      print('Errore di connessione all\'API: $e');
    }
  }*/

  void _initializeMqttClient() async {
    _client = MqttServerClient('test.mosquitto.org', 'flutter_client');
    _client.logging(on: true);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.pongCallback = _onPong;

    try {
      print('Connecting to MQTT broker...');
      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client')
          .startClean()
          .keepAliveFor(20)
          .withWillTopic('willtopic')
          .withWillMessage('Will message')
          .withWillQos(MqttQos.atMostOnce);
      _client.connectionMessage = connMessage;
      await _client.connect();
      print('Connected to MQTT broker.');
      _client.subscribe('iot/notifications', MqttQos.atMostOnce);
    } catch (e) {
      print('Errore nella connessione MQTT: $e');
      _client.disconnect();
    }

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      print('Received message from topic: ${messages[0].topic}>');

      // Decodifica il messaggio ricevuto dal topic MQTT
      final MqttPublishMessage recMess = messages[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('Message content: $message');

      setState(() {
        latestMessage = message;  //Assegna il nuovo messaggio a latestMessage

        // Controlla se il messaggio contiene la parola "incidente"
        if (latestMessage != null && latestMessage!.contains('INCIDENTE')) {
          print('Incidente rilevato! Avvio del riconoscimento vocale.');

          // Estrai l'ID dell'incidente dal messaggio
          final idStartIndex = latestMessage!.indexOf('ID Incidente:') + 'ID Incidente:'.length;
          incidentId = latestMessage!.substring(idStartIndex).trim();

          latestMessage = 'INCIDENTE';

          // Avvia il riconoscimento vocale quando viene rilevato un incidente
          _speakAndListen();

        }
        if (latestMessage != null && latestMessage!.contains('FRENATA')) {
          latestMessage = 'FRENATA';
        }
        else if(latestMessage != null && latestMessage!.contains('ALTRO')){
          latestMessage = 'ALTRO';
        }

      });
    });
  }

  void _onConnected() {
    print('Connesso al broker MQTT');
  }

  void _onDisconnected() {
    print('Disconnesso dal broker MQTT');
  }

  void _onSubscribed(String topic) {
    print('Sottoscritto al topic $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('Disiscritto dal topic $topic');
  }

  void _onPong() {
    print('Pong received');
  }

  void _listenToAccelerometer() {
    accelerometerChannel.receiveBroadcastStream().listen(
          (data) {
        if (mounted) {
          setState(() {
            accelerometerData = '$data';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            accelerometerData = 'Errore: $error';
          });
        }
      },
    );
  }

  void _listenToGyroscope() {
    gyroscopeChannel.receiveBroadcastStream().listen(
          (data) {
        if (mounted) {
          setState(() {
            gyroscopeData = '$data';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            gyroscopeData = 'Errore: $error';
          });
        }
      },
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);

      setState(() {
        username = decodedToken['user'];
      });

      await usernameChannel.invokeMethod('setUsername', {'username': username});
    }
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.grey[300]),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDataCard('Accelerometro', accelerometerData, screenWidth),
                  _buildDataCard('Giroscopio', gyroscopeData, screenWidth),
                ],
              ),
              _buildEventCard('Rilevatore di incidenti', latestMessage, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String data, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 80,
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)],
            ),
            child: Center(
              child: Text(
                data,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0XFF29E2FD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String? message, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 150,
            width: screenWidth - 20,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  message ?? 'Aspettando i dati...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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

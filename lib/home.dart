import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  static const EventChannel accelerometerChannel = EventChannel('accelerometer_channel');
  static const EventChannel gyroscopeChannel = EventChannel('gyroscope_channel');
  static const MethodChannel usernameChannel = MethodChannel('username_channel');

  late MqttServerClient _client;
  String accelerometerData = 'Aspettando i dati...';
  String gyroscopeData = 'Aspettando i dati...';
  List<String> eventMessages = [];

  String? username;

  @override
  void initState() {
    super.initState();
    _initializeMqttClient();
    _listenToAccelerometer();
    _listenToGyroscope();
    _loadToken();
  }

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
      final MqttPublishMessage recMess = messages[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Message content: $message');
      setState(() {
        eventMessages.add(message);  // Aggiungi il nuovo messaggio alla lista
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
              _buildEventCard('Rilevatore di incidenti/frenate', eventMessages, screenWidth),
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

  Widget _buildEventCard(String title, List<String> messages, double screenWidth) {
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
            height: 450,
            width: screenWidth - 20,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)],
            ),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54, // Cambia il colore di sfondo del messaggio
                      borderRadius: BorderRadius.circular(10.0), // Aggiungi bordi arrotondati
                      border: Border.all(
                        color: Color(0XFF29E2FD), // Colore del bordo del messaggio
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white, // Cambia il colore del testo
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

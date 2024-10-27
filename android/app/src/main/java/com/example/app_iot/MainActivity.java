package com.example.app_iot;

import android.annotation.SuppressLint;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Handler;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import java.text.DecimalFormat;

public class MainActivity extends FlutterActivity implements SensorEventListener {

    private static final String BROKER_URL = "tcp://test.mosquitto.org:1883";
    private static final String CLIENT_ID = "client_android_12345";
    private static String USER_ID = "default_user_id";

    // Definizione dei canali per la comunicazione con Flutter
    private static final String ACCELEROMETER_CHANNEL = "accelerometer_channel";
    private static final String GYROSCOPE_CHANNEL = "gyroscope_channel";
    private static final String USERNAME_CHANNEL = "username_channel";

    private SensorManager sensorManager;
    private Sensor accelerometer;
    private Sensor gyroscope;
    private MqttHandler mqttHandler;

    // Variabili in cui vengono salvati gli ultimi valori di accelerometro e giroscopio per essere confrontati con i nuovi valori che arrivano
    private float[] lastAccelerometerValues = new float[3];
    private float[] lastGyroscopeValues = new float[3];

    // Soglie per decidere quando avviene un cambiamento significativo dei valori di accelerometro e giroscopio
    private static final float THRESHOLD_ACC = 1f;
    private static final float THRESHOLD_GYR = 0.005f;

    // Oggetti che servono per gestire i canali di comunicazione
    private EventChannel.EventSink accelerometerSink;
    private EventChannel.EventSink gyroscopeSink;

    private Handler handler = new Handler();
    private static final long UPDATE_INTERVAL = 1000; // 1 second

    // Formattazione dei dati provenienti dai sensori del telefono in 4 cifre decimali
    private DecimalFormat decimalFormat = new DecimalFormat("#.####");

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);

        // Connessione al broker MQTT a cui dobbiamo inviare i dati rilevati dai nostri sensori
        mqttHandler = new MqttHandler();
        mqttHandler.connect(BROKER_URL, CLIENT_ID);

        // Inizializza i valori memorizzati con Float.MAX_VALUE per garantire il rilevamento iniziale
        // in quanto impostando ogni valore delle componenti x,y,z ad un valore iniziale alto, il primo dato rilevato dal sensore sarà sicuramente preso in considerazione poichè avrà un threshold sicuramente maggiore
        for (int i = 0; i < 3; i++) {
            lastAccelerometerValues[i] = Float.MAX_VALUE;
            lastGyroscopeValues[i] = Float.MAX_VALUE;
        }

        // Configura il canale per l'accelerometro
        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), ACCELEROMETER_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        accelerometerSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        accelerometerSink = null;
                    }
                }
        );

        // Configura il canale per il giroscopio
        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GYROSCOPE_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        gyroscopeSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        gyroscopeSink = null;
                    }
                }
        );

        // Configura il canale per la gestione del nome utente (poichè ci possono essere più utenti registrati nel sistema e si deve distinguere a quale utente appartengono quei dati)
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), USERNAME_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("setUsername")) {
                        String username = call.argument("username");
                        if (username != null) {
                            USER_ID = username; // Aggiorna USER_ID
                            result.success("Username set successfully");
                        } else {
                            result.error("UNAVAILABLE", "Username not available.", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
        );


    }

    @Override
    protected void onResume() {
        super.onResume();
        sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);
        sensorManager.registerListener(this, gyroscope, SensorManager.SENSOR_DELAY_NORMAL);
    }

    @Override
    protected void onPause() {
        super.onPause();
        // Mette in stop l'acquisizione dei dati dei sensori
        sensorManager.unregisterListener(this);
        handler.removeCallbacksAndMessages(null);
    }

    // Gestisce quando un valore ha un cambiamento significativo e dunque deve essere inviato tramite MQTT
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            // Se i dati rilevati sono 0 li impostiamo ad un valore prossimo a zero altrimenti vengono considerati "null" e abbiamo problemi con la previsione del modello
            if (z == -0.0f) {
                z = 0.0001f;
            }
            else if (x == -0.0f){
                x = 0.0001f;
            }
            else if (y == -0.0f){
                y = 0.0001f;
            }

            boolean hasChanged = false;

            // Se hanno un cambiamento significativo rispetto al valore soglia allora possono essere mandati al modello di ML tramite MQTT
            if (Math.abs(lastAccelerometerValues[0] - x) > THRESHOLD_ACC) {
                lastAccelerometerValues[0] = x;
                hasChanged = true;
            }

            if (Math.abs(lastAccelerometerValues[1] - y) > THRESHOLD_ACC) {
                lastAccelerometerValues[1] = y;
                hasChanged = true;
            }

            if (Math.abs(lastAccelerometerValues[2] - z) > THRESHOLD_ACC) {
                lastAccelerometerValues[2] = z;
                hasChanged = true;
            }

            // Se c'è stata una variazione significativa su almeno uno degli assi, invia i dati
            if (hasChanged) {
                sendAccelerometerData();
            }
        } else if (event.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            // Se i dati rilevati sono 0 li imppstiamo ad un valore prossimo a zero altrimenti vengono considerati null e abbiamo problemi con la previsione del modello
            if (z == -0.0f) {
                z = 0.0001f;
            }
            else if (x == -0.0f){
                x = 0.0001f;
            }
            else if (y == -0.0f){
                y = 0.0001f;
            }


            boolean hasChanged = false;

            if (Math.abs(lastGyroscopeValues[0] - x) > THRESHOLD_GYR) {
                lastGyroscopeValues[0] = x;
                hasChanged = true;
            }

            if (Math.abs(lastGyroscopeValues[1] - y) > THRESHOLD_GYR) {
                lastGyroscopeValues[1] = y;
                hasChanged = true;
            }

            if (Math.abs(lastGyroscopeValues[2] - z) > THRESHOLD_GYR) {
                lastGyroscopeValues[2] = z;
                hasChanged = true;
            }

            // Se c'è stata una variazione significativa su almeno uno degli assi, invia i dati
            if (hasChanged) {
                sendGyroscopeData();
            }
        }
    }

    // Metodo per inviare i dati di accelerometro sul topic "iot/accelerometer"
    private void sendAccelerometerData() {
        if (accelerometerSink != null) {
            String accelerometerData = "x: " + decimalFormat.format(lastAccelerometerValues[0]) + "\n" +
                    "y: " + decimalFormat.format(lastAccelerometerValues[1]) + "\n" +
                    "z: " + decimalFormat.format(lastAccelerometerValues[2]);
            accelerometerSink.success(accelerometerData);

            publishMessage("iot/accelerometer", accelerometerData);
        }
    }

    // Metodo per inviare i dati di accelerometro sul topic "iot/gyroscope"
    private void sendGyroscopeData() {
        if (gyroscopeSink != null) {
            String gyroscopeData = "x: " + decimalFormat.format(lastGyroscopeValues[0]) + "\n" +
                    "y: " + decimalFormat.format(lastGyroscopeValues[1]) + "\n" +
                    "z: " + decimalFormat.format(lastGyroscopeValues[2]);
            gyroscopeSink.success(gyroscopeData);

            publishMessage("iot/gyroscope", gyroscopeData);
        }
    }

    // Metodo per disconnettersi dal broker MQTT
    @Override
    protected void onDestroy() {
        if (mqttHandler != null) {
            mqttHandler.disconnect();
        }
        super.onDestroy();
        accelerometerSink = null;
        gyroscopeSink = null;
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }

    // Metodo per pubblicare un messaggio tramite MQTT (Si noti che insieme al messaggio viene anche definito l'utente a cui appartengono quei dati)
    private void publishMessage(String topic, String message) {
        String messageWithUserId = "user_id: " + USER_ID + "\n" + message;
        mqttHandler.publish(topic, messageWithUserId);
    }
}

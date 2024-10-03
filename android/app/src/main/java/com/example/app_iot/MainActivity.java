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
    private static String USER_ID = "default_user_id"; // Imposta un valore predefinito

    private static final String ACCELEROMETER_CHANNEL = "accelerometer_channel";
    private static final String GYROSCOPE_CHANNEL = "gyroscope_channel";
    private static final String USERNAME_CHANNEL = "username_channel";

    private SensorManager sensorManager;
    private Sensor accelerometer;
    private Sensor gyroscope;
    private MqttHandler mqttHandler;

    private float[] lastAccelerometerValues = new float[3];
    private float[] lastGyroscopeValues = new float[3];
    private static final float THRESHOLD_ACC = 1f;
    private static final float THRESHOLD_GYR = 0.005f;

    private EventChannel.EventSink accelerometerSink;
    private EventChannel.EventSink gyroscopeSink;

    private Handler handler = new Handler();
    private static final long UPDATE_INTERVAL = 1000; // 1 second

    // Create DecimalFormat instance to format to 4 decimal places
    private DecimalFormat decimalFormat = new DecimalFormat("#.####");

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize SensorManager and sensors
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);

        mqttHandler = new MqttHandler();
        mqttHandler.connect(BROKER_URL, CLIENT_ID);

        // Initialize last values with Float.MAX_VALUE to ensure the first change is detected
        for (int i = 0; i < 3; i++) {
            lastAccelerometerValues[i] = Float.MAX_VALUE;
            lastGyroscopeValues[i] = Float.MAX_VALUE;
        }

        // Set up EventChannel for accelerometer
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

        // Set up EventChannel for gyroscope
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

        // Set up MethodChannel for username
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
        // Register the sensor listeners
        sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);
        sensorManager.registerListener(this, gyroscope, SensorManager.SENSOR_DELAY_NORMAL);
    }

    @Override
    protected void onPause() {
        super.onPause();
        // Unregister the sensor listeners
        sensorManager.unregisterListener(this);
        handler.removeCallbacksAndMessages(null);
    }


    // Meno valori non validi ma acquisizione piu lenta e dunque non rileva alcuni eventi
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            boolean hasChanged = false;

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

            if (hasChanged) {
                sendAccelerometerData();
            }
        } else if (event.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            if (z == -0.0f) {
                z = 0.0001f;
            }
            else if (x == -0.0f){
                x = 0.0001f
            }
            else if (y == -0.0f){
                y = 0.0001f
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

    // Ci sono meno dati non validi ma rileva quasi tutti gli eventi
   /* @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            if (hasSignificantChange(lastAccelerometerValues, x, y, z)) {
                lastAccelerometerValues[0] = x;
                lastAccelerometerValues[1] = y;
                lastAccelerometerValues[2] = z;
                sendAccelerometerData();
            }
        }

        if (event.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            if (hasSignificantChange(lastGyroscopeValues, x, y, z)) {
                lastGyroscopeValues[0] = x;
                lastGyroscopeValues[1] = y;
                lastGyroscopeValues[2] = z;
                sendGyroscopeData();
            }
        }
    }*/


    private void sendAccelerometerData() {
        if (accelerometerSink != null) {
            String accelerometerData = "x: " + decimalFormat.format(lastAccelerometerValues[0]) + "\n" +
                    "y: " + decimalFormat.format(lastAccelerometerValues[1]) + "\n" +
                    "z: " + decimalFormat.format(lastAccelerometerValues[2]);
            accelerometerSink.success(accelerometerData);

            publishMessage("iot/accelerometer", accelerometerData);
        }
    }

    private void sendGyroscopeData() {
        if (gyroscopeSink != null) {
            String gyroscopeData = "x: " + decimalFormat.format(lastGyroscopeValues[0]) + "\n" +
                    "y: " + decimalFormat.format(lastGyroscopeValues[1]) + "\n" +
                    "z: " + decimalFormat.format(lastGyroscopeValues[2]);
            gyroscopeSink.success(gyroscopeData);

            publishMessage("iot/gyroscope", gyroscopeData);
        }
    }

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
        // Not necessary for this example
    }

    private boolean hasSignificantChange(float[] lastValues, float x, float y, float z) {
        return Math.abs(lastValues[0] - x) > THRESHOLD_ACC ||
                Math.abs(lastValues[1] - y) > THRESHOLD_ACC ||
                Math.abs(lastValues[2] - z) > THRESHOLD_ACC;
    }

    private void publishMessage(String topic, String message) {
        String messageWithUserId = "user_id: " + USER_ID + "\n" + message;
        mqttHandler.publish(topic, messageWithUserId);
    }
}

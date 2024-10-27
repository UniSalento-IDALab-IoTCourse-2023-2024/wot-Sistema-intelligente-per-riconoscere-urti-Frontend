package com.example.app_iot;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

public class MqttHandler {

    private MqttClient client;

    // Metodo per connettersi al broker MQTT
    public void connect(String brokerUrl, String clientId) {
        try {
            // Crea persistenza in memoria
            MemoryPersistence persistence = new MemoryPersistence();

            // Inizializza client MQTT
            client = new MqttClient(brokerUrl, clientId, persistence);

            // Configura le opzioni di connessione
            MqttConnectOptions connectOptions = new MqttConnectOptions();
            connectOptions.setCleanSession(false);

            // Connessione al broker
            client.connect(connectOptions);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    // Metodo per disconnettersi dal broker MQTT
    public void disconnect() {
        try {
            client.disconnect();
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    // Metodo per pubblicare un messaggio su uno specifico topic. Imposta QoS a 1
    public void publish(String topic, String message) {
        try {
            MqttMessage mqttMessage = new MqttMessage(message.getBytes());
            mqttMessage.setQos(1);
            client.publish(topic, mqttMessage);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    // Metodo di sottoscrizione ad un preciso topic per ricevere messaggi inviati a quel preciso canale
    public void subscribe(String topic) {
        try {
            client.subscribe(topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }
}


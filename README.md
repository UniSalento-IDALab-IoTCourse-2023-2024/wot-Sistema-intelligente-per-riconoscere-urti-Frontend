# C.A.R.E. 
- - -

## Panoramica
- - -


Il progetto __C.A.R.E.__ si pone l'obiettivo di creare un'app Android per raccogliere dati dai sensori di accelerometro e giroscopio montati su uno smartphone; questi vengono inviati in tempo reale ad un algoritmo di Machine Learning che classifica i dati raccolti in una classe del tipo “incidente” o “altro”. Con il termine "altro" si raggruppano tutti gli eventi di accelerazione constante, accelerazione improvvisa, frenata constante, frenata improvvisa, svolta a destra e svolta a sinistra. Se l’evento rilevato è “incidente”, il fenomeno in questione viene memorizzato all’interno di un database MongoDB per essere analizzato meglio in seguito dall’admin dell’app (responsabile della compagnia assicurativa) mediante opportune dashboard.
L'interfaccia è facile ed intuitiva e permette agli utenti di registrarsi, fare il login, di visualizzare in tempo reale i dati di accelerometro e giroscopio e l’evento che è stato rilevato. 

## ARCHITETTURA DEL SISTEMA
- - -

<div align="center">
  <img src="https://i.ibb.co/9tbRGK7/architettura.jpg" alt="Architettura" width="400"/>
</div>



Le componenti principali dell’architettura sono: 

-	__Front end:__ Realizzato con Flutter, prevede inizialmente un’interfaccia di login e registrazione e, una volta loggato, l’utente può navigare all’interno della sua area riservata visualizzando i dati di accelerometro e giroscopio raccolti in tempo reale, lo storico dei suoi incidenti e le sue informazioni personali, con l’opportunità di poterle modificare. 

-	__Android Studio:__ Grazie all’utilizzo di questo IDE si è creata un’app in grado si acquisire dati in tempo reale dai sensori (accelerometro e giroscopio) situati sullo smartphone su cui l’app viene eseguita.
	Una volta acquisiti vengono inviati, grazie al protocollo MQTT, all’algoritmo di ML che classifica i dati in eventi di incidenti ed altro;

-	__Python:__ Si è addestrato un modello di Random Forest che è in grado di classificare, in base ai dati ricevuti in input, un evento, distinguendolo in una di queste due classi: incidente e altro.
Inoltre, grazie al framework Flask, si sono sviluppate delle API che hanno permesso alle varie componenti dell'applicazione di comunicare con il database MongoDB.


## REPOSITORY DEI COMPONENTI:
- - -
- Machine Learning C.A.R.E.: [Link al repository][git-repo-url1]
- Back-end C.A.R.E.: [Link al repository][git-repo-url2]
- Front-end C.A.R.E.: [Link al repository][git-repo-url3]
- [Pagina web][link_pagina_web]

## FRONT-END C.A.R.E.
- - -

## 1.Gestione falsi positivi:

E' stato impleementato un sistema basato su comando vocale che si attiva nel momento in cui il modello di ML rileva un incidente, chiedendo all’utente di rispondere alla domanda “Hai fatto un incidente?”. In caso di risposta negativa (deve dire la parola “no”) si richiama l’API che elimina l’incidente memorizzato per errore nel database. In questo caso appare una schermata dalla durata di tre secondi (in questo modo l’utente non si distrae andando a togliere personalmente quella notifica) che indica che l’incidente è stato eliminato correttamente.

<div align="center">
  <img src="https://i.ibb.co/mqDwJdQ/Immagine-Whats-App-2024-11-13-ore-19-31-53-0d17bd53.jpg" alt="Gestione_falsi_positivi" width="150"/>
</div>


## 2. Modifica informazioni personali
All'utente viene data la possibilità di modificare le proprie informazioni personali e di eliminare il proprio account.

<div align="center">
  <img src="https://i.ibb.co/s9RS9GD/Immagine-Whats-App-2024-11-13-ore-19-33-35-6386fa61.jpg" alt="Modifica" width="150"/>
</div>


## 3. Visualizzazione dati storici
Quando il modello di ML classifica un evento come "incidente" viene richiamata un API che salva l'evento all'interno del database MongoDB. In questo modo l'utente in qualsiasi momento può visualizzare il suo storico per vedere gli incidenti che ha fatto.

<div align="center">
  <img src="https://i.ibb.co/Nm9VXtV/Immagine-Whats-App-2024-11-13-ore-19-32-54-ad4c1f9e.jpg" alt="Dati_storici" width="150"/>
</div>


## 4. Analisi dati
E' stata implementata una sezione relativa all'admin che offre una panoramica generale dell'applicazione.
In particolare l'amministratore dell'app può visualizzare:

- Statistiche Generali: Numero totale di utenti registrati, numero di incidenti rilevati e dettagli aggiornati sugli eventi raccolti.


- Grafico degli Incidenti: Un grafico interattivo che mostra l'andamento degli incidenti nel tempo, con la possibilità di filtrare i dati per tutti gli utenti o per un singolo utente specifico.

<div align="center">
  <img src="https://i.ibb.co/sbhTzfX/Immagine-Whats-App-2024-11-13-ore-19-32-34-9c91ffa9.jpg" alt="Analisi_dati" width="150"/>
</div>


## Come iniziare:

1. PREREQUISITO FONDAMENTALE: Bisogna avere Flutter installato sul proprio pc


2. Connettere lo smartphone al pc 


3. Recuperare la lista dei dispositivi connessi:
 ```
    Flutter devices
 ```
Da questa lista bisogna estrarsi l'id dello smartphone che abbiamo collegato al pc

4. Installare l'app sul dispositivo
 ```
    Flutter run id_smartphone
 ```


   [git-repo-url1]: <https://github.com/UniSalento-IDALab-IoTCourse-2023-2024/wot-Sistema-intelligente-per-riconoscere-urti-Machine-Learning>
   
   [git-repo-url2]: <https://github.com/UniSalento-IDALab-IoTCourse-2023-2024/wot-Sistema-intelligente-per-riconoscere-urti-Backend>
    
   [git-repo-url3]: <https://github.com/UniSalento-IDALab-IoTCourse-2023-2024/wot-Sistema-intelligente-per-riconoscere-urti-Frontend>
   
   [link_pagina_web]: <https://unisalento-idalab-iotcourse-2023-2024.github.io/wot-project-presentation-Schirinzi-Paglialonga/>
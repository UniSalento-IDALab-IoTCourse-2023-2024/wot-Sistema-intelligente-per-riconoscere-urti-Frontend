import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Spacer(flex:1), // Aggiungi uno Spacer per spingere l'immagine verso l'alto
            Container(
              height: MediaQuery.of(context).size.height / 3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/6.png"),
                    fit: BoxFit.contain
                ),
              ),
            ),
            const SizedBox(height: 20),  // Spazio tra l'immagine e il testo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              child: Text(
                'RECUPERIAMO I TUOI DATI',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(flex:2), // Aggiungi uno Spacer per spingere il testo più in basso
          ],
        )
    );
  }
}

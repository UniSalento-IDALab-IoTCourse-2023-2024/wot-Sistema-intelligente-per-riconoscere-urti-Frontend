import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/5.png"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                child: Text(
                  'CON IL SUPPORTO DEL TUO TELEFONO, RILEVIAMO GLI INCIDENTI',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        )
    );
  }
}

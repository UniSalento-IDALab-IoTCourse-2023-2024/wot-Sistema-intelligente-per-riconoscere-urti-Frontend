import 'package:app_iot/intro_page_1.dart';
import 'package:app_iot/intro_page_2.dart';
import 'package:app_iot/intro_page_3.dart';
import 'package:app_iot/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget{

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>{

  PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
              alignment: Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: (){
                        _controller.jumpToPage(2);
                      },
                      child: Text('SALTA', style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 19
                      ),)
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: WormEffect(
                      dotColor: Colors.grey, // Colore dei pallini non attivi
                      activeDotColor: Color(0XFF29E2FD), // Colore del pallino attivo
                  ),),
                  onLastPage ? GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (e) => HomePage()));
                      },
                      child: Text('INIZIAMO', style: TextStyle(
                          color: Color(0XFF29E2FD),
                          fontSize: 19
                      ),)
                  ) : GestureDetector(
                      onTap: (){
                        _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn
                        );
                      },
                      child: Text('AVANTI', style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 19
                      ),)
                  ),
                ],
              )
          )
        ],
      )
    );
  }
}
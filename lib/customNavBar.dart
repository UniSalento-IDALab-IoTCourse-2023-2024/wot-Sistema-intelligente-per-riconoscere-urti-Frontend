import 'package:app_iot/constants.dart';
import 'package:app_iot/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottom_nav_btn.dart';
import 'clipper.dart';

class CustomNavBar extends StatefulWidget{
  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>{

  int _currentIndex = 0;
  late final PageController pageController;

  @override
  void initState(){
    pageController = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  void animateToPage(int page){
    pageController.animateToPage(
        page,
        duration: Duration(milliseconds: 300),
        curve: Curves.decelerate
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                  child: PageView(
                    controller: pageController,
                    children: screens,
                    onPageChanged: (value){
                      setState(() {
                        _currentIndex = value;
                      });
                    },
                  )
              ),

              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: _buildBottomNavigationBar(context),
              )
            ],
          )
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          10, 0, 10, 30
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        elevation: 10,
        child: Container(
          width: screenWidth,
          height: screenWidth / 100 * 18,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                top: 0,
                left: screenWidth / 100 * 3,
                right: screenWidth / 100 * 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BottomNavBtn(
                      icon: Icons.home,
                      color: Color(0XFF29E2FD),
                      currentIndex: _currentIndex,
                      index: 0,
                      totalIcons: 4,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() {
                          _currentIndex = val;
                        });
                      },
                    ),
                    BottomNavBtn(
                      icon: Icons.history,
                      color: Color(0XFF29E2FD),
                      currentIndex: _currentIndex,
                      index: 1,
                      totalIcons: 4,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() {
                          _currentIndex = val;
                        });
                      },
                    ),
                    BottomNavBtn(
                      icon: Icons.settings,
                      color: Color(0XFF29E2FD),
                      currentIndex: _currentIndex,
                      index: 2,
                      totalIcons: 4,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() {
                          _currentIndex = val;
                        });
                      },
                    ),
                    BottomNavBtn(
                      icon: Icons.exit_to_app,
                      color: Colors.red,
                      currentIndex: _currentIndex,
                      index: 3,
                      totalIcons: 4,
                      onPressed: (val) {
                        _showLogoutDialog(context);
                      },
                    )
                  ],
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.decelerate,
                left: animatedPositionedLeftValue(_currentIndex, context),
                child: Column(
                  children: [
                    Container(
                      height: screenWidth / 100 * 1.0,
                      width: screenWidth / 100 * 12,
                      decoration: BoxDecoration(
                        color: Color(0XFF29E2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ClipPath(
                      clipper: MyCustomClipper(context),
                      child: Container(
                        height: screenWidth / 100 * 15,
                        width: screenWidth / 100 * 12,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter
                            )
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
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
              Expanded(
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (e) => HomePage()));
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

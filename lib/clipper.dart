import 'package:flutter/cupertino.dart';

class MyCustomClipper extends CustomClipper<Path>{

  final BuildContext context;

  MyCustomClipper(this.context);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(MediaQuery.of(context).size.width / 100 * 3, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - MediaQuery.of(context).size.width / 100 * 3, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
  
}
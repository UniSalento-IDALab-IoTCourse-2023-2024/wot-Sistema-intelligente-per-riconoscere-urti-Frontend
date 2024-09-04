import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavBtn extends StatelessWidget {
  const BottomNavBtn({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onPressed,
    required this.color,
    required this.totalIcons, // Add a parameter for the total number of icons
  });

  final IconData icon;
  final Color color;
  final int index;
  final int currentIndex;
  final int totalIcons; // Total number of icons
  final Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed(index);
      },
      child: Container(
        height: MediaQuery.of(context).size.width / 100 * 13,
        width: MediaQuery.of(context).size.width / 100 * 17,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (currentIndex == index)
              Positioned(
                left: MediaQuery.of(context).size.width / 100 * 4,
                bottom: MediaQuery.of(context).size.width / 100 * 1.5,
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: MediaQuery.of(context).size.width / 100 * 8,
                ),
              ),

            // Updated logic for opacity
            AnimatedOpacity(
              opacity: (index == totalIcons - 1 || currentIndex == index) ? 1 : 0.2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: Icon(
                icon,
                color: color,
                size: MediaQuery.of(context).size.width / 100 * 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

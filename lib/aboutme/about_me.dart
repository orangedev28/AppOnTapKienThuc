import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "About Us",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Stack(
        children: [
          Background(),
          Positioned(
            top: 130,
            left: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place),
                    SizedBox(width: 5, height: 5),
                    Text(
                      "Hutech ThuDuc Campus",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 5, height: 5),
                    Text(
                      "Biện Huỳnh Công Khang - 2011060425",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 5, height: 5),
                    Text(
                      "Lê Hoài Lộc - 2011063439",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 253,
            left: 0,
            child: Image.asset(
              'assets/images/hutechback.jpg',
              width: 412.0,
              height: 220.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

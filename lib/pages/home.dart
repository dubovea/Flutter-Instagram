import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  String tabName;

  Home({super.key, required this.tabName});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Column(
          children: [
            Text(
              'Oops, the ${widget.tabName} tab is\n under construction!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28.0),
            ),
            Image.asset('assets/images/building.gif'),
          ],
        ),
      ),
    );
  }
}

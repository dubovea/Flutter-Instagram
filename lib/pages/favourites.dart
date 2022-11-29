import 'package:flutter/material.dart';

class Favourites extends StatefulWidget {
  String tabName;

  Favourites({super.key, required this.tabName});

  @override
  FavouritesState createState() => FavouritesState();
}

class FavouritesState extends State<Favourites> {
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

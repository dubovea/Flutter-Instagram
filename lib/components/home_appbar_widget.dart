import 'package:flutter/material.dart';
import 'package:instagramexample/utils/ui_utils.dart';

class HomeAppBar extends StatelessWidget with PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1.0,
      backgroundColor: Colors.grey[50],
      title: Row(
        children: [
          GestureDetector(
            child: const Text(
              'Instagram',
              style: TextStyle(
                  fontFamily: 'Billabong', color: Colors.black, fontSize: 30.0),
            ),
          ),
          GestureDetector(
              child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          )),
        ],
      ),
      actions: [
        Builder(builder: (BuildContext context) {
          return IconButton(
            color: Colors.black,
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => showSnackbar(context, 'Live TV'),
          );
        }),
        Builder(builder: (BuildContext context) {
          return IconButton(
            color: Colors.black,
            icon: const Icon(Icons.telegram),
            onPressed: () => showSnackbar(context, 'My Messages'),
          );
        }),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

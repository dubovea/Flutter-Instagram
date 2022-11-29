import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:instagramexample/pages/authorization.dart';
import 'package:instagramexample/pages/home.dart';
import 'package:instagramexample/home_feed_page.dart';
import 'package:instagramexample/ui_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'instagramexample',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.black,
      ),
      routes: {
        '/': (context) => Auhorization(),
        '/main': (context) => MainScaffold(),
        '/home': (context) => Home(tabName: 'Home'),
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const _kAddPhotoTabIndex = 2;
  int _tabSelectedIndex = 0;

  // Save the home page scrolling offset,
  // used when navigating back to the home page from another tab.
  double _lastFeedScrollOffset = 0;
  late ScrollController _scrollController;

  @override
  void dispose() {
    _handleScroll();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController == null) {
      return;
    }
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.decelerate,
    );
  }

  // Call this when changing the body that doesn't use a ScrollController.
  void _handleScroll() {
    if (_scrollController != null) {
      _lastFeedScrollOffset = _scrollController.offset;
      _scrollController.dispose();
      _scrollController = null as ScrollController;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _kAddPhotoTabIndex) {
      showSnackbar(context, 'Add Photo');
    } else if (index == _tabSelectedIndex) {
      _scrollToTop();
    } else {
      setState(() => _tabSelectedIndex = index);
    }
  }

  Widget _buildPlaceHolderTab(String tabName) {
    return Home(tabName: tabName);
  }

  Widget _buildBody() {
    switch (_tabSelectedIndex) {
      case 0:
        _scrollController =
            ScrollController(initialScrollOffset: _lastFeedScrollOffset);
        return HomeFeedPage(scrollController: _scrollController);
      default:
        const tabIndexToNameMap = {
          0: 'Home',
          1: 'Search',
          2: 'Add Photo',
          3: 'Notifications',
          4: 'Profile',
        };
        _handleScroll();

        return _buildPlaceHolderTab(tabIndexToNameMap[_tabSelectedIndex]!);
    }
  }

  // Unselected tabs are outline icons, while the selected tab should be solid.
  Widget _buildBottomNavigation() {
    const unselectedIcons = <IconData>[
      Icons.home_outlined,
      Icons.search,
      OMIcons.addBox,
      Icons.favorite_border,
      Icons.person_outline,
    ];
    const selectedIcons = <IconData>[
      Icons.home,
      Icons.search,
      Icons.add_box,
      Icons.favorite,
      Icons.person,
    ];
    final bottomNaivgationItems = List.generate(selectedIcons.length, (int i) {
      final iconData =
          _tabSelectedIndex == i ? selectedIcons[i] : unselectedIcons[i];
      return BottomNavigationBarItem(icon: Icon(iconData), label: '');
    }).toList();

    return Builder(builder: (BuildContext context) {
      return BottomNavigationBar(
        iconSize: 32.0,
        type: BottomNavigationBarType.fixed,
        items: bottomNaivgationItems,
        currentIndex: _tabSelectedIndex,
        onTap: (int i) => _onTabTapped(context, i),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.grey[50],
        title: Row(
          children: [
            Builder(builder: (BuildContext context) {
              return GestureDetector(
                child: const Icon(Icons.camera_alt,
                    color: Colors.black, size: 32.0),
                onTap: () => showSnackbar(context, 'Add Photo'),
              );
            }),
            const SizedBox(width: 12.0),
            GestureDetector(
              onTap: _scrollToTop,
              child: const Text(
                'Instagram',
                style: TextStyle(
                    fontFamily: 'Billabong',
                    color: Colors.black,
                    fontSize: 22.0),
              ),
            ),
          ],
        ),
        actions: [
          Builder(builder: (BuildContext context) {
            return IconButton(
              color: Colors.black,
              icon: const Icon(Icons.live_tv_outlined),
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
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}

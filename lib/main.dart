import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagramexample/components/home_appbar_widget.dart';
import 'package:instagramexample/pages/my_posts.dart';
import 'package:instagramexample/utils/models.dart';
import 'package:instagramexample/pages/authorization.dart';
import 'package:instagramexample/pages/home.dart';
import 'package:instagramexample/pages/favourites.dart';
import 'package:instagramexample/components/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp(firstCamera: firstCamera));
  });
}

class MyApp extends StatelessWidget {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  String name = '';
  String picture = '';
  var firstCamera;

  MyApp({super.key, required this.firstCamera});
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
        '/': (context) => Authorization(),
        '/main': (context) => MainScaffold(),
        '/favourites': (context) => Favourites(tabName: 'Home'),
        '/camera': (context) => Camera(
              // Pass the appropriate camera to the TakePictureScreen widget.
              camera: firstCamera,
            ),
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
  ScrollController _scrollController = ScrollController();

  get firstCamera => firstCamera;

  @override
  void dispose() {
    _handleScroll();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.decelerate,
      );
    }
  }

  // Call this when changing the body that doesn't use a ScrollController.
  void _handleScroll() {
    if (_scrollController.hasClients) {
      _lastFeedScrollOffset = _scrollController.offset;
      _scrollController.dispose();
      _scrollController = ScrollController();
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _kAddPhotoTabIndex) {
      _openCamera();
    } else if (index == _tabSelectedIndex) {
      _scrollToTop();
    } else {
      setState(() => _tabSelectedIndex = index);
    }
  }

  Widget? _buildBody() {
    const tabIndexToNameMap = {
      0: 'home',
      1: 'Search',
      2: 'Add Photo',
      3: 'Notifications',
      4: 'Profile',
    };
    var tabName = tabIndexToNameMap[_tabSelectedIndex]!;

    switch (_tabSelectedIndex) {
      case 0:
        _scrollController =
            ScrollController(initialScrollOffset: _lastFeedScrollOffset);
        return Home(scrollController: _scrollController);
      case 1:
        _handleScroll();
        return Favourites(tabName: tabName);
      case 2:
        _handleScroll();
        return Favourites(tabName: tabName);
      case 3:
        _handleScroll();
        return Favourites(tabName: tabName);
      case 4:
        return MyPosts(currentUser);
      default:
    }
    return null;
  }

  void _openCamera() async {
    Navigator.pushNamedAndRemoveUntil(context, '/camera', (route) => true);
  }

  // Unselected tabs are outline icons, while the selected tab should be solid.
  Widget _buildBottomNavigation() {
    const unselectedIcons = <IconData>[
      Icons.home_outlined,
      Icons.search,
      Icons.live_tv_outlined,
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
      appBar: _tabSelectedIndex == 0 ? HomeAppBar() : null,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}

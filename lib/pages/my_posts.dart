import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagramexample/components/avatar_widget.dart';
import 'package:instagramexample/components/mypost_widget.dart';
import 'package:instagramexample/utils/models.dart';

import '../utils/ui_utils.dart';

class MyPosts extends StatefulWidget {
  const MyPosts(User currentUser, {super.key});

  @override
  MyPostsState createState() => MyPostsState();
}

class MyPostsState extends State<MyPosts> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  int _selectedTab = 0;
  final int _countTabItems = 2;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: _countTabItems);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: Colors.grey[50],
          title: Row(
            children: [
              GestureDetector(
                child: Text(
                  currentUser.name,
                  style: const TextStyle(
                      fontFamily: 'Billabong',
                      color: Colors.black,
                      fontSize: 30.0),
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
                icon: const Icon(Icons.menu),
                onPressed: () => showSnackbar(context, 'My Messages'),
              );
            }),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            const Padding(padding: EdgeInsets.all(8.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AvatarWidget(
                  radius: 34.0,
                  user: currentUser,
                  padding: const EdgeInsets.only(right: 8.0),
                  onTap: () {},
                ),
                Column(
                  children: [
                    const Text('10',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Публикаций')
                  ],
                ),
                Column(
                  children: [
                    const Text('2175',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Подписчиков')
                  ],
                ),
                Column(
                  children: [
                    const Text('2606',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Подписок')
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TKD_ATLET',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                      'Node или Node.js — программная платформа, основанная на движке V8, превращающая JavaScript из узкоспециализированного языка в язык общего назначения. '),
                  const Text('ещё'),
                  Text.rich(TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            text: "www.google.com",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {}),
                      ])),
                  const Padding(padding: EdgeInsets.all(2.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(300, 0),
                              backgroundColor:
                                  const Color.fromARGB(255, 235, 233, 233),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                          onPressed: () {},
                          child: const Text('Редактировать профиль',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.person_add))
                    ],
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            SizedBox(
                height: MediaQuery.of(context).size.height,
                child: DefaultTabController(
                    length: _countTabItems,
                    child: Column(
                      children: <Widget>[
                        Material(
                          color: Colors.grey.shade300,
                          child: TabBar(
                            unselectedLabelColor: Colors.black,
                            labelColor: Colors.black,
                            indicatorColor: Colors.black,
                            controller: _tabController,
                            labelPadding: const EdgeInsets.all(0.0),
                            tabs: [
                              _getTab(
                                  index: 0, child: const Icon(Icons.grid_on)),
                              _getTab(
                                  index: 1,
                                  child: const Icon(Icons.account_box_outlined))
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: [
                              MyPostsWidget(currentUser),
                              const Icon(Icons.directions_transit),
                            ],
                          ),
                        ),
                      ],
                    ))),
          ]),
        ));
  }

  _getTab({required int index, required Widget child}) {
    return Tab(
      child: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: _generateBorderRadius(index)),
          child: child,
        ),
      ),
    );
  }

  _generateBorderRadius(int index) {
    if ((index + 1) == _selectedTab) {
      return const BorderRadius.only(bottomRight: Radius.circular(10.0));
    } else if ((index - 1) == _selectedTab) {
      return const BorderRadius.only(bottomLeft: Radius.circular(10.0));
    } else {
      return BorderRadius.zero;
    }
  }
}

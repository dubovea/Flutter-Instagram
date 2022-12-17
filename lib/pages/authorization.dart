import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Profile extends StatelessWidget {
  final logoutAction;
  String? name = '';
  String? picture = '';

  Profile(this.logoutAction, this.name, this.picture);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4.0),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture ?? ''),
            ),
          ),
        ),
        SizedBox(height: 24.0),
        Text('Name: $name'),
        SizedBox(height: 48.0),
        ElevatedButton(
          onPressed: () {
            logoutAction();
          },
          child: Text('Logout'),
        ),
      ],
    );
  }
}

class Login extends StatelessWidget {
  final loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            loginAction();
          },
          child: Text('Login'),
        ),
        Text(loginError ?? ''),
      ],
    );
  }
}

class Authorization extends StatefulWidget {
  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  String name = '';
  String picture = '';
  UserProfile? _user;
  Auth0? auth0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth0 Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth0 Demo'),
        ),
        body: Center(
          child: isBusy
              ? CircularProgressIndicator()
              : isLoggedIn
                  ? Profile(logoutAction, name, picture)
                  : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  Future<void> loginAction() async {
    var credentials = await auth0!
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
        .login();
    setState(() {
      isLoggedIn = false;
      if (credentials.accessToken.isNotEmpty) {
        isLoggedIn = true;
        name = credentials.user.nickname!;
        picture = '';
        _user = null;
      }
    });
  }

  Future<void> logoutAction() async {
    await auth0!
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
        .logout();

    setState(() {
      isLoggedIn = true;
      _user = null;
    });
  }

  @override
  void initState() {
    super.initState();

    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  }
}

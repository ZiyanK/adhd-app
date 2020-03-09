import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
//              Image(
//                image: AssetImage(),
//              ),
              Text(
                'Username'
              ),
              TextField(),
              Text(
                'Password'
              ),
              TextField()
            ],
          ),
        ),
      ),
    );
  }
}

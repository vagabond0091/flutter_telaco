import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/landingLandlord.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'landingTenant.dart';

class RegisterState extends StatefulWidget {
  @override
  _RegisterStateState createState() => _RegisterStateState();
}

class _RegisterStateState extends State<RegisterState> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmpassword = TextEditingController();
  TextEditingController _name = TextEditingController();
  List<String> _userType = ['landlord', 'tenant'];
  String _selectedUser;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: Container(

        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
        child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Register',
                  style: Theme.of(context).textTheme.headline3,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(hintText: 'Email'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Please enter email";
                    }
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _password,
                  decoration: InputDecoration(hintText: 'Password'),
                  obscureText: true,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _confirmpassword,
                  decoration: InputDecoration(hintText: 'Confirm Password'),
                  obscureText: true,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please re-enter password';
                    }
                    if (_password.text != _confirmpassword.text) {
                      return 'Password Do not match!';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(hintText: 'Name'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Please enter full name";
                    }

                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('User Type:'),
                    DropdownButton(
                        hint: Text('Please choose a user type'),
                        value: _selectedUser,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUser = newValue;

                          });
                        },
                        items: _userType.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList()),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueAccent)),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        )),
                    Text('OR'),
                    SizedBox(height: 20.0),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueAccent)),
                        onPressed: _handleLogin,
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            )),
      ),
    );
  }

  void _handleLogin() async {
    var data = {
      'name': _name.text,
      'email': _email.text,
      'user_type': _selectedUser,
      'password': _password.text
    };
    if (_formkey.currentState.validate()) {
      var res = await CallApi().postData(data, 'createUser');
      var body = jsonDecode(res.body);
      print(body);
      if (body['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Register Successfully')),
        );

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('user', jsonEncode(body['data']));
        var userData;
        var userJson = localStorage.getString('user');
        var user = jsonDecode(userJson);
        setState(() {
          userData = user;
          if (userData['user_type'] == 'landlord') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TenantDashboard()),
            );
          }
        });
      } else {
        _showMsg(body['message']);
      }
      return;
    }
  }
}

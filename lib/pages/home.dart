import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/api/googleSignInApi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'Register.dart';
import 'landingLandlord.dart';
import 'landingTenant.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _mail = TextEditingController();
  TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<String> _userType = ['landlord', 'tenant'];
  bool loading = true;

  String _selectedUser;
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
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headline3,
                ),
                // TextFormField(
                //   controller: _mail,
                //   decoration: InputDecoration(hintText: 'Email'),
                //   validator: (String value) {
                //     if (value.isEmpty) {
                //       return "Please enter email";
                //     }
                //     if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                //         .hasMatch(value)) {
                //       return 'Please enter valid email';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(height: 20.0),
                // TextFormField(
                //     controller: _password,
                //     decoration: InputDecoration(hintText: 'Password'),
                //     obscureText: true,
                //     validator: (String value) {
                //       if (value.isEmpty) {
                //         return 'Please enter password';
                //       }
                //       return null;
                //     }),
                // SizedBox(height: 20.0),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: <Widget>[
                //     TextButton(
                //         style: ButtonStyle(
                //             backgroundColor:
                //                 MaterialStateProperty.all(Colors.deepOrange)),
                //         onPressed: _login,
                //         child: Text(
                //           'Sign In',
                //           style: TextStyle(color: Colors.white),
                //         )),
                //     Text('OR'),
                //     SizedBox(height: 20.0),
                //     TextButton(
                //         style: ButtonStyle(
                //             backgroundColor:
                //                 MaterialStateProperty.all(Colors.deepOrange)),
                //         onPressed: () async {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (context) => RegisterState()),
                //           );
                //         },
                //         child: Text(
                //           'Register',
                //           style: TextStyle(color: Colors.white),
                //         ))
                //   ],
                // ),
                SizedBox(height: 20.0),
                Text('Notes:  please select user type'),
                SizedBox(height: 20.0),
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
                Text('Sign With Google'),
                SizedBox(height: 20.0,),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.green)),
                    onPressed: googleLogin,
                    child:  loading != false ? Text(
                      'Google Sign In',
                      style: TextStyle(color: Colors.white),
                    ) : Text('Loading...',style: TextStyle(color: Colors.white),)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    var data = {
      'email': _mail.text,
      'password': _password.text,
    };

    if (_formkey.currentState.validate()) {
      var res = await CallApi().loginData(data, 'mobile/login');
      var body = jsonDecode(res.body);

      if (body['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Login Successfully')),
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
  Future googleLogin() async{
   final user  =  await GoogleSignInApi.login();
    setState(() {
      loading = false;
    });
   if(user != null){
     var data = {
       'email':user.email,
     };
     var res = await CallApi().loginData(data, 'mobile/login/google');
     var body = jsonDecode(res.body);
     print(body);
     if (body['success']) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Account Login Successfully')),
       );
       SharedPreferences localStorage = await SharedPreferences.getInstance();
       localStorage.setString('user', jsonEncode(body['data']));
       var userData;
       var userJson = localStorage.getString('user');
       var user = jsonDecode(userJson);
       setState(() {
         loading = true;
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

     }
     else {

       var data = {
         'email':user.email,
         'name':user.displayName,
         'provider_id':user.id,
          'user_type':_selectedUser,
       };
      if(_selectedUser != null){
        var res = await CallApi().loginData(data, 'mobile/login/googleSignIn');
        var body = jsonDecode(res.body);
        print(body);
        if (body['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Login Successfully')),
          );
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          localStorage.setString('user', jsonEncode(body['data']));
          var userData;
          var userJson = localStorage.getString('user');
          var user = jsonDecode(userJson);

          setState(() {
            loading = true;
            userData = user;
            print('home screen');
            print(userData);
            if (userData['user_type'] == 'landlord') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LandingPage()),
              );
            }
            else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TenantDashboard()),
              );
            }
          });
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select user type ')),);
      }

       // Navigator.push(
       //   context,
       //   MaterialPageRoute(
       //       builder: (context) => RegisterState()),
       // );
     }
   }
   else{
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Unable to Login ')),
     );
   }

  }

}

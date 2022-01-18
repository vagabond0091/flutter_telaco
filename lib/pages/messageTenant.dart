import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';
import 'messageScreen.dart';

class MessageTenantScreen extends StatefulWidget {
  final int userInfo;
  const MessageTenantScreen({
    Key key,
    this.userInfo
  }) : super(key: key);


  @override
  _MessageTenantScreenState createState() => _MessageTenantScreenState();
}

class _MessageTenantScreenState extends State<MessageTenantScreen> {
  List listOfTenant = [];
  var name;
  var email;
  var avatar;
  var avatarOriginal;
  int receiverId;
  int unreadMsg;
  bool isLoading = true;
  Timer  timer;
  var incomingMessage = 'You have a New Messages';
  @override
  void initState() {



    getAllTenantMessage();
    startLoading();
    super.initState();

  }
  void startLoading() async{
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        isLoading = false;
      });
    });
  }
  Future<void> getAllTenantMessage() async{
    var res = await CallApi().getData('getMessageUser/${widget.userInfo}');
    var items = jsonDecode(res.body);


    setState(() {
         name = items['landlord']['user']['name'];
         email = items['landlord']['user']['email'];
         avatar = items['landlord']['user']['avatar'];
         avatarOriginal = items['landlord']['user']['avatar_original'];
         receiverId = items['landlord']['user']['id'];
         unreadMsg = items['messages'];
         print(unreadMsg);

    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text( MyApp.title),

      ),
      body: message(),
    );
  }
  Widget message(){

    return name != null ?
    Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration:BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image:NetworkImage(avatarOriginal != null ? '$avatarOriginal':'$avatar')
                ,   fit: BoxFit.fill
            ),
          ) ,
        ),
        title: Text(name != null ? '$name ':'') ,
        subtitle: Text(email != null ? '$email':''),
        trailing: Container(
          child: unreadMsg != 0 ?  Text('$incomingMessage' ,style: TextStyle(
    fontWeight: FontWeight.bold,

    fontSize: 13.0
    )) : Text('') ),
        onTap:  (){
            setState(() {
              unreadMsg = 0;
            });
          var route  = new MaterialPageRoute(builder: (BuildContext context) =>
          new MessageScreen(myId: widget.userInfo,recieverId:receiverId,recieverName:name,
            avatarOriginal:avatarOriginal,avatar: avatar,
          ),
          );
          Navigator.of(context).push(route);

        },

      ),
    ) : Center(
      child:
      isLoading ? SpinKitDoubleBounce(
        size: 80.0,
        color: Colors.deepOrange[800],
      ) :Text('You are not renting a property !')
    );
  }
}

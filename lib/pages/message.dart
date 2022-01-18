import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/messageScreen.dart';

import '../main.dart';

class Message extends StatefulWidget {
  final int landlord;
  const Message({
    Key key,
    this.landlord
  }) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
List listOfTenant = [];
List messages = [];
bool isLoading = true;
bool loading = false;
int landlordId;
List newDataList = [];
Timer  timer;
var incomingMessage = 'You have a New Messages';
  @override
  void initState() {
    if(widget.landlord != null){
      landlordId = widget.landlord;
     
    }
    getAllTenantMessage();
    startLoading();
    super.initState();

  }
void startLoading() async{
  timer = Timer.periodic(Duration(seconds: 3), (_) {
    setState(() {
      isLoading = false;
    });
  });
}
  void getAllTenantMessage() async{
    var res = await CallApi().getData('getMessageUser/landlord/$landlordId');
    var items = jsonDecode(res.body);
    print(items);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
     setState(() {
       listOfTenant = myMap['property'];

       messages = myMap['messages'];
      messages.forEach((element) {
        newDataList.add(element['id']);
        print(newDataList);

      });
      loading = true;


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
    return loading != false ? ListView.builder(
      itemCount: listOfTenant.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context,index){
        int id = listOfTenant[index]['id'];
        print(id);
        bool newMessage = newDataList.contains(id);
        print(newMessage);
        return Card(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration:BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image:NetworkImage(listOfTenant[index]['avatar_original'] != null ? '${listOfTenant[index]['avatar_original']}':'${listOfTenant[index]['avatar']}')
                    ,   fit: BoxFit.fill
                ),
              ) ,
            ),
            title: Text(listOfTenant[index]['name'] != null ? '${listOfTenant[index]['name']} ':'') ,
            subtitle: Text(listOfTenant[index]['email'] != null ? '${listOfTenant[index]['email']}':''),
           trailing: newMessage ? Text('$incomingMessage' ,style: TextStyle(
             fontWeight: FontWeight.bold,

             fontSize: 13.0
           )) : Text(''),
            onTap:  (){
              int userId;
              if(listOfTenant[index]['user_id'] != null ){
                 userId = listOfTenant[index]['user_id'];
              }
              else{
                userId = listOfTenant[index]['id'];
              }
              setState(() {
                incomingMessage = '';


              });
              var route  = new MaterialPageRoute(builder: (BuildContext context) =>
              new MessageScreen(myId: widget.landlord,recieverId:userId,recieverName:listOfTenant[index]['name'],
                  avatarOriginal:listOfTenant[index]['avatar_original'],avatar: listOfTenant[index]['avatar'],
              ),
              );
              Navigator.of(context).push(route);
            },

          ),
        );
      },
    ) :Center(
        child:
        isLoading != false ? SpinKitDoubleBounce(
          size: 80.0,
          color: Colors.deepOrange[800],
        ) :Text('You  dont have a tenant ! ')
    );
  }
}

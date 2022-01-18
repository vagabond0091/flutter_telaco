import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class Notifications extends StatefulWidget {
  final int userId;
  const Notifications(
      {
      Key key,this.userId,
      }
  ) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int user;
  List notificationsData = [];
  @override
  void initState() {
    if(widget.userId != null){
      user = widget.userId;
    }
    getAllNotifications();
    super.initState();

  }
  void getAllNotifications() async{
    var res = await CallApi().getData('getAllNotificationPerTenant/$user');
    var items = jsonDecode(res.body);

    // print(eventDateMap);
    Map<String, dynamic > myMap = Map<String, dynamic>.from(items);

    setState(() {
      notificationsData = myMap['data'];

      updateAllNotifications();



    });

  }
  void updateAllNotifications() async{
    var res = await CallApi().updateSingleData('updateNotification/$user');
    var items = jsonDecode(res.body);
    print(items);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: notifications() ,
    );
  }
  Widget notifications(){
    return
      SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(

        children: [

          Container(
            child: ListView.builder(
            itemCount: notificationsData.length,
                physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context,index){
              return Card(

                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      leading:  Icon(Icons.notification_important,color: Colors.deepOrange[800],),
                      title: Text('${notificationsData[index]['message_notification']}',style: TextStyle(
                      ),) ,
                      // trailing: Text(DateFormat('d MMMM y ').format(DateTime.tryParse(notificationsData[index]['created_at']))),
                    ),
                  )
              );
            }),
          )
        ],
    ),
      );
  }
}

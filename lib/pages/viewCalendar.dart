import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';

class ViewCalendar extends StatefulWidget {
  final  int user;
  const ViewCalendar(
      {
        Key key,
        this.user,
      }
      ) : super(key: key);

  @override
  _ViewCalendarState createState() => _ViewCalendarState();
}

class _ViewCalendarState extends State<ViewCalendar> {
  List eventData = [];
  List _eventDate = [];
  Map<DateTime, List > _groupedEvent ={};
  int tenantData;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  @override
  void initState() {
    tenant();
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
  void tenant() async{
    var res = await CallApi().getData('tenant/${widget.user}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    var dataTenant = myMap['data']['id'];

    setState(() {
      tenantData = dataTenant;
      getSchedule(tenantData);
    });
  }
  void getSchedule(tenant) async{
    var res = await CallApi().getData('mobile/getAllSchedule/$tenant');
    var items = jsonDecode(res.body);

    // print(eventDateMap);
    Map<String, dynamic > myMap = Map<String, dynamic>.from(items);

    setState(() {
      eventData = myMap['data'];




    });
    loading = true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text( MyApp.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.only(left:16.0,right: 16.0),
            child: Text('List of Schedule',style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            )),
          ),
          SizedBox(height: 20.0),
          Container(


            child:  loading != false ?  ListView.builder(
                itemCount: eventData.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
                itemBuilder: (context,index){
                  return Card(
                    color: Colors.deepOrangeAccent,
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Property: ${eventData[index]['title']}',style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.0,
                          )),
                          Text('Date: ${eventData[index]['start']}',style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.0,
                          )),
                          // Text('${eventData[index]['id']}'),
                          IconButton(onPressed: (){
                            deleteInquiry(eventData[index]['id']);
                          },
                              icon: Icon(Icons.delete,color: Colors.white,size: 22.0)),
                        ],
                      ),

                    ),
                  );
                }) : Center(
                child:
                isLoading != false ? SpinKitDoubleBounce(
                  size: 80.0,
                  color: Colors.deepOrange[800],
                ) :Text('')),
          )
        ],
      ),
    );
  }

  void deleteInquiry(id) async{
    print(id);
    var res = await CallApi().deleteData('deleteInquiry/$id');
    print(res.body);
    var body = jsonDecode(res.body);
    print(body);
    if(body['success']){
      _showMsg(body['message']);
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => this.widget));

      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Delete  Schedule ')),
      );
    }

  }
}

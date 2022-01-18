import 'dart:convert';

import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';

class Calendar extends StatefulWidget {
final String dataTitle;
final landlordUserId;
final tenantUserId;
final int property;
  const Calendar({
    Key key,
    this.property,
    this.landlordUserId,
    this.tenantUserId,
    this.dataTitle,
  }) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat format  = CalendarFormat.month;
  DateTime selectedDay =  DateTime.now();
  DateTime focusedDay =  DateTime.now();
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  String  selectedTime;
  String selectedDate;
  int tenantData;
  int propertyId;
  String title;

  var userData;
  var userId;
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }
  @override
  void initState() {
    _getUserInfo();

    super.initState();

  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = jsonDecode(userJson);
    setState(() {
      var userData = user;

      userId = userData['id'];

      landlord(userId);
    });
  }
  void landlord(tenant) async{
    var res = await CallApi().getData('tenant/$tenant');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    var dataTenant = myMap['data']['id'];

    setState(() {
      tenantData = dataTenant;

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text( MyApp.title),
      ),
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Center(
            child: Text('SET A SCHEDULE TO VISIT PROPERTY',style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            )),
          ),
          SizedBox(height: 20.0),
          TableCalendar(
            focusedDay:DateTime.now() ,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,
            onDaySelected: (DateTime selectDay, DateTime focusDay){
              setState(() {

                selectedDay = selectDay;
                focusedDay = focusDay;
                selectedDate =  DateFormat('yyyy-MM-dd').format(selectedDay);
              });

            },
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange[800],
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),

            ),
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            headerStyle: HeaderStyle(formatButtonVisible: false,titleCentered: true),
          ),
          SizedBox(height: 20.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        showPicker(
                          context: context,
                          value: _time,
                          onChange: onTimeChanged,
                          sunAsset: Image(
                            image: AssetImage('assets/sunshine.png'),
                          ),
                          onChangeDateTime: (DateTime dateTime) {
                            selectedTime =  DateFormat.Hms().format(dateTime);
                          },


                        ),

                      );

                },
                    child: Text('Select time to visit',)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left:16.0),
            child: ElevatedButton(
              onPressed: scheduleVisit,
                child: Text('Submit Schedule'),
            ),
          ),
        ],
      ),
    );
  }
  void scheduleVisit() async{
    String resultDate;
    if(selectedDate != null && selectedTime != null && widget.property != null
       && tenantData != null && widget.dataTitle != null ){
      resultDate = selectedDate + ' ' + selectedTime;

      var data = {
        'tenant_id':tenantData,
        'date':resultDate,
        'title':widget.dataTitle,
        'property_id':widget.property,

      };
      var res = await CallApi().postData(data, 'createInquiry');

      var body = jsonDecode(res.body);

      if (body['success']) {


        _showMsg(body['message']);
        sendNotifications();
        setState(() {
          Navigator.pop(context);

        });
      } else {
        _showMsg(body['message']);
      }

    }



  }
  void sendNotifications() async{
    var message = "you have a new inquiry in this Property Name:${widget.dataTitle}";

    var data = {
      'user_id':widget.tenantUserId,
      'message_notification':message,
      'to':widget.landlordUserId,
    };
    var res = await CallApi().postData(data,'createNotification');
    var items = jsonDecode(res.body);


  }
}

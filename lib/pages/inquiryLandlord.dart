import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';

class InquiryLandlord extends StatefulWidget {
  final int property;
  final int landlord;
  final String propertyName;
  const InquiryLandlord({
    Key key,
    this.property,
    this.landlord,
    this.propertyName
  }) : super(key: key);

  @override
  _InquiryLandlordState createState() => _InquiryLandlordState();
}

class _InquiryLandlordState extends State<InquiryLandlord> {
  int landlordId;
  int propertyId;
  String propertyName;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  List listOfInquiry = <DataRow>[];
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    if(widget.landlord != null && widget.property != null && widget.propertyName != null){
      landlordId = widget.landlord;
      propertyId = widget.property;
      propertyName = widget.propertyName;
    }


    getAllInquiry();
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
  Future<void> getAllInquiry() async{

    var res = await CallApi().getData('listAllInquiryTenants/property=$propertyId&landlord=$landlordId');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfInquiry = myMap['data'];
    print(listOfInquiry);

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
      body:
      RefreshIndicator(
        onRefresh: (){
          return getAllInquiry();
        },
        child: loading != false ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width
            ),
             child:
             SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child:  DataTable(
                   columnSpacing: 5,
                   horizontalMargin: 30.0,
                   headingRowColor: MaterialStateColor.resolveWith((states) {return Colors.blueAccent;}),
                   headingTextStyle: TextStyle(color: Colors.white),
                   dividerThickness: 1.0,
                   showBottomBorder: true,
                   columns:
                   <DataColumn>[
                    DataColumn(
                        label: Text('Name',textAlign: TextAlign.center,),
                        numeric: false,
                        onSort: (i,b)
                      {

                      },
                        tooltip: 'Full Name',
                    ),
                    DataColumn(
                      label: Text('Email',textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Email',
                    ),
                    DataColumn(
                      label: Text('Contact' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Contact No.',
                    ),
                    DataColumn(
                      label: Text('Schedule Visit',textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Schedule Visit',
                    ),
                    DataColumn(
                      label: Text('Action' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },

                    ),

                  ],
                 rows: listOfInquiry?.map((item) {
                   return new DataRow(
                       cells:[
                         DataCell(Text(item['name']!= null ? item['name'] : '',textAlign: TextAlign.center,)),
                         DataCell(Text(item['email']!= null ? item['email'] : '',textAlign: TextAlign.center,)),
                         DataCell(Text(item['contact']!= null ? item['contact'] : '',textAlign: TextAlign.center,)),
                         DataCell(Text(item['start']!= null ? item['start'] : '',textAlign: TextAlign.center,)),
                         DataCell(ElevatedButton(
                           child: Text('Accept',textAlign: TextAlign.center,),
                           onPressed: (){
                             updateSchedule(item['id'],item['users']);
                           },
                         )),

                       ]
                   );
                 })?.toList())

             ),





             ),
          ) :  Center(
            child:
            isLoading != false ? SpinKitDoubleBounce(
              size: 80.0,
              color: Colors.deepOrange[800],
            ) :Text('')),
      ),

    );
  }
  void updateSchedule(property,tenant) async{

    var res = await CallApi().updateSingleData( 'updateInquiry/$property');

    var body = jsonDecode(res.body);

    if (body['success']) {



      _showMsg(body['message']);
      sendNotifications(tenant);


      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => this.widget));

      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Accept Inquiry Schedule ')),
      );
    }
  }

  void sendNotifications(tenant ) async{
    var message = "Your inquiry  in this Property Name: $propertyName was Accepted ";

    var data = {
      'user_id':landlordId,
      'message_notification':message,
      'to':tenant,
    };
    var res = await CallApi().postData(data,'createNotification');
    var items = jsonDecode(res.body);
    print(items);

  }
}

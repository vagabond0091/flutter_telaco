import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';
class OverviewScreening extends StatefulWidget {
 final int property;
 final int landlord;
 final String landlordName;
  const OverviewScreening(
      {
        Key key,
        this.property,
        this.landlord,
        this.landlordName,
      }) : super(key: key);

  @override
  _OverviewScreeningState createState() => _OverviewScreeningState();
}

class _OverviewScreeningState extends State<OverviewScreening> {
List listOfScreening = [];
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

  getAllScreening();
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
  Future<void> getAllScreening() async{

    var res = await CallApi().getData('screeningTenants/property=${widget.property}&landlord=${widget.landlord}');
    var items = jsonDecode(res.body);
    // print(items);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfScreening = myMap['data'];

      print(listOfScreening);
    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body:
      RefreshIndicator(
        onRefresh: (){
          return getAllScreening();
        },
        child: loading != false ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,

            child:
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  columnSpacing: 12,

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
                      label: Text('Mark Tenant',textAlign: TextAlign.center),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Schedule Visit',
                    ),

                    DataColumn(
                      label: Text('Removed' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },

                    ),
                  ],
                  rows: listOfScreening?.map((item) {
                    return
                      new DataRow(
                        cells:[
                          DataCell(Text(item['name']!= null ? item['name'] : '',textAlign: TextAlign.center,)),
                          DataCell(Text(item['email']!= null ? item['email'] : '',textAlign: TextAlign.center,)),
                          DataCell(Text(item['contact']!= null ? item['contact'] : '',textAlign: TextAlign.center,)),
                          // DataCell(Text(item['start']!= null ? item['start'] : '',textAlign: TextAlign.center,)),
                          DataCell(ElevatedButton(
                            child: Text('Accept',textAlign: TextAlign.center,),
                            onPressed: (){
                              // print(item['id']);
                              markAsTenant(item['property_id'],item['tenant_id'],item['users'],item['title']);

                            },
                          )),
                          DataCell(ElevatedButton(
                            child: Text('Remove',textAlign: TextAlign.center,),
                            onPressed: (){
                              deleteScreening(item['id']);

                            },
                          ),

                          ),


                        ]
                    );
                  })?.toList()) ,
            ),






        ) : Center(
            child:
            isLoading != false ? SpinKitDoubleBounce(
              size: 80.0,
              color: Colors.deepOrange[800],
            ) :Text('')),
      ),
    );
  }
  void markAsTenant(property,tenant,propertyName,tenantUser) async{

  var data = {
    'tenant_id':tenant,

  };

    var res = await CallApi().updateData(data,'tenantUpdate/$property}');
    var items = jsonDecode(res.body);

  if (items['success']) {

    sendNotifications(tenantUser,propertyName,);

    _showMsg(items['message']);



    setState(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => this.widget));

    });
  }
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to mark as tenant')),
    );
  }
}
void sendNotifications(propertyName,tenant,  ) async{
  var message = "Your are accepted as a tenant in this Property Name: $propertyName by ${widget.landlordName}";

  var data = {
  'user_id':widget.landlord,
  'message_notification':message,
    'to':tenant,
  };
  var res = await CallApi().postData(data,'createNotification');
  var items = jsonDecode(res.body);

}
  void deleteScreening(id) async{

    var res = await CallApi().updateSingleData('removedInquiry/$id}');
    var items = jsonDecode(res.body);

    if (items['success']) {



      _showMsg(items['message']);



      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => this.widget));

      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Removed Screening Data ')),
      );
    }
  }
}

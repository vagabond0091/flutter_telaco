import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';
class LandlordMaintenance extends StatefulWidget {
  final int landlord;
  const LandlordMaintenance(
      {Key key,this.landlord}
      ) : super(key: key);

  @override
  _LandlordMaintenanceState createState() => _LandlordMaintenanceState();
}

class _LandlordMaintenanceState extends State<LandlordMaintenance> {
  List listOfMaintenance = <DataRow>[];
  bool _isVisible = true;
  String results;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  String inProgress = 'In-Progress';
  String resolved = 'Resolved';
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  void initState() {

    getAllMaintenance();
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
  Future<void> getAllMaintenance() async{
    var res = await CallApi().getData('getAllMaintenance/landlord=${widget.landlord}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfMaintenance = myMap['data'];
      print(listOfMaintenance);

    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
      ),

     body: RefreshIndicator(
        onRefresh: (){
          return getAllMaintenance();
        },
        child: loading != false ?  SingleChildScrollView(
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
                  horizontalMargin: 10.0,
                  headingRowColor: MaterialStateColor.resolveWith((states) {return Colors.blueAccent;}),
                  headingTextStyle: TextStyle(color: Colors.white),
                  dividerThickness: 1.0,
                  showBottomBorder: true,
                  columns:
                  <DataColumn>[
                    DataColumn(
                      label: Text('Ticket #',textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Ticket #',
                    ),
                    DataColumn(
                      label: Text('Tenant Name',textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Full Name',
                    ),
                    DataColumn(
                      label: Text('Property Name' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Property Name',
                    ),
                    DataColumn(
                      label: Text('Maintenance Type',textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Maintenance Type',
                    ),
                    DataColumn(
                      label: Text('Scenario' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },

                    ),DataColumn(
                    label: Text('Maintenance Status' ,textAlign: TextAlign.center,),
                    numeric: false,
                    onSort: (i,b)
                    {

                    },

                  ),

                    // DataColumn(
                    //   label: Text('' ),
                    //   numeric: false,
                    //
                    //
                    // ),

                    DataColumn(
                      label: Text('Action' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },

                    ),
                  ],
                  rows:
                  listOfMaintenance?.map((item) {
                    return new DataRow(
                        cells:[
                          DataCell(Text(item['id']!= null ? item['id'].toString().padLeft(6, '0') : '',textAlign: TextAlign.center,)),
                          DataCell(Text(item['name']!= null ? item['name'] : '',textAlign: TextAlign.center,)),
                          DataCell(Text(item['title']!= null ? item['title'] : '',textAlign: TextAlign.center,)),
                          DataCell(Text(item['maintenance_type']!= null ? item['maintenance_type'] : '',textAlign: TextAlign.center,)),
                          DataCell(
                              Padding(
                                padding: const EdgeInsets.only(left:8.0,right: 8.0),
                                child: Text(item['scenario']!= null ? item['scenario'] : '',textAlign: TextAlign.center,),
                              )),
                          DataCell(Padding(
                            padding: const EdgeInsets.only(left:8.0,right: 8.0),
                            child: Text(item['maintenance_status']!= null ? item['maintenance_status'] : '',textAlign: TextAlign.center,),
                          )),


                          DataCell(
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Visibility(
                                  visible: item['maintenance_status'] == 'New' ? _isVisible : false ,
                                  child: ElevatedButton(
                                    style:ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.green)),
                                    onPressed: (){
                                      updateMaintenance(item['id'],inProgress,item['users']);
                                    },
                                    child: Text('In-Progress'),
                                  ),
                                  replacement:  Visibility(
                                    visible: item['maintenance_status'] == 'In-Progress' ? _isVisible : false ,
                                    child: SizedBox(
                                      width: 106.0,
                                      child: ElevatedButton(
                                        style:ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.green)),
                                        onPressed: (){
                                          updateMaintenance(item['id'],resolved,item['users']);
                                        },
                                        child: Text('Resolved'),
                                      ),
                                    ),
                                    replacement: Center(child: Text('N/A')),
                                  ),
                                ),
                              )
                          ),
                          // DataCell(
                          //     Padding(
                          //
                          //       padding: const EdgeInsets.only(left:8.0),
                          //       child: ElevatedButton(
                          //         style:ButtonStyle(
                          //             backgroundColor: MaterialStateProperty.all(Colors.red)),
                          //         onPressed: (){
                          //           deleteMaintenance(item['id']);
                          //         },
                          //
                          //         child: Row(
                          //           children: [
                          //             Icon(Icons.delete),
                          //             Padding(
                          //               padding: const EdgeInsets.only(left:8.0),
                          //               child: Text('delete'),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     )
                          // ),



                        ]
                    );
                  })?.toList())
            ),





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
  void updateMaintenance(id,status,users) async{
    var data = {
      'maintenance_status':status,
    };
    var res = await CallApi().updateData(data,'maintenanceUpdate/$id}');
    var items = jsonDecode(res.body);
    print(items['success']);
    if (items['success']) {



      _showMsg(items['message']);
      sendNotifications(status,users);


      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => this.widget));

      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Update Maintenance Request ')),
      );
    }
  }
  void sendNotifications(status,tenant,  ) async{
    var message = "Your Maintenance request was $status";

    var data = {
      'user_id':widget.landlord,
      'message_notification':message,
      'to':tenant,
    };
    var res = await CallApi().postData(data,'createNotification');
    var items = jsonDecode(res.body);
    print(items);

  }
  //delete maintenance code here
  // void deleteMaintenance(id) async{
  //   var res = await CallApi().deleteData('maintenanceDelete/$id}');
  //   var items = jsonDecode(res.body);
  // print(items);
  //   if (items['success']) {
  //     _showMsg(items['message']);
  //     setState(() {
  //       Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (BuildContext context) => this.widget));
  //
  //     });
  //   }
  //   else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Unable to  Removed Maintenance Request ')),
  //     );
  //   }
  // }
}

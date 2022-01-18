import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';
class ListOfTenant extends StatefulWidget {
  final int landlord;
  const ListOfTenant(
      {
        Key key,
        this.landlord
      }
  ) : super(key: key);

  @override
  _ListOfTenantState createState() => _ListOfTenantState();
}

class _ListOfTenantState extends State<ListOfTenant> {
  List dataTenants = [];
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


    startLoading();
    super.initState();
    getAllTenant();

  }
  void startLoading() async{
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      setState(() {
        isLoading = false;

      });
    });
  }
  Future<void> getAllTenant() async{
    var res = await CallApi().getData('getCurrentTenant/landlord=${widget.landlord}');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      dataTenants = myMap['data'];

      print(dataTenants);
    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body:  RefreshIndicator(
        onRefresh: (){
          return getAllTenant();
        },
        child:
        loading != false ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width
            ),
            child:
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:   DataTable(

                  columnSpacing: 12,
                  horizontalMargin: 2.0,
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
                      label: Text('Current Tenant',textAlign: TextAlign.center),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },
                      tooltip: 'Schedule Visit',
                    ),

                    DataColumn(
                      label: Text('Property Name' ,textAlign: TextAlign.center,),
                      numeric: false,
                      onSort: (i,b)
                      {

                      },

                    ),
                  ],
                  rows: dataTenants?.map((item) {
                    return
                      new DataRow(
                          cells:[
                            DataCell(Text(item['name']!= null ? item['name'] : '',textAlign: TextAlign.center,)),
                            DataCell(Text(item['email']!= null ? item['email'] : '',textAlign: TextAlign.center,)),
                            DataCell(Text(item['contact']!= null ? item['contact'] : '',textAlign: TextAlign.center,)),

                            DataCell( Text('Yes',textAlign: TextAlign.center,)),
                            DataCell(Text(item['title']!= null ? item['title'] : '',textAlign: TextAlign.center,)),
                            // DataCell(Text(item['start']!= null ? item['start'] : '',textAlign: TextAlign.center,)),




                          ]
                      );
                  })?.toList()) ,
            ),





          ),
        )  : Center(
      child:
      isLoading != false ? SpinKitDoubleBounce(
        size: 80.0,
        color: Colors.deepOrange[800],
      ) :Text('')),
      ),
    );
  }
}

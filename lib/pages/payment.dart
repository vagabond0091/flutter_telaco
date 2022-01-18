import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/paymentCreate.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class Payment extends StatefulWidget {
  final int landlord;
  const Payment({
    Key key,
    this.landlord
  }) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}


class _PaymentState extends State<Payment> {
  List listOfProperty = [];
  List listOfTenant = [];
  List allPayments = [];
  int selectedProperty;
  TextEditingController _paid = TextEditingController();
  String paidDate;
  int tenant;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  String tenantName;
  @override
  void initState() {
    getAllPropertyByLandlord();
    getAllPayment();
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
  void getAllPropertyByLandlord() async{
    var res = await CallApi().getData('getAllPropertyPayment/${widget.landlord}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfProperty = myMap['data'];

    });

  }
  void getAllPayment() async{
    var res = await CallApi().getData('getAllPayment/${widget.landlord}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      allPayments = myMap['payment'];
      print(allPayments);
    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: payment(),
        floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.add),
            label: Text('Add Payment'),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () {
              Navigator.pop(this.context);
              var route  = new MaterialPageRoute(builder: (BuildContext context) =>
              new PaymentCreate(landlord: widget.landlord),
              );
              Navigator.of(context).push(route);
            }),
    );
  }
  Widget payment(){
    return
      loading != false ?  SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:  ConstrainedBox(
        constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width
        ),
        child:
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:  DataTable(

              columnSpacing: 2,
              horizontalMargin: 2.0,
              headingRowColor: MaterialStateColor.resolveWith((states) {return Colors.blueAccent;}),
              headingTextStyle: TextStyle(color: Colors.white),
              dividerThickness: 1.0,
              showBottomBorder: true,
              columns:
              <DataColumn>[
                DataColumn(
                  label: Text('Property Name',textAlign: TextAlign.center,),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },
                  tooltip: 'Property Name',
                ),
                DataColumn(
                  label: Text('Current Tenant',textAlign: TextAlign.center,),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },
                  tooltip: 'Current Tenant',
                ),
                DataColumn(
                  label: Text('Due Date' ,textAlign: TextAlign.center,),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },
                  tooltip: 'Due Date',
                ),
                DataColumn(
                  label: Text('Paid Date',textAlign: TextAlign.center),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },
                  tooltip: 'Paid Date',
                ),

                DataColumn(
                  label: Text('Payment Status' ,textAlign: TextAlign.center,),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },

                ),
                DataColumn(
                  label: Text('Action' ,textAlign: TextAlign.center,),
                  numeric: false,
                  onSort: (i,b)
                  {

                  },

                ),
              ],
              rows: allPayments?.map((item) {
                return
                  new DataRow(
                      cells:[
                        DataCell(Text(item['title']!= null ? item['title'] : '',textAlign: TextAlign.center,)),
                        DataCell(Text(item['tenant_name']!= null ? item['tenant_name'] : '',textAlign: TextAlign.center,)),
                        DataCell(Text(item['due_date']!= null ? item['due_date'] : '',textAlign: TextAlign.center,)),
                        DataCell(Text(item['paid_date']!= null ? item['paid_date'] : 'N/A',textAlign: TextAlign.center,)),

                        DataCell(Text(item['payment_status']!= null ? item['payment_status'] : '',textAlign: TextAlign.center,)),
                        // DataCell(Text(item['start']!= null ? item['start'] : '',textAlign: TextAlign.center,)),
                        DataCell(
                          Visibility(
                            visible: (item['payment_status'] != 'paid'  && item['payment_status'] != 'Paid')   ? true:false ,

                            child: ElevatedButton(
                              onPressed: (){
                                showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {

                                    return StatefulBuilder(builder: (BuildContext context,StateSetter setState){
                                      return AlertDialog(
                                        title: const Text('Update Payment Log Book'),
                                          content: SizedBox(
                                            height: 230.0,
                                            width: 300.0,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text('Date Paid:'),
                                                    SizedBox(width: 15.0),
                                                    SizedBox(
                                                      width: 180.0,
                                                      child: TextFormField(

                                                          controller: _paid,
                                                          decoration: InputDecoration(labelText: 'Date of Payment'),
                                                          validator: (String value) {
                                                            if (value.isEmpty) {
                                                              return "Please enter paid date";
                                                            }

                                                            return null;
                                                          },
                                                          onTap: () async{
                                                            String data;
                                                            DateTime date = DateTime(1900);
                                                            FocusScope.of(context).requestFocus(new FocusNode());

                                                            date = await showDatePicker(
                                                                context: context,
                                                                initialDate:DateTime.now(),
                                                                firstDate:DateTime(1900),
                                                                lastDate: DateTime(2100));





                                                            data =date.toIso8601String() ;
                                                            _paid.text =DateFormat('yyyy-MM-dd').format(DateTime.parse(data));
                                                            paidDate = _paid.text;
                                                          }
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Row(
                                                    children: [
                                                      Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              updatePayment(item['id'],item['tenant_id']);
                                                            },
                                                            child: Text('Saved'),
                                                          ),

                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: (){
                                                            Navigator.pop(this.context);
                                                          },
                                                          child: Text('Cancel'),
                                                        ),

                                                      ),
                                                    ],
                                                )
                                              ],
                                            )
                                          )
                                      );
                                  });
                                });
                              },
                              child:Text('Update')
                            ),
                            replacement: Text('N/A'),
                          ),


                        ),



                      ]
                  );
              })?.toList())
        ),





      ),
    ) :  Container(
    child:
    isLoading != false ? SpinKitDoubleBounce(
    size: 80.0,
    color: Colors.deepOrange[800],
    ) :Text(''));
  }

  void updatePayment(id,tenant) async{

    var response = await CallApi().getData('tenantPayment/$tenant');
    var body = jsonDecode(response.body);
    var data = {
      'paid_date': paidDate,
      'payment_status':'paid',

    };
    var res = await CallApi().updateData(data,'updatePayment/$id');
    var items = jsonDecode(res.body);
    if(items['success']){
      allPayments.clear();
      sendNotifications(paidDate,body['data']['user']['id']);
      var res = await CallApi().getData('getAllPayment/${widget.landlord}');
      var items = jsonDecode(res.body);

      Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
      setState(() {
        allPayments = myMap['payment'];

      });
      Navigator.pop(this.context);

    }
  }

  void sendNotifications(paid,tenant,  ) async{
    var message = "You paid your rent for this month of  $paid";

    var data = {
      'user_id':widget.landlord,
      'message_notification':message,
      'to':tenant,
    };
    var res = await CallApi().postData(data,'createNotification');
    var items = jsonDecode(res.body);
    if(items['success']){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification send')),
      );
    }

  }
  //sub property type

}

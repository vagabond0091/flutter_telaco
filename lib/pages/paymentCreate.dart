import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/payment.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class PaymentCreate extends StatefulWidget {
  final int landlord;
  const PaymentCreate({
    Key key,
    this.landlord
  }) : super(key: key);

  @override
  _PaymentCreateState createState() => _PaymentCreateState();
}

class _PaymentCreateState extends State<PaymentCreate> {
  List listOfProperty = [];
  List listOfTenant = [];
  List payments = ['paid','not paid'];
  int selectedProperty;

  int tenant;
  String tenantName;
  String selectedPayment;
  String paidDate;
  String notpaidDate;
  String notificationPaymentDate;
  bool initialStateDate = true;
  bool paid = false;
  TextEditingController _paid = TextEditingController();
  TextEditingController _notpaid = TextEditingController();
  @override
  void initState() {
    getAllPropertyByLandlord();
    super.initState();

  }
  void getAllPropertyByLandlord() async{
    var res = await CallApi().getData('getAllPropertyPayment/${widget.landlord}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfProperty = myMap['data'];
      print(listOfProperty);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Create Payment',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0)),
                SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Property:'),
                    DropdownButton(
                        hint: Text('Please choose a Property'),
                        value: selectedProperty,
                        onChanged: (newValue) {
                          setState(() {
                            tenant = null;
                            selectedProperty = newValue;
                            _getTenant(selectedProperty);
                          });
                        },
                        items: listOfProperty?.map((item) {
                          return new DropdownMenuItem(
                            child: new Text(item['title']),
                            value: item['id'],
                          );
                        })?.toList()) ?? [],


                  ],
                ),

                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text('Tenant Name:'),
                      SizedBox(height: 10.0),

                      DropdownButton(
                          hint: Text('Please select tenant'),
                          value: tenant,
                          onChanged: (newValue) {
                            setState(() {
                              tenant = newValue;

                            });
                          },
                          items: listOfTenant.map((item) {
                            tenantName = item['name'];
                            print(tenantName);
                            return DropdownMenuItem(

                              child: new Text(item['name']),
                              value: item['id'],
                            );
                          }).toList()),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text('Payment Status:'),
                      SizedBox(height: 10.0),

                      DropdownButton(
                          hint: Text('Please Select Payment Status'),
                          value: selectedPayment,
                          onChanged: (newValue) {
                            setState(() {
                              selectedPayment = newValue;
                              print(initialStateDate);
                              if(selectedPayment == 'paid'){
                                initialStateDate = false;
                                paid = true;
                              }
                              else{
                                paid = false;
                                initialStateDate = false;
                              }
                            });
                          },
                          items: payments.map((item) {
                            return DropdownMenuItem(

                              child: new Text(item),
                              value: item,
                            );
                          }).toList()),
                    ]
                ),
                Center(
                  child: Container(

                    child: initialStateDate == true ? Text('') :  Container(

                      child:  paid == true ? Padding(
                        padding: const EdgeInsets.only(left:8.0),
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Paid:'),
                            SizedBox(
                              width: 300,
                              height: 50,
                              child:
                              TextFormField(

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
                        ) ,
                      ) : Padding(
                        padding:  const EdgeInsets.only(left:8.0),
                        child:
                        Row(
                          children: [
                            Text('Not Paid:'),
                            SizedBox(
                              width: 300,
                              height: 50,
                              child:
                              TextFormField(

                                  controller: _notpaid,
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
                                    _notpaid.text =DateFormat('yyyy-MM-dd').format(DateTime.parse(data));
                                    notpaidDate = _notpaid.text;
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left:12.0,right: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            onPressed: (){
                              createPayment();
                            },
                            child: Text('Create Payment'),
                          )
                      ),
                      SizedBox(width: 30.0),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: (){
                              Navigator.pop(this.context);
                            },
                            child: Text('Cancel'),
                          )
                      ),
                    ],
                  ),
                )

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Visibility(
                //       visible: initialStateDate,
                //         child: Text('test'),
                //         replacement: Visibility(
                //           visible: paid,
                //           child: Row(
                //
                //             children: [
                //               Text('Paid'),
                //               Padding(
                //                 padding: const EdgeInsets.only(left:8.0),
                //                 child:
                //                 SizedBox(
                //                   width: 200,
                //                   height: 50,
                //                   child:
                //                   TextFormField(
                //
                //                       controller: _paid,
                //                       decoration: InputDecoration(labelText: 'Date of Payment'),
                //                       validator: (String value) {
                //                         if (value.isEmpty) {
                //                           return "Please enter paid date";
                //                         }
                //
                //                         return null;
                //                       },
                //                       onTap: () async{
                //                         String data;
                //                         DateTime date = DateTime(1900);
                //                         FocusScope.of(context).requestFocus(new FocusNode());
                //
                //                         date = await showDatePicker(
                //                             context: context,
                //                             initialDate:DateTime.now(),
                //                             firstDate:DateTime(1900),
                //                             lastDate: DateTime(2100));
                //
                //
                //
                //
                //
                //                         data =date.toIso8601String() ;
                //                         _paid.text =DateFormat('yyyy-MM-dd').format(DateTime.parse(data));
                //
                //                       }
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           replacement: Text('Not Paid'),
                //         ),
                //     )
                //   ],
                // )
              ],
            )

          ],
        )

    );
  }
  void _getTenant(property) async {
    print(property);
    // print(url);
    if (selectedProperty == null) {
      return;
    }
    else {
      print(widget.landlord);
      var res = await CallApi().getData(
          'getPaymentPerTenantMobile/${widget.landlord}/$property');

      //     property = null;
      var body = jsonDecode(res.body);
      print(body);
      Map<String, dynamic> jsonMap = Map<String, dynamic>.from(body);
      // print(jsonMap['data']);
      setState(() {
        listOfTenant = jsonMap['tenant'];
        // tenantName = listOfTenant[0]['name'];
        print(listOfTenant);
        // _tenant.text = tenantName;

      });
    }

  }

  void createPayment () async{

    if(paidDate != null){
      notificationPaymentDate = "You paid your rent for this month of $paidDate";
    }
    else{
      notificationPaymentDate = "Your due date for your rent is $notpaidDate";
    }
    var data = {
      'property_id': selectedProperty,
      'tenant_name': tenantName,
      'payment_status':selectedPayment,
      'due_date':notpaidDate,
      'paid_date':paidDate
    };
    var res = await CallApi().postData(data,
        'createPayment');

    //     property = null;
    var body = jsonDecode(res.body);
    if(body['success']){
      sendNotifications(notificationPaymentDate,tenant);
    }

}
  void sendNotifications(paid,tenant,  ) async{
    var message = paid;

    var data = {
      'user_id':widget.landlord,
      'message_notification':message,
      'to':tenant,
    };
    var res = await CallApi().postData(data,'createNotification');
    var items = jsonDecode(res.body);
    print(items);
    if(items['success']){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification send')),


      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Payment(landlord: widget.landlord,)));
    }

  }

}

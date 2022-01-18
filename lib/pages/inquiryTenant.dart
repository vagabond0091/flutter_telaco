import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';

class InquiryTenant extends StatefulWidget {
  final  int user;
  const InquiryTenant(
      {
        Key key,
        this.user,
      }
      ) : super(key: key);

  @override
  _InquiryTenantState createState() => _InquiryTenantState();
}

class _InquiryTenantState extends State<InquiryTenant> {
  int tenantData;
  List listOfProperty = [];
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  final formatCurrency = new NumberFormat.currency(locale: "en_US",symbol: "₱");
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  @override
  void initState() {
    landlord();
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
  void landlord() async{
    var res = await CallApi().getData('tenant/${widget.user}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    var dataTenant = myMap['data']['id'];
      print(dataTenant);
    setState(() {
      tenantData = dataTenant;
      getInquiries(tenantData);
    });
  }
  void getInquiries(tenant) async{
    var res = await CallApi().getData('getAllInquiriesPerTenant/tenant=$tenant');
    var items = jsonDecode(res.body);


    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfProperty = myMap['data'];
      print(listOfProperty.length);
      print(listOfProperty);
    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body:getGrid(),
    );
  }
  Widget getGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: loading != false ? Container(

              child: StaggeredGridView.countBuilder(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 1,
                  itemCount: listOfProperty.length,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemBuilder: (context, index) {
                    return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Card(
                              margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                              child: Column(children: <Widget>[


                                FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: "${listOfProperty[index]['showroom_img']}",
                                    height: 250,
                                    //
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                    children: <Widget>[

                                      Row(

                                        children: [
                                          Icon(Icons.home,size: 20.0,color: Colors.deepOrange[600]),
                                          Padding(
                                            padding: EdgeInsets.only(left: 16.0),
                                            child:    Text('${listOfProperty[index]['title']}'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(CupertinoIcons.tag_solid,size: 18.0,color: Colors.deepOrange[600]),
                                          Padding(
                                            padding: EdgeInsets.only(left: 16.0),
                                            child:   Text('${formatCurrency.format(listOfProperty[index]['price'])}',
                                            ),

                                          )
                                        ],
                                      )
                                     ],
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                        Icon(CupertinoIcons.location,size: 18.0,color: Colors.deepOrange[600]),

                                          Padding(
                                            padding: const EdgeInsets.only(left:16.0),
                                            child: Text('${listOfProperty[index]['address']+ ' Brgy.'+listOfProperty[index]['barangay']+' City '+listOfProperty[index]['city']}',
                                              ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                      children: [

                                        Padding(
                                          padding: const EdgeInsets.only(left:16.0),
                                          child: Container(
                                            padding:  EdgeInsets.all(9.0),
                                            child:
                                            Text('Status: ${listOfProperty[index]['isAccepted']} ',style: TextStyle(
                                              color:Colors.white,
                                            ),),
                                            decoration: BoxDecoration(
                                                color:Colors.green[800] ,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left:16.0),
                                          child: ElevatedButton(onPressed: (){
                                            deleteInquiry(listOfProperty[index]['id']);
                                          },child:Row(
                                            children: [
                                              Icon(Icons.delete),
                                              SizedBox(width: 10.0),
                                              Text('Delete Inquiry'),
                                            ],
                                          )),
                                        ),

                                      ]
                                    )
                                  ],
                                ),
                                SizedBox(height: 20.0),



                              ]),
                            ),
                          ],
                        ));
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
            ) :  Center(
                child:
                isLoading != false ? SpinKitDoubleBounce(
                  size: 80.0,
                  color: Colors.deepOrange[800],
                ) :Text(''))),

      ],
    );
  }
  void deleteInquiry(id) async{
    var res = await CallApi().deleteData('deleteInquiry/$id}');
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

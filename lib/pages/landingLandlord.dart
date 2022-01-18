import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/api/googleSignInApi.dart';
import 'package:flutter_telaco/pages/home.dart';
import 'package:flutter_telaco/pages/listOfTenant.dart';
import 'package:flutter_telaco/pages/payment.dart';
import 'package:flutter_telaco/pages/profile.dart';
import 'package:flutter_telaco/pages/property.dart';
import 'package:flutter_telaco/pages/screening.dart';
import 'package:flutter_telaco/pages/updateProperty.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';
import 'inquiryLandlord.dart';
import 'maintenanceLandlord.dart';
import 'message.dart';
import 'notification.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  var userData;
  var userId;
  var landlord;
  String landlordName;
  String providerId;
  var role;
  List listOfProperty = [];
  Timer  timer;
  int notifCount;
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

    super.initState();
    _getUserInfo();
    startLoading();
  }
  void startLoading() async{
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      setState(() {
        isLoading = false;

      });
    });
  }
  Future<void> _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = jsonDecode(userJson);
    setState(() {
      userData = user;
      providerId = userData['provider_id'];
      role = userData['user_type'];
      if(userData['id'] != null){
        userId = userData['id'];
        getAllNotifications(userId);
      }




    });
    var response = await CallApi().getData('getLandlord/${userData['id']}');
    var bodyData = jsonDecode(response.body);

    Map<String, dynamic> dataMapping = Map<String, dynamic>.from(bodyData);

    setState(() {
      landlord = dataMapping['data']['id'];
      landlordName = userData['name'];
      print(landlordName);
      getAllLandlordProperties();
      });
  }
  void getAllNotifications(id) async{
    var res = await CallApi().getData('getAllNotificationPerTenant/$id');
    var items = jsonDecode(res.body);
    setState(() {
      notifCount = items['notif_count'];
    });

  }
  Future getAllLandlordProperties() async {

    var res = await CallApi().getData('getAllPropertyLandlord/$landlord');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);

    setState(() {
      listOfProperty = myMap['data'];


    });
    loading = true;
  }
  void _handleDeleteData(int propertyID) async{
    var res = await CallApi().deleteData('deleteProperties/$propertyID');
    var body = jsonDecode(res.body);
    if(body['success']){
      getAllLandlordProperties();
      _showMsg(body['message']);
    }
    else{
      _showMsg('unable to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 150,
                child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[600],
                    ),
                    child: Center(
                      child: Text(
                        userData != null ? 'Welcome ! ${userData['name']}' : '',
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      ),
                    )),
              ),
              ListTile(
                leading: Icon(Icons.house ,color: Colors.deepOrange[600]),
                title: const Text('Property ', ),
                onTap: () {

                },
              ),
              ListTile(
                leading: Icon(Icons.message ,color: Colors.deepOrange[600]),
                title:  Text('Message ', ),
                onTap: () {
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new Message(landlord: userId),
                  );
                  Navigator.of(context).push(route);
                  },


              ),
              ListTile(
                leading: Icon(Icons.notifications ,color: Colors.deepOrange[600]),
                title: const Text('Notification'),
                trailing: notifCount != 0 ? ClipOval(
                  child: Container(
                    width: 25,
                    height: 25,
                    color: Colors.redAccent,

                    child: Center(
                      child:  Text(
                        "$notifCount",
                        style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                      ) ,
                    ),
                  ),
                ) : Text(''),
                onTap: () {
                  setState(() {
                    notifCount = 0;
                  });
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new Notifications(userId: userId),
                  );
                  Navigator.of(context).push(route);
                },
              ),
              ListTile(
                leading: Icon(Icons.content_paste_outlined ,color: Colors.deepOrange[600]),
                title: const Text('Screening'),
                onTap: () {
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new Screening(landlord: landlord,landlordName:landlordName),
                  );
                  Navigator.of(context).push(route);
                },
              ),
              ListTile(
                leading: Icon(Icons.person ,color: Colors.deepOrange[600]),
                title: const Text('Current Tenants'),
                onTap: () {
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new ListOfTenant(landlord: landlord),
                  );
                  Navigator.of(context).push(route);
                },
              ),
              ListTile(
                leading: Icon(Icons.handyman ,color: Colors.deepOrange[600]),
                title: const Text('Maintenance Request'),
                onTap: () {
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new LandlordMaintenance(landlord: landlord),
                  );
                  Navigator.of(context).push(route);
                },
              ),
              ListTile(
                leading: Icon(Icons.payment ,color: Colors.deepOrange[600]),
                title: const Text('Payment'),
                onTap: () {
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new Payment(landlord: landlord),
                  );
                  Navigator.of(context).push(route);
                },
              ),
              ListTile(
                  leading: Icon(Icons.person_outline_rounded ,color: Colors.deepOrange[600]),
                  title:  Text('Profile '),
                  onTap: (){
                    var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                    new Profile(userInfo: userId,role: role),
                    );
                    Navigator.of(context).push(route);
                  }),
              ListTile(
                  leading: Icon(Icons.exit_to_app ,color: Colors.deepOrange[600]),
                  title: const Text('Logout'),
                  onTap: logout),
            ],
          ),
        ),
        body: getGrid(),
        floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.add),
            label: Text('Add Property'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PropertyCreate()),
              );
            }));
  }
  Widget getGrid() {
    return RefreshIndicator(
      onRefresh:(){
        return getAllLandlordProperties();
      },

      child: Column(


        children: [
          Expanded(
              child: loading != false ?  Container(

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
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[

                                  Container(
                                    alignment: Alignment.topRight,
                                    padding: EdgeInsets.only(left:16.0),
                                    child: PopupMenuButton(
                                      child: Padding(
                                        padding: EdgeInsets.only(),

                                        child: Icon(Icons.more_vert,color: Colors.black),

                                      ),
                                      itemBuilder: (context)=>[
                                        PopupMenuItem(
                                            child: Text('Edit'),
                                          value:'edit',
                                        ),
                                        PopupMenuItem(
                                            child: Text('Delete'),
                                            value:'delete',
                                        )
                                      ],
                                      onSelected: (val){
                                        if(val == 'edit'){
                                             var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                             new UpdateProperty(title:listOfProperty[index]['title'],description: listOfProperty[index]['description'],landlord: landlord,
                                              bedrooms:listOfProperty[index]['other_information']['bedrooms'],baths:listOfProperty[index]['other_information']['baths'],
                                               floorarea:listOfProperty[index]['other_information']['floorarea'], lot_number:listOfProperty[index]['other_information']['lot_number'],
                                               subdivision:listOfProperty[index]['other_information']['subdivision'],  total_room:listOfProperty[index]['other_information']['total_room'],
                                               car_space:listOfProperty[index]['other_information']['car_space'],total_floor:listOfProperty[index]['other_information']['total_floor'],
                                                 price:listOfProperty[index]['price'],showroom_img:listOfProperty[index]['showroom_img'],propertyID:listOfProperty[index]['id']

                                             ),
                                                 // bedrooms:listOfProperty[index]['bedrooms']
                                             );
                                             Navigator.of(context).push(route);
                                        }
                                        else{
                                            _handleDeleteData(listOfProperty[index]['id'] ?? 0);
                                        }
                                      }

                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: "${listOfProperty[index]['showroom_img']}",
                                      height: 250,
                                      //
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth
                                  ),
                                  // propertyImage(listOfProperty[index]['showroom_img']),
                                 Padding(
                                   padding: const EdgeInsets.only(left:16.0),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       SizedBox(height: 10.0),
                                       Row(
                                         children: [
                                           Icon(Icons.home,color: Colors.deepOrange[600]),
                                           Padding(
                                             padding: const EdgeInsets.only(left:10.0),
                                             child: Text('${listOfProperty[index]['title']}'),
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
                                       ),
                                       SizedBox(height: 10.0),
                                       Row(
                                         children: [
                                           Icon(CupertinoIcons.location,size: 18.0,color: Colors.deepOrange[600]),

                                           Padding(

                                             padding: EdgeInsets.only(left: 16.0),
                                             child: Text('${listOfProperty[index]['address']+ ' Brgy.'+listOfProperty[index]['barangay']+' City '+listOfProperty[index]['city']}'),
                                           ),
                                         ],
                                       ),
                                        SizedBox(height: 10.0),
                                       Text(listOfProperty[index]['status'] == 1 ? 'Status: Rented':'Status: Vaccant'),
                                       SizedBox(height: 10.0),
                                       Padding(
                                         padding: const EdgeInsets.only(right:16.0),
                                         child: Row(
                                           children: [

                                             Expanded(
                                               child: ElevatedButton(onPressed: (){
                                                 var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                                 new InquiryLandlord(property:listOfProperty[index]['id'] ,landlord: landlord,propertyName:listOfProperty[index]['title']));
                                                 Navigator.of(context).push(route);
                                               },
                                                   child: Text('View Inquiries')),
                                             ),
                                             SizedBox(width: 10.0),
                                             Expanded(
                                               child: listOfProperty[index]['status'] == 1 ?  ElevatedButton(onPressed: (){
                                                 markAsAvailable(listOfProperty[index]['id'] );
                                               },
                                                   child: Text('Mark as Available')) : Text(''),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ],
                                   ),
                                 )

                                ]),
                              ),
                            ],
                          ));
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
              ) : Center(
                  child:
                  isLoading != false ? SpinKitDoubleBounce(
                    size: 80.0,
                    color: Colors.deepOrange[800],
                  ) :Text(''))),

        ],
      ),
    );
  }
  void logout() async {
    var res = await CallApi().getData('mobile/logout');
    var body = jsonDecode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      if(providerId != null){
        await GoogleSignInApi.logout();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()),
            (route) => false,
      );

      _showMsg(body['message']);
    }
  }
  void markAsAvailable(id) async{
    var res = await CallApi().updateSingleData('updatePropertyAvailability/$id');
    var body = jsonDecode(res.body);
    print(body);
    if (body['success']) {

      _showMsg(body['message']);
      var res = await CallApi().getData('getAllPropertyLandlord/$landlord');
      var items = jsonDecode(res.body);

      Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
      listOfProperty.clear();
      setState(() {
        listOfProperty = myMap['data'];


      });
    }

  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_telaco/api/api.dart';

import '../main.dart';
class MaintenanceRequest extends StatefulWidget {
  final int user;
  const MaintenanceRequest({
    Key key,
    this.user
  }) : super(key: key);

  @override
  _MaintenanceRequestState createState() => _MaintenanceRequestState();
}

class _MaintenanceRequestState extends State<MaintenanceRequest> {
TextEditingController _scenarioController = TextEditingController();
List<String> _userType =  [
  'smoke detector (price ₱600)', 'heater (price ₱900)',
  'dishwasher (price ₱2,251)','in-unit washer (price ₱8,957 - ₱11,868)',
  'dryer (price ₱8,957 - ₱11,868)','faucet (price ₱1,191)','toilet (price ₱3,100 - ₱4,428)',
  'sink (price ₱5,248)','refrigerator (price ₱8,708)','water pipe (price ₱6,506)','gas line (price ₱6,506)',
  'doorlock (price ₱650)','sewer (price ₱10,807)','stove burner (price ₱8,645)',
];
List maintenanceData = [];
String _selectedUser;
int property;
int dataTenant;
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
  getPropertyTenant();
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
  void getPropertyTenant() async {
    var res = await CallApi().getData('tenant/${widget.user}');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
     dataTenant = myMap['data']['id'];
    getAllMaintenance(dataTenant);
    var response = await CallApi().getData('getProperty/$dataTenant}');
    var body = jsonDecode(response.body);
    Map<String, dynamic> userData = Map<String, dynamic>.from(body);

    setState(() {

     property = userData['data']['id'];
    });
  }
  void getAllMaintenance(id) async {
    // getMaintenancePerTenant

    var res = await CallApi().getData('getMaintenancePerTenant/tenant=$id');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {

      maintenanceData = myMap['data'];
      print(maintenanceData);
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
      body:getGrid(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Create Maintenance'),
        onPressed: (){
           showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (BuildContext context,StateSetter setState){
                      return AlertDialog(
                        title: const Text('Create Maintenance Request'),
                        content:  SizedBox(
                          height: 230.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              DropdownButton(
                                  hint: Text('Maintenance type'),
                                  value: _selectedUser,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedUser = newValue;

                                    });
                                  },
                                  items: _userType.map((location) {
                                    return DropdownMenuItem(
                                      child: new Text(location,style: TextStyle(fontSize: 14.0),),
                                      value: location,
                                    );
                                  }).toList()),

                              SizedBox(height: 20.0),


                              TextFormField(
                                controller: _scenarioController,

                                maxLines: 2,
                                decoration:InputDecoration(labelText: 'Scenario'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "Please enter a scenario";
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: createMaintenance,
                            child: const Text('Saved'),
                          ),
                        ],
                      );

                });
          });

      },

    ),

    );
  }
Widget getGrid() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
          child: loading != false ?  Container(

            child: StaggeredGridView.countBuilder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                crossAxisCount: 1,
                itemCount: maintenanceData.length,
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
                              SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.sticky_note_2,size: 20.0,color: Colors.deepOrange[600]),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16.0),
                                      child: Text('Ticket No. ${maintenanceData[index]['id'].toString().padLeft(6, '0')}',style: TextStyle(
                                          fontSize: 16.0,fontWeight: FontWeight.bold,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 40.0),
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
                                          child:    Text('${maintenanceData[index]['title']}'),
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
                                          child:   Text('${maintenanceData[index]['maintenance_type']}',
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
                                          child: Text('${maintenanceData[index]['address']+ ' Brgy.'+maintenanceData[index]['barangay']+' City '+maintenanceData[index]['city']}',
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Row(

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                    child: Text('Scenario',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                  ),
                                ],
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
                                        Icon(Icons.handyman_rounded,size: 18.0,color: Colors.deepOrange[600]),

                                        Padding(
                                          padding: const EdgeInsets.only(left:16.0),
                                          child: Column(
                                            children: [

                                              Text('${maintenanceData[index]['scenario']}',
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(height: 20.0),
                              Row(

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                    child: Text('Maintenance Status',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                        children: [


                                          Padding(
                                            padding: const EdgeInsets.only(left:16.0),
                                            child: Container(
                                              padding:  EdgeInsets.all(9.0),
                                              child:SizedBox( width: 106.0, child:Center(
                                                child: Text('${maintenanceData[index]['maintenance_status']} ',style: TextStyle(
                                                  color:Colors.white,
                                                ),),
                                              ),),
                                              decoration: BoxDecoration(
                                                color:Colors.green[800] ,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: const EdgeInsets.only(left:16.0,right: 16.0),
                                          //
                                          //   child: ElevatedButton(  style:ButtonStyle(
                                          //       backgroundColor: MaterialStateProperty.all(Colors.red)),onPressed: (){
                                          //     deleteMaintenance(maintenanceData[index]['id']);
                                          //   },child:Row(
                                          //     children: [
                                          //       Icon(Icons.delete),
                                          //       SizedBox(width: 10.0),
                                          //       Text('Delete Maintenance '),
                                          //     ],
                                          //   )),
                                          // ),

                                        ]
                                    ),
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
void createMaintenance() async{

  if(property != null){

    var data = {
      'property_id': property,
      'maintenance_type':_selectedUser,
      'scenario': _scenarioController.text
    };
    var res = await CallApi().postData(data, 'createMaintenance');
    var body = jsonDecode(res.body);
    if (body['success']) {

      sendNotifications();
      var res = await CallApi().getData('getMaintenancePerTenant/tenant=$dataTenant');
      var items = jsonDecode(res.body);
      Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
      _showMsg(body['message']);
      maintenanceData.clear();


      setState(() {
        maintenanceData = myMap['data'];
        Navigator.pop(context, 'Cancel');

      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Removed Screening Data ')),
      );
    }
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are not renting a property')),
    );
  }

}
void sendNotifications() async{

  var response = await CallApi().getData('landlordUserId/$property');
  var data = jsonDecode(response.body);
  int landlord = data['data']['user_id'];

  var message = "You have a new maintenance request";

  var dataNotification = {
    'user_id':widget.user,
    'message_notification':message,
    'to':landlord,
  };
  var res = await CallApi().postData(dataNotification,'createNotification');
  var items = jsonDecode(res.body);


}
void deleteMaintenance(id) async{
  var res = await CallApi().deleteData('maintenanceDelete/$id}');
  var items = jsonDecode(res.body);
  print(items);
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
      const SnackBar(content: Text('Unable to  Removed Maintenance Request ')),
    );
  }
}
}

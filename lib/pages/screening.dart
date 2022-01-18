import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/screeningOverview.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';
class Screening extends StatefulWidget {
  final int landlord;
  final String landlordName;
  const Screening(
      {
        Key key,
        this.landlord,
        this.landlordName,
      }
      ) : super(key: key);

  @override
  _ScreeningState createState() => _ScreeningState();
}

class _ScreeningState extends State<Screening> {
  var userData;
  var userId;
  int landlordID;
  String fname;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  List listOfProperty = [];
  final formatCurrency = new NumberFormat.currency(locale: "en_US",symbol: "₱");
  @override
  void initState() {
    if(widget.landlord != null && widget.landlordName != null){
      landlordID = widget.landlord;
      fname = widget.landlordName;

    }
    super.initState();
    getAllLandlordProperties();
    startLoading();

  }
  void startLoading() async{
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      setState(() {
        isLoading = false;

      });
    });
  }


  Future getAllLandlordProperties() async {

    var res = await CallApi().getData('getAllPropertyLandlord/$landlordID');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);

    setState(() {
      listOfProperty = myMap['data'];
      print(listOfProperty);
      print(fname);

    });
    loading = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: getGrid(),
    );
  }
  Widget getGrid() {
    return RefreshIndicator(
      onRefresh:(){
        return getAllLandlordProperties();
      },

      child: Column(


        children: [
          Expanded(
              child:  loading != false ? Container(

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


                                      FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: "${listOfProperty[index]['showroom_img']}",
                                          height: 250,
                                          //
                                          width: MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth
                                      ),

                                      SizedBox(height: 10.0),
                                      Text('${listOfProperty[index]['title']}'),
                                      SizedBox(height: 10.0),
                                      Text('${formatCurrency.format(listOfProperty[index]['price'])}'),
                                      SizedBox(height: 10.0),
                                      Text('${listOfProperty[index]['address']}'),
                                      SizedBox(height: 10.0),
                                      Text(listOfProperty[index]['status'] == 1 ? 'Status: Rented':'Status: Vaccant'),
                                      SizedBox(height: 10.0),
                                      ElevatedButton(onPressed: (){
                                        var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                        new OverviewScreening(property:listOfProperty[index]['id'] ,landlord: landlordID,landlordName:fname));
                                        Navigator.of(context).push(route);
                                      },
                                          child: Text('View Screening')),

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
          // FloatingActionButton(
          //     onPressed: () {},
          //     child: const Icon(Icons.navigation),
          //     backgroundColor: Colors.green)
        ],
      ),
    );
  }
}

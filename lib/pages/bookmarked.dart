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

class Bookmarked extends StatefulWidget {
  final int user;
  const Bookmarked(
      {
        Key key,
        this.user
      }
      ) : super(key: key);

  @override
  _BookmarkedState createState() => _BookmarkedState();
}

class _BookmarkedState extends State<Bookmarked> {
  var tenantData;
  var _isVisible = true;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  List bookmarked = [];
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

    setState(() {
      tenantData = dataTenant;

      getAllBookmark(tenantData);
    });
  }
  Future<void> getAllBookmark(id) async{
    var res = await CallApi().getData('getAllBookmark/$id');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      bookmarked = myMap['data'];


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
        return getAllBookmark(tenantData);
      },

      child: Column(


        children: [
          Expanded(
              child: loading != false ?  Container(

                child: StaggeredGridView.countBuilder(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    crossAxisCount: 1,
                    itemCount: bookmarked.length,
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


                                  Visibility(
                                      visible: _isVisible,
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                          children:[

                                      IconButton(icon: Icon(CupertinoIcons.heart_fill,size: 30.0,color: Colors.deepOrange[600]),
                                            onPressed: (){
                                              deleteBookmark(bookmarked[index]['id']);

                                            },
                                      )],
                                      ),
                                  ),
                                      FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: "${bookmarked[index]['showroom_img']}",
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
                                            SizedBox(height: 20.0),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.home,size: 18.0,color: Colors.deepOrange[600]),
                                                SizedBox(width: 17.0),
                                                Text('${bookmarked[index]['title']}'),
                                              ],
                                            ),
                                            SizedBox(height: 20.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(CupertinoIcons.tag_solid,size: 18.0,color: Colors.deepOrange[600]),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 16.0),
                                                  child:   Text('${formatCurrency.format(bookmarked[index]['price'])}',
                                                  ),

                                                )
                                              ],
                                            ),
                                            SizedBox(height: 20.0),
                                            Row(
                                              children: [
                                                Icon(CupertinoIcons.location,size: 18.0,color: Colors.deepOrange[600]),

                                                Padding(

                                                  padding: EdgeInsets.only(left: 16.0),
                                                  child: Text('${bookmarked[index]['address']+ ' Brgy.'+bookmarked[index]['barangay']+' City '+bookmarked[index]['city']}'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20.0),
                                            Text(bookmarked[index]['status'] == 1 ? 'Status: Rented':'Status: Vaccant'),
                                            SizedBox(height: 20.0),

                                          ],
                                        ),
                                      )

                                    ]),
                              ),
                            ],
                          ));
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
              ) :   Center(
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
  void deleteBookmark(id) async{
    var res = await CallApi().deleteData( 'deleteBookmark/$id');

    var body = jsonDecode(res.body);
    if (body['success']) {
      _showMsg(body['message']);
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => this.widget));

      });

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Update Property')),
      );
    }
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/virtualShowroom.dart';
import 'package:flutter_telaco/widgets/calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';
import 'calendar.dart';

class OverviewProperty extends StatefulWidget {
  final String title;
  final String description;
  final String addr;
  final int price;
  final double lat;
  final double lng;
  final String city;
  final int property;
  final String brgy;
  final String image;
  final int landlord;
  final int tenant;
  const OverviewProperty({
    Key key,
    this.landlord,
    this.property,
    this.title,
    this.city,
    this.brgy,
    this.lat,
    this.addr,
    this.lng,
    this.description,
    this.price,
    this.image,
    this.tenant
  }) : super(key: key);

  @override
  _OverviewPropertyState createState() => _OverviewPropertyState();
}

class _OverviewPropertyState extends State<OverviewProperty> {
  String propertyTitle;
  int price;
  final formatCurrency = new NumberFormat.currency(locale: "en_US",symbol: "₱");
  Set<Marker> _marker = {};
  double lt;
  double lg;
  int landlordId;
  String firstName;
  String email;
  String contact;
  int propertyId;
  int landlord;
  String totalReviews;
  String totalRatings;
  List ratingsAndReviews = [];
  static const LatLng  _initialPosition =  const LatLng(14.40,121.03);
  GoogleMapController _controller;
  @override
  void initState() {

      if(widget.lat != null && widget.lng != null &&  widget.landlord != null && widget.property != null){
        lt = widget.lat;
        lg = widget.lng;
        landlordId = widget.landlord;
        propertyId = widget.property;


      }

    super.initState();
      _userInfo();
      getAllRatings();
  }
  void _userInfo() async{
    var res = await CallApi().getData('userId/$landlordId');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);

   var dataName = myMap['data']['user']['name'];
    var dataEmail = myMap['data']['user']['email'];
    var dataContact = myMap['data']['user']['contact'];
    var dataUserID = myMap['data']['user']['id'];
    setState(() {
      firstName = dataName;
      email = dataEmail;
      contact = dataContact;
      landlord = dataUserID;
    });

  }
  void getAllRatings () async{

    var res = await CallApi().getData('getAllRatings/$propertyId');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    var reviews = myMap['total_review'][0]['total_reviews'];
    var rating = myMap['total_review'][0]['total'];
    if(rating == null){
        rating = '0';
    }
    setState(() {
      totalReviews = reviews.toString();
      totalRatings = double.parse(rating).toStringAsFixed(2);

       ratingsAndReviews = myMap['data'];


    });





  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text( MyApp.title),
      ),
      body:SingleChildScrollView(
        child: Column(

          children: [

             Padding(
               padding: EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),

               child:
               Column(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [

                   SizedBox(height:20.0),
                   Container(
                     height: 250,
                     child:
                     GestureDetector(
                       child: GoogleMap(
                         gestureRecognizers: Set()
                           ..add(Factory<OneSequenceGestureRecognizer>(
                                   () => new EagerGestureRecognizer()))
                           ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                           ..add(
                               Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                           ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                           ..add(Factory<VerticalDragGestureRecognizer>(
                                   () => VerticalDragGestureRecognizer())),
                           initialCameraPosition: CameraPosition(
                             target: LatLng(lt,lg),
                             zoom:12.0,

                           ),


                           mapType: MapType.normal,
                           onMapCreated: _mapCreated,
                           markers: _marker,
                           // onCameraMove: (position){
                           //  setState(() {
                           //    _controller.animateCamera(CameraUpdate.newCameraPosition(position));
                           //
                           //  });
                           // },

                       ),
                     ),
                   ),
                  SizedBox(height: 20.0),
                   Text('Property Details ',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                   SizedBox(height: 20.0),

                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,

                     children: <Widget>[
                       Icon(Icons.house ,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child: Text(widget.title != null ? 'Property Name: ${widget.title}':''),
                       ),
                       Icon(CupertinoIcons.tag_solid,size: 18.0,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child: Text(widget.price != null ? '${formatCurrency.format(widget.price)}':''),
                       ),
                     ],
                   ),
                   SizedBox(height: 20.0),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,


                     children: <Widget>[

                       Icon(Icons.location_on,size: 20.0 ,color: Colors.deepOrange[600]),
                       Expanded(

                         child:   Padding(
                           padding: EdgeInsets.only(left: 16.0),
                           child: Text(widget.addr!= null && widget.brgy != null && widget.city != null ? 'Address: ${widget.addr} Brgy.${widget.brgy} ${widget.city} City' : ''),
                         ),
                       )

                     ],
                   ),

                   SizedBox(height: 20.0),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,

                     children: <Widget>[

                       Icon(Icons.description,size: 20.0 ,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child:   Text('Description:'),
                       )

                     ],
                   ),
                   SizedBox(height: 20.0),
                   Text(widget.description != null ? '${widget.description}':''),
                   SizedBox(height: 20.0),
                   Text('Contact Information',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                   SizedBox(height: 20.0),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,

                     children: <Widget>[

                       Icon(Icons.person,size: 20.0 ,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child:   Text(firstName != null ? 'Name: ${firstName.toUpperCase()}' : ''),
                       )

                     ],
                   ),
                   SizedBox(height: 20.0),

                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,

                     children: <Widget>[

                       Icon(Icons.phone,size: 20.0 ,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child:   Text(contact != null ? 'Contact: ${contact}' : 'N/A'),
                       )

                     ],
                   ),
                   SizedBox(height: 20.0),

                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,

                     children: <Widget>[

                       Icon(Icons.email,size: 20.0 ,color: Colors.deepOrange[600]),
                       Padding(
                         padding: EdgeInsets.only(left: 16.0,right: 16.0),
                         child:   Text(email != null ? 'Name: ${email}' : 'N/A'),
                       )

                     ],
                   ),
                   SizedBox(height: 20.0),


                   Row(

                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                     children: <Widget>[



                       Expanded(

                         child: TextButton(

                             style: ButtonStyle(
                                 backgroundColor:
                                 MaterialStateProperty.all(Colors.deepOrange[800])),
                               onPressed:  () {
                                 var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                 new VirtualShowroom(
                                   showroomImage: widget.image,
                                 ),

                                 );
                                 Navigator.of(context).push(route);
                               },
                              child: Text(
                              'Enter Virtual Showroom',
                              style: TextStyle(color: Colors.white),
                              )
                             ),

                       ),
                       SizedBox(width: 20.0),

                       Expanded(

                         child: TextButton(
                             style: ButtonStyle(
                                 backgroundColor:
                                 MaterialStateProperty.all(Colors.deepOrange[800])),
                                 onPressed: () {
                                   var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                   new Calendar( dataTitle: widget.title, property: propertyId,tenantUserId: widget.tenant,landlordUserId: landlord,

                                    ),

                                   );
                                   Navigator.of(context).push(route);
                                  },


                             child: Text(
                               'INQUIRE',
                               style: TextStyle(color: Colors.white),
                             )),
                       )

                     ],
                   ),
                   SizedBox(height: 30.0),

                   Text(totalReviews != null ? '$totalRatings/5 Ratings and $totalReviews Reviews ' : 'Ratings and Reviews',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                   SizedBox(height: 20.0),
                   Container(
                     child: totalRatings != null ? stars() : Text('No Reviews and ratings yet !'),
                   ),
                   SizedBox(height: 30.0),


                 ],
               ),

             ),
          ],
        ),
      ),
    );
  }
  Widget stars(){

    return Container(
      child: ListView.builder(
          itemCount: ratingsAndReviews.length,

          shrinkWrap: true,
          itemBuilder: (context,index){
            if(ratingsAndReviews[index]['rating'] == 5){
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width,
                    child: Card(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(ratingsAndReviews[index]['avatar_original'] != null ? '${ratingsAndReviews[index]['avatar_original']}':'${ratingsAndReviews[index]['avatar']}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 20.0),
                                    Text('${ratingsAndReviews[index]['name']}'),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Text('${ratingsAndReviews[index]['comment']}'),
                                    SizedBox(height: 10.0),
                                    Text('${DateFormat('d MMMM y  ').format(DateTime.tryParse(ratingsAndReviews[index]['created_at']))}'),
                                    SizedBox(height: 20.0),




                                  ],
                                ),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),

                );
            }
            else if(ratingsAndReviews[index]['rating'] == 4){
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width,
                    child: Card(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(ratingsAndReviews[index]['avatar_original'] != null ? '${ratingsAndReviews[index]['avatar_original']}':'${ratingsAndReviews[index]['avatar']}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 20.0),
                                    Text('${ratingsAndReviews[index]['name']}'),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),

                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Text('${ratingsAndReviews[index]['comment']}'),
                                    SizedBox(height: 10.0),
                                    Text('${DateFormat('d MMMM y  ').format(DateTime.tryParse(ratingsAndReviews[index]['created_at']))}'),
                                    SizedBox(height: 20.0),




                                  ],
                                ),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),

                );
            }
            else if(ratingsAndReviews[index]['rating'] == 3) {
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width,
                    child: Card(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(ratingsAndReviews[index]['avatar_original'] != null ? '${ratingsAndReviews[index]['avatar_original']}':'${ratingsAndReviews[index]['avatar']}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 20.0),
                                    Text('${ratingsAndReviews[index]['name']}'),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),


                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Text('${ratingsAndReviews[index]['comment']}'),
                                    SizedBox(height: 10.0),
                                    Text('${DateFormat('d MMMM y  ').format(DateTime.tryParse(ratingsAndReviews[index]['created_at']))}'),
                                    SizedBox(height: 20.0),




                                  ],
                                ),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),

                );
            }
            else if(ratingsAndReviews[index]['rating'] == 2) {
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width,
                    child: Card(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(ratingsAndReviews[index]['avatar_original'] != null ? '${ratingsAndReviews[index]['avatar_original']}':'${ratingsAndReviews[index]['avatar']}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 20.0),
                                    Text('${ratingsAndReviews[index]['name']}'),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),


                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Text('${ratingsAndReviews[index]['comment']}'),
                                    SizedBox(height: 10.0),
                                    Text('${DateFormat('d MMMM y  ').format(DateTime.tryParse(ratingsAndReviews[index]['created_at']))}'),
                                    SizedBox(height: 20.0),




                                  ],
                                ),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),

                );
            }
            else if(ratingsAndReviews[index]['rating'] == 1) {
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width,
                    child: Card(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(ratingsAndReviews[index]['avatar_original'] != null ? '${ratingsAndReviews[index]['avatar_original']}':'${ratingsAndReviews[index]['avatar']}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 20.0),
                                    Text('${ratingsAndReviews[index]['name']}'),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.yellowAccent,size: 24.0,),
                                        SizedBox(width: 10.0),



                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Text('${ratingsAndReviews[index]['comment']}'),
                                    SizedBox(height: 10.0),
                                    Text('${DateFormat('d MMMM y  ').format(DateTime.tryParse(ratingsAndReviews[index]['created_at']))}'),
                                    SizedBox(height: 20.0),




                                  ],
                                ),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),

                );
            }
            else{
              return Text('No review and ratings yet !');
            }


          }

      ),
    );
  }
  void _mapCreated (GoogleMapController controller) async{
    setState(() {

      _marker.add(
          Marker(
            markerId:  MarkerId(LatLng(lt,lg).toString()),
            position: LatLng(lt, lg),
            infoWindow: InfoWindow(
              title: widget.title != null ? 'Property Name: ${widget.title}' : '',
              snippet: widget.addr!= null && widget.brgy != null && widget.city != null ? 'Address: ${widget.addr} Brgy.${widget.brgy} ${widget.city} City' : '',
            ),


          ),

      );


    });
  }



}




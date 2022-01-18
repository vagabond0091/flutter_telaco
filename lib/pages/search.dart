import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';
import 'overviewProperty.dart';

class Search extends StatefulWidget {
  final String searchData;
  final int tenant;
  const Search({
    Key key,
    this.searchData,
    this.tenant
    }) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List listOfProperty = [];
  List listOfCity = [];
  List collectionsOfCity = [];
  GoogleMapController googleMapController;
  List mapMarker = [];
  List< Marker> markers =[];
  List _indoorFeatures = [];
  List _outdoorFeatures = [];
  String message;
  final formatCurrency = new NumberFormat.currency(locale: "en_US",symbol: "₱");
  int startPrice = 0;
  int endPrice = 30000;
  double dataStartPrice;
  double dataEndPrice;
  double priceRange;
  String search;
  String city;
  int selectedIndoorFeature;
  int selectedOutdoorFeature;
  RangeValues priceValue = RangeValues(0, 30000);
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  static  LatLng  _initialPosition;
  stt.SpeechToText _speech;
  bool _isListening = false;
  double confidence =  1.0;
  @override
  void initState()  {

    filterByBarangay();
    getIndoorFeatures();
    getOutdoorFeatures();
    _property();
    super.initState();

  }
  void _property() async {
    var res = await CallApi().getData('collections/${widget.tenant}');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfCity = myMap['property'];
      listOfCity.forEach((item) {
        collectionsOfCity.add(item['city']);
      });
      print(collectionsOfCity);

    });
  }
  void getIndoorFeatures() async{

    var res = await CallApi().getData('getIndoor');
    var body = jsonDecode(res.body);


    Map<String, dynamic> jsonMaps = Map<String, dynamic>.from(body);
    setState(() {
      _indoorFeatures = jsonMaps['data'];
      print(_indoorFeatures);
    });


  }
  void getOutdoorFeatures() async{
    var res = await CallApi().getData('getOutdoor');
    var body = jsonDecode(res.body);


    Map<String, dynamic> jsonMaps = Map<String, dynamic>.from(body);
    setState(() {
      _outdoorFeatures = jsonMaps['data'];


    });


  }
  void filterByBarangay() async{
    var res = await CallApi().getData('search?search-collection=${widget.searchData}');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfProperty = myMap['data'];
      print(listOfProperty);
      if(listOfProperty[0]['latitude'] != null && listOfProperty[0]['longtitude'] != null){
        _initialPosition =   LatLng(listOfProperty[0]['latitude'],listOfProperty[0]['longtitude']);
      }
      else{
        _initialPosition =   LatLng(14.406843096441726, 121.03706555761143);
      }

        listOfProperty.forEach((element) {
          var productMap = {
            'lat': element['latitude'],
            'lng': element['longtitude'],
            'markerId': element['id'],
          };
           Marker marker =  Marker(
               markerId: MarkerId(element['id'].toString()),
               position: LatLng(element['latitude'],element['longtitude']),
               infoWindow: InfoWindow(title: element['title'])
          );
          markers.add(marker);

        });

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
            children: [
              googleMaps(context),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8.0),
                child: Column(

                  children: [
                    SizedBox(height: 20.0),
                    Form(
                      key: _formkey,
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(hintText: 'Search a city',suffixIcon: IconButton(
                          icon:  Icon(Icons.search,color: Colors.deepOrange[800],size: 30.0,),

                          onPressed: (){
                            search = _searchController.text;
                            filterByBarangayInsideWidget(search);
                          },
                        ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange[800], width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange[800], width: 2.0),
                          ),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter city name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text('Select a filter for Property',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0)),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price Range'),




                                 SizedBox(
                                   width: 300.0,
                                   child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTickMarkColor: Colors.transparent,
                                          inactiveTickMarkColor: Colors.transparent,
                                          overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                                        ),
                                        child: RangeSlider(
                                            values: priceValue,
                                            min: 0,
                                            max: 30000,
                                            divisions: 20,
                                            labels: RangeLabels(
                                              formatCurrency.format(priceValue.start.round()),
                                                formatCurrency.format(priceValue.end.round()),
                                            ),
                                            onChanged: (priceValue){

                                         setState(() {

                                           this.priceValue = priceValue;
                                           dataStartPrice = this.priceValue.start;
                                           dataEndPrice = this.priceValue.end;

                                         });
                                        }),
                                      ),
                                 ),
                                Row(
                                  children: [
                                    ElevatedButton(onPressed: (){
                                    filterByPrice();
                                    },
                                        style: ButtonStyle(
                                          // side: BorderRadius()
                                        ),
                                        child: Text('Apply Price Range')
                                    ),
                                  ],
                                ),

                                ],
                              )
                            ],

                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text('Select Amenities to filter property',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0)),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Column(
                        children: [

                          SizedBox(height: 10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Indoor Features: '),
                              DropdownButton(
                                  hint: Text('Please choose a amenities'),
                                  value: selectedIndoorFeature,
                                  onChanged: (newValue) {
                                    setState(() {

                                      selectedIndoorFeature = newValue;

                                    });
                                  },
                                  items: _indoorFeatures?.map((item) {
                                    return new DropdownMenuItem(
                                      child: new Text(item['IndoorFeatures']),
                                      value: item['id'],
                                    );
                                  })?.toList()) ?? [],


                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Outdoor Features: '),
                              DropdownButton(
                                  hint: Text('Please choose a amenities'),
                                  value: selectedOutdoorFeature,
                                  onChanged: (newValue) {
                                    setState(() {

                                      selectedOutdoorFeature = newValue;

                                    });
                                  },
                                  items: _outdoorFeatures?.map((item) {
                                    return new DropdownMenuItem(
                                      child: new Text(item['OutdoorFeatures']),
                                      value: item['id'],
                                    );
                                  })?.toList()) ?? [],


                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              ElevatedButton(onPressed: (){
                                filterByAmenities();
                              },
                                  style: ButtonStyle(
                                    // side: BorderRadius()
                                  ),
                                  child: Text('Apply Amenities')
                              ),
                            ],
                          ),



                        ],
                      ),
                    )

                  ],
                ),
              ),
              SizedBox(height: 10.0),

              Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8.0),
                child: properties(),
              ),
            ],
          ),
      ),

        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton.extended(
              icon: Icon( _isListening ? Icons.mic : Icons.mic_none),
              label: _isListening ?  Text('Searching....'): Text('Search a City'),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onPressed: () {
                _speech = stt.SpeechToText();
                    _listen();
              }),
        )
    );
  }
  Widget googleMaps(BuildContext context){
    return Container(
      height: 500,
      width: double.infinity,
      child: GestureDetector(
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
            target:_initialPosition != null ? _initialPosition :  LatLng(14.406843096441726, 121.03706555761143),
            zoom:12.0,

          ),

          mapType: MapType.normal,
          onMapCreated: (controller){
            setState(() {
              googleMapController = controller;
            });
          },
          markers: Set<Marker>.of(markers)




        ),
      ),
    );
  }
  Widget properties(){
    return listOfProperty.isNotEmpty  ?
    Column(
      children:[
        Text('List of Property',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0)),
        SizedBox(height: 10.0),
      ListView.builder(
          itemCount:listOfProperty.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context,index){
            return Card(
              child:Row(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: "${listOfProperty[index]['showroom_img']}",
                        height: 100,
                        //
                        width: 100,
                        fit: BoxFit.fitWidth
                    ),
                  ),
                  SizedBox(width: 10.0 ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right:8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(right:8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Row(
                                 children: [
                                   Icon(Icons.home,color: Colors.deepOrange[800],),
                                   SizedBox(width: 10.0),
                                   Text(listOfProperty[index]['title'] != null ? '${listOfProperty[index]['title']}':''),
                                 ],
                               ),


                                Row(
                                  children: [
                                    Icon(CupertinoIcons.tag_solid,size: 19.0,color: Colors.deepOrange[600]),
                                    SizedBox(width: 10.0),
                                    Text(listOfProperty[index]['price'] != null ? '${formatCurrency.format(listOfProperty[index]['price'])}':''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,color: Colors.deepOrange[800],),
                            SizedBox(width: 10.0),
                            Expanded(child: Text(listOfProperty[index]['address'] != null ? '${listOfProperty[index]['address']} Brgy. ${listOfProperty[index]['barangay']} ${listOfProperty[index]['city']} City ':'')),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [

                               SizedBox(
                                 width:100,
                                 height:30,
                                 child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty.all(Colors.deepOrange)),
                                    onPressed: () async {
                                      var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                      new OverviewProperty(title:listOfProperty[index]['title'],description: listOfProperty[index]['description'],
                                        addr:listOfProperty[index]['address'],city:listOfProperty[index]['city'],brgy:listOfProperty[index]['barangay'],
                                        image:listOfProperty[index]['showroom_img'],landlord:listOfProperty[index]['landlord_id'],property:listOfProperty[index]['id'],
                                        price:listOfProperty[index]['price'], lat:listOfProperty[index]['latitude'],lng:listOfProperty[index]['longtitude'],


                                      ),

                                      );
                                      Navigator.of(context).push(route);
                                    },
                                    child: Text(
                                      'View Property',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                               ),

                          ],
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),

                ],
              )
            ) ;
         }
      ),
    ]
    ) : Column(

      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('No property found ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0)),
          ],
        ),
      ],
    );
  }
  Widget buildSideLabel(int value){
    return Container(
      width: 30,
      child: Text(
          value.round().toString(),
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,

        ),
        textAlign: TextAlign.center,

      ),
    );
  }
  void filterByPrice() async{
    if(search != null){
     city = search;
    }
    else{
      city = widget.searchData;
    }
    print(city);
    print(dataStartPrice);
    print(dataEndPrice);
    var res = await CallApi().getData('mobilfilterByPrice/$dataStartPrice/$dataEndPrice/$city');
    var items = jsonDecode(res.body);
    print(items);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    listOfProperty.clear();
    markers.clear();
    setState(() {
      listOfProperty = myMap['data'];
      listOfProperty.forEach((element) {

        Marker marker =  Marker(
            markerId: MarkerId(element['id'].toString()),
            position: LatLng(element['latitude'],element['longtitude']),
            infoWindow: InfoWindow(title: element['title'])
        );
        markers.add(marker);

      });
    });



  }
  void filterByAmenities() async{
    if(search != null){
      city = search;
    }
    else{
      city = widget.searchData;
    }
    print(city);
    print(selectedOutdoorFeature);
    print(selectedIndoorFeature);
    var res = await CallApi().getData('filterByTypes/$selectedOutdoorFeature/$selectedIndoorFeature/$city');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    print(items);
    listOfProperty.clear();

    markers.clear();
    setState(() {
      listOfProperty = myMap['data'];

      listOfProperty.forEach((element) {

        Marker marker =  Marker(
            markerId: MarkerId(element['id'].toString()),
            position: LatLng(element['latitude'],element['longtitude']),
            infoWindow: InfoWindow(title: element['title'])
        );
        markers.add(marker);

      });
    });



  }
  void filterByBarangayInsideWidget(searchBrgy) async{

    var res = await CallApi().getData('search?search-collection=$searchBrgy');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);

    print(items);
    listOfProperty.clear();

    markers.clear();
    setState(() {
      listOfProperty = myMap['data'];


      listOfProperty.forEach((element) {
        var productMap = {
          'lat': element['latitude'],
          'lng': element['longtitude'],
          'markerId': element['id'],
        };
        Marker marker =  Marker(
            markerId: MarkerId(element['id'].toString()),
            position: LatLng(element['latitude'],element['longtitude']),
            infoWindow: InfoWindow(title: element['title'])
        );
        markers.add(marker);

      });

    });
  }


  void _listen() async{

    bool available = true;
    var status;

    if (!_isListening) {
      _isListening = true;
      await _speech.initialize(
        onStatus: (val) {
          print('$val');
          if(val == 'notListening'){
            setState(() {
              _isListening = false;
              available = false;

            });
            List<String> cities =  collectionsOfCity.cast<String>();
            cities.forEach((element) {
              print(message);
              if(message.contains(element.toLowerCase())){
                var search = element.toLowerCase();
                print(search);
                print(message);
                voiceSearch(element.toLowerCase());
                _speech.stop();

              }


            });




          }
        },
        onError: (val) => print('onError: $val'),

      );
      print(available);
      if (available) {
        print(available);
        _speech.listen(
          onResult: (val) => setState(() {
            message = val.recognizedWords;
            print(message);


          }),
        );
      }
      else {
        print("The user has denied the use of speech recognition.");
      }
    }


    print('outside the if statement$_isListening');
  }
  void voiceSearch(searchBrgy) async{
    print(searchBrgy);
    var res = await CallApi().getData('search?search-collection=$searchBrgy');
    var items = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    print(items);
    listOfProperty.clear();

    markers.clear();
    setState(() {
      listOfProperty = myMap['data'];

      print(listOfProperty);
      listOfProperty.forEach((element) {
        var productMap = {
          'lat': element['latitude'],
          'lng': element['longtitude'],
          'markerId': element['id'],
        };
        Marker marker =  Marker(
            markerId: MarkerId(element['id'].toString()),
            position: LatLng(element['latitude'],element['longtitude']),
            infoWindow: InfoWindow(title: element['title'])
        );
        markers.add(marker);


      });
      print(markers);
    });
  }
}


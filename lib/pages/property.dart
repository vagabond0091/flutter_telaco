
// import 'dart:html';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class PropertyCreate extends StatefulWidget {
  // const PropertyCreate({ Key? key }) : super(key: key);

  @override
  _PropertyCreateState createState() => _PropertyCreateState();
}

class _PropertyCreateState extends State<PropertyCreate> {
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _province = TextEditingController();
  TextEditingController _barangay = TextEditingController();
  TextEditingController _addr = TextEditingController();
  TextEditingController _latController = TextEditingController();
  TextEditingController _lngController = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _bedroomsController = TextEditingController();
  TextEditingController _bathsController = TextEditingController();
  TextEditingController _floorareaController = TextEditingController();
  TextEditingController _lotNumberController = TextEditingController();
  TextEditingController _subdivisionController = TextEditingController();
  TextEditingController _totalRoomController = TextEditingController();
  TextEditingController _carSpaceController = TextEditingController();
  TextEditingController _totalFloorController = TextEditingController();

  double _lat;
  double _lng;
  static const LatLng  _initialPosition =  const LatLng(14.40,121.03);

  GoogleMapController _controller;
  File imageFile;
  bool isChecked = false;
  List _indoorFeatures = [];
  List _outdoorFeatures = [];
  List _propertyType = [];
  List _propertySubType = [];
  List<Marker> myMarker = [];
  List userChecked = [];
  List userCheckedOutdoor = [];
  int selectedPropertyType;
  int selectedPropertySubType;
var landlord;
  var userData;
  String cloudinaryImage;
  final _picker = ImagePicker();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    _getPropertyType();
    _getUserInfo();
    getIndoorFeatures();
    getOutdoorFeatures();
    super.initState();


  }

  void _getUserInfo() async {

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = jsonDecode(userJson);

    setState(() {
      userData = user;

    });
  }

  void getIndoorFeatures() async{

    var res = await CallApi().getData('getIndoor');
    var body = jsonDecode(res.body);


      Map<String, dynamic> jsonMaps = Map<String, dynamic>.from(body);
      setState(() {
        _indoorFeatures = jsonMaps['data'];

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

  Future<void> _getPropertyType() async {
    var res = await CallApi().getData('getPropertyTypes');
    var body = jsonDecode(res.body);
    if (body['success']) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(body);
      setState(() {
        _propertyType = myMap['data'];

      });
    }
    // print(body);

    // print(selectedPropertyType);


  }

  Future getImage() async {
    final picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(pickedFile.path);

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

          child: Container(
            // alignment: Alignment.topLeft,
            child: Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Create a Property',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline3,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _title,
                        decoration: InputDecoration(labelText: 'title'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter property";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _province,
                        decoration: InputDecoration(labelText: 'Province'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter province';
                          }

                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Text('Property Type: '),
                          DropdownButton(
                              hint: Text('Please choose a Property type'),
                              value: selectedPropertyType,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedPropertySubType = null;
                                  selectedPropertyType = newValue;
                                  _getSubPropertyType(selectedPropertyType);
                                });
                              },
                              items: _propertyType?.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['property_type']),
                                  value: item['id'],
                                );
                              })?.toList()) ?? [],


                        ],
                      ),
                      Row(
                          children: [

                            Text('Property Sub Type:'),
                            DropdownButton(
                                hint: Text('Please select Property Subtype'),
                                value: selectedPropertySubType,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPropertySubType = newValue;
                                  });
                                },
                                items: _propertySubType.map((item) {
                                  return DropdownMenuItem(

                                    child: new Text(item['property_subtype']),
                                    value: item['id'],
                                  );
                                }).toList()),
                          ]
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _city,
                        decoration: InputDecoration(labelText: 'City'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter City";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _barangay,
                        decoration: InputDecoration(labelText: 'Barangay'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter Barangay";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _addr,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter address";
                          }

                          return null;
                        },
                      ),

                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _price,
                        decoration: InputDecoration(labelText: 'Price'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter Longtitude";
                          }

                          return null;
                        },
                      ),

                      SizedBox(height: 20.0),
                      Text('Upload Photos for Virtual Showroom'),
                      Padding(
                        padding: const EdgeInsets.all(16.0),

                        child: Container(

                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: 200,
                            decoration: BoxDecoration(
                                image: imageFile == null
                                    ? null
                                    : DecorationImage(
                                    image: FileImage(imageFile ?? File('')),
                                    fit: BoxFit.cover
                                )
                            )

                        ),
                      ),

                      TextButton.icon(
                        icon: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.black38,
                        ),
                        label: Text('Add Property Image'),
                        onPressed: getImage,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(

                          controller: _latController,
                        decoration: InputDecoration(labelText: 'Latitude'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter Latitude";
                          }


                          return null;
                        },

                      ),
                      SizedBox(height: 20.0),
                      TextFormField(

                        controller: _lngController,
                        decoration: InputDecoration(labelText: 'Longtitude'),
                        validator: ( String value) {
                          if (value.isEmpty) {
                            return "Please enter Longtitude";
                          }

                          return null;
                        },



                      ),
                      SizedBox(height: 20.0),
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
                              target: _initialPosition,
                              zoom:12.0,

                            ),

                            mapType: MapType.normal,
                            onMapCreated: (controller){
                              setState(() {
                                _controller = controller;
                              }
                              );
                            },

                            onTap:(LatLng latLng){
                              final lat = latLng.latitude;
                              final long = latLng.longitude;
                              _latController.text= lat.toString();
                              _lngController.text = long.toString();
                              _lng = long;
                              _lat = lat;
                              setState(() {
                                myMarker = [];
                                myMarker.add(Marker(
                                  markerId:  MarkerId(latLng.toString()),
                                  position: LatLng(lat,long),
                                 
                                ));

                              });

                            },
                            markers:Set.from(myMarker),
                          ),
                        ),

                      ),
                      SizedBox(height: 20.0),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text('Indoor Features',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                            SizedBox(height: 15.0),
                            ListView(
                              shrinkWrap: true,

                              // primary: false,
                              children: _indoorFeatures?.map((item) {
                                return new CheckboxListTile(
                                  title: Text(item['IndoorFeatures']),
                                  value: userChecked.contains(item['id']),
                                  onChanged: (val){
                                    setState(() {
                                      _onSelected(val,item['id']);
                                    });
                                  },
                                );
                              })?.toList() ?? [],

                            ),
                            Text('Outdoor Features',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                            SizedBox(height: 15.0),
                            ListView(
                              shrinkWrap: true,
                              // primary: false,
                              children: _outdoorFeatures?.map((item) {
                                return new CheckboxListTile(
                                  title: Text(item['OutdoorFeatures']),
                                  value: userCheckedOutdoor.contains(item['id']),
                                  onChanged: (val){
                                    setState(() {
                                      _onSelectedOutdoor(val,item['id']);
                                    });
                                  },
                                );
                              })?.toList() ?? [],

                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text('Additional Information',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
                      SizedBox(height: 10.0),
                      TextFormField(
                      controller: _bedroomsController,
                      decoration: InputDecoration(labelText: 'Bedrooms'),
                      validator: ( String value) {
                        if (value.isEmpty) {
                          return "Please enter number of bedrooms or N/A";
                        }

                        return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _bathsController,
                        decoration: InputDecoration(labelText: 'Bath'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter number of baths or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _floorareaController,
                        decoration: InputDecoration(labelText: 'Floorarea'),
                        validator: ( String value) {
                          if (value.isEmpty) {
                            return "Please enter number of floorarea or N/A" ;
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _lotNumberController,
                        decoration: InputDecoration(labelText: 'Lot Number'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter lot number or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _subdivisionController,
                        decoration: InputDecoration(labelText: 'Subdivision'),
                        validator: ( String value) {
                          if (value.isEmpty) {
                            return "Please enter subdivision or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _totalRoomController,
                        decoration: InputDecoration(labelText: 'Total Rooms'),
                        validator: ( String value) {
                          if (value.isEmpty) {
                            return "Please enter total rooms or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _carSpaceController,
                        decoration: InputDecoration(labelText: 'Car Space'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter Car Space or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _totalFloorController,
                        decoration: InputDecoration(labelText: 'Total Floors'),
                        validator: ( String value) {
                          if (value.isEmpty) {
                            return "Please enter total floors or N/A";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.deepOrangeAccent)),
                          onPressed: imageCloudinary,
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ))

                    ]),


              ),
            ),
          ),
        ),

    );
  }

  String getStringImage(File file) {
    if (file == null) {
      return null;
    }
    else {
      return base64Encode(file.readAsBytesSync());
    }
  }

  void imageCloudinary(){
    String realImg = "data:image/png;base64,";
    String image = imageFile == null ? null : getStringImage(imageFile);
    print(image);
    String img;


    if(image != null){
      img =realImg + image;
      uploadPropertyImage(img);
    }
    else{
      img ='';
    }
  }
  Future<void> uploadProperty(cloudinaryUrl) async {
    var response = await CallApi().getData('getLandlord/${userData['id']}');
    // //
    var bodyData = jsonDecode(response.body);
    Map<String, dynamic> dataMapping = Map<String, dynamic>.from(bodyData);
    // print(jsonMap['data']);
    setState(() {
      landlord = dataMapping['data']['id'];

    });







    var data = {
      'title': _title.text,
      'description': _description.text,
      'property_type':selectedPropertyType,
      'sub_property':selectedPropertySubType,
      'price':_price.text,
      'province': _province.text,
      'city': _city.text,
      'barangay': _barangay.text,
      'address': _addr.text,
      'latitude': _lat,
      'longtitude': _lng,
      'showroom_img': cloudinaryUrl,
      'bedrooms':_bedroomsController.text,
      'baths':_bathsController.text,
      'floorarea':_floorareaController.text,
      'lot_number':_lotNumberController.text,
      'subdivision':_subdivisionController.text,
      'total_room':_totalRoomController.text,
      'car_space':_carSpaceController.text,
      'total_floor':_totalFloorController.text,
      'landlord': landlord,
      'indoor_features':userChecked,
      'outdoor_features':userCheckedOutdoor,


    };

    if (_formkey.currentState.validate()) {
      var res = await CallApi().postData(data, 'createProperties');

      var body = jsonDecode(res.body);
      print(body);
      if (body['success']) {


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property Created Successfully')),
        );
        setState(() {
          Navigator.pop(context);

        });
      } else {
        _showMsg(body['message']);
      }
      return;
    }
  }
  //Widget

  Future<void> uploadPropertyImage(propertyImage) async{
    var data = {
      'showroom_img':propertyImage,
    };
    var res = await CallApi().postData(data, 'uploadImage');

    var body = jsonDecode(res.body);

    Map<String, dynamic> imageMapping = Map<String, dynamic>.from(body);
    if (body['success']) {
      setState(() {
        cloudinaryImage = imageMapping['data_url']['secure_url'];
        uploadProperty(cloudinaryImage);
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property Image upload failed !')),
      );
    }
  }
  //sub property type
  Future<void> _getSubPropertyType(property) async {

    // print(url);
    if (selectedPropertyType == null) {
      return;
    }
    else {
      var res = await CallApi().getData(
          'subproperty/$property');

      //     property = null;
      var body = jsonDecode(res.body);

      Map<String, dynamic> jsonMap = Map<String, dynamic>.from(body);
      // print(jsonMap['data']);
      setState(() {
        _propertySubType = jsonMap['data'];
        print(_propertySubType);
      });
    }

  }
  void _onSelected(bool selected, int id) {
    if (selected == true) {
      setState(() {
        userChecked.add(id);

      });
    } else {
      setState(() {
        userChecked.remove(id);
      });
    }
  }
  void _onSelectedOutdoor(bool selected, int id) {
    if (selected == true) {
      setState(() {
        userCheckedOutdoor.add(id);

      });
    } else {
      setState(() {
        userCheckedOutdoor.remove(id);
      });
    }
  }

}

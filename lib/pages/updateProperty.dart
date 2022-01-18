import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';

class UpdateProperty extends StatefulWidget {
  final String title;
  final int propertyID;
  final String description;
  final String showroom_img;
  final int landlord;

  final int price;
  final String bedrooms;
  final String baths;
  final String floorarea;
  final String lot_number;
  final String subdivision;
  final String total_room;
  final String total_floor;
  final String car_space;
  const UpdateProperty(
      {
        Key key,
        this.propertyID,
        this.title,
        this.description,
        this.landlord,

        this.floorarea,
        this.showroom_img,
        this.price,
        this.bedrooms,
        this.baths,
        this.car_space,
        this.lot_number,
        this.subdivision,
        this.total_room,
        this.total_floor,

      }
      ) : super(key: key);

  @override
  _UpdatePropertyState createState() => _UpdatePropertyState();
}

class _UpdatePropertyState extends State<UpdateProperty> {
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _bedrooms = TextEditingController();
  TextEditingController _bathsController = TextEditingController();
  TextEditingController _floorareaController = TextEditingController();
  TextEditingController _lotNumberController = TextEditingController();
  TextEditingController _subdivisionController = TextEditingController();
  TextEditingController _totalRoomController = TextEditingController();
  TextEditingController _carSpaceController = TextEditingController();
  TextEditingController _totalFloorController = TextEditingController();
  TextEditingController _price = TextEditingController();
  String showroomImg;
  int landlord;
  File imageFile;
  List _indoorFeatures = [];
  List _outdoorFeatures = [];
  List userChecked = [];
  List _selectedUser = ['Vacant','Rented'];
  List userCheckedOutdoor = [];
  String statusProperty;
  int status;
  int updateStatus;
  int property;
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
    if(widget.title != null && widget.description != null && widget.landlord != null && widget.bedrooms != null && widget.baths != null
        && widget.floorarea != null  && widget.lot_number != null  && widget.subdivision != null  && widget.total_room != null  && widget.car_space != null
        && widget.total_floor != null && widget.price != null && widget.propertyID != null
    ){
      _title.text = widget.title;
      _description.text = widget.description;
      landlord = widget.landlord;
      _bedrooms.text = widget.bedrooms;
      _bathsController.text = widget.baths;
      _floorareaController.text = widget.floorarea;
      _lotNumberController.text = widget.lot_number;
      _subdivisionController.text = widget.subdivision;
      _totalRoomController.text = widget.total_room;
      _carSpaceController.text = widget.car_space;
      _totalFloorController.text = widget.total_floor;
      _price.text = widget.price.toString();
      showroomImg = widget.showroom_img;
      property = widget.propertyID;

    }
    getIndoorFeatures();
    getOutdoorFeatures();
    super.initState();
  }
  Future getImage() async {
    final picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(pickedFile.path);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
        title: Text(MyApp.title),
    ),
    body: SingleChildScrollView(
    child: Container(
    child: Form(
      key: _formkey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: <Widget>[
              Text(
                'Edit your Property',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline3,
              ),
              SizedBox(height: 20.0),
              Text('Current Image '),
              SizedBox(height: 20.0),
              FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: "$showroomImg",
                  height: 250,
                  //
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth
              ),
              SizedBox(height: 20.0),
              Text('New Property Image'),

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
                decoration: InputDecoration(labelText: 'Description'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please enter a description";
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
                    return "Please enter a price";
                  }

                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Row(
                  children: [
                    Text('Property Status:'),
                    DropdownButton(
                        hint: Text('Please choose a user type'),
                        value: statusProperty,
                        onChanged: (newValue) {
                          setState(() {
                            statusProperty = newValue;
                            print(statusProperty);
                          });
                        },
                        items: _selectedUser.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList()),
                  ],
              ),

              SizedBox(height: 20.0),
              Text('Additional Information',textAlign: TextAlign.left,style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 20.0),
              TextFormField(

                controller: _bedrooms,
                decoration: InputDecoration(labelText: 'BedRooms'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please enter no. of bedroom";
                  }

                  return null;
                },
              ),

              SizedBox(height: 20.0),
              TextFormField(

                controller: _bathsController,
                decoration: InputDecoration(labelText: 'Baths'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please enter no. of baths";
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
              SizedBox(height: 10.0),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.blueAccent)),
                  onPressed: imageCloudinary,
                  child: Text(
                    'Update Property',
                    style: TextStyle(color: Colors.white),
                  ))
            ]
        ),
      ),
    )
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
  void updateProperty(cloudinaryUrl) async{

    if(statusProperty == 'Rented'){
      updateStatus = 1;

    }
    else{
      updateStatus = 0;
    }

    var data = {
      'title': _title.text,
      'description': _description.text,

      'status':updateStatus,
      'price':_price.text,
      'bedrooms':_bedrooms.text,
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
      'showroom_img': cloudinaryUrl,

    };

    if (_formkey.currentState.validate()) {
      var res = await CallApi().updateData(data, 'updateProperties/$property');

      var body = jsonDecode(res.body);
      print(body);
      if (body['success']) {



        _showMsg(body['message']);
        setState(() {
          Navigator.pop(context);

        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to  Update Property')),
        );
      }
      return;
    }
  }
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
        updateProperty(cloudinaryImage);
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property Image upload failed !')),
      );
    }
  }
}

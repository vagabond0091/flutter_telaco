// import 'dart:html';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class ProfileUpdate extends StatefulWidget {
  final String name;
  final String email;
  final String bday;
  final String contact;
  final String position;
  final String company;
  final String workPhone;
  final String avatarOriginal;
  final String avatar;
  final String workAddr;
  final String fbLinks;
  final String noOfPeople;
  final String relationship;
  final String reason;
  final String refFullName;
  final String refEmail;
  final String refContact;
  final String refRelationship;
  final String emerFullName;
  final String emerEmail;
  final String emerContact;
  final int id;
  final String role;
 final String emerRelationship;

  const ProfileUpdate(
      {
        Key key,
        this.role,
        this.name,
        this.email,
        this.bday,
        this.contact,
        this.noOfPeople,
        this.avatarOriginal,
        this.avatar,
        this.emerRelationship,
        this.emerEmail,
        this.emerContact,
        this.emerFullName,
        this.refRelationship,
        this.refContact,
        this.refEmail,
        this.refFullName,
        this.fbLinks,
        this.workPhone,
        this.company,
        this.position,
        this.reason,
        this.relationship,
        this.workAddr,
        this.id,
      }
  ) : super(key: key);

  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  TextEditingController _title = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _bday = TextEditingController();
  TextEditingController _contact = TextEditingController();
  TextEditingController noOfPeople = TextEditingController();
  TextEditingController reason = TextEditingController();
  TextEditingController relationship = TextEditingController();
  TextEditingController _fbLinks = TextEditingController();
  TextEditingController company = TextEditingController();
  TextEditingController position = TextEditingController();
  TextEditingController  workPhone = TextEditingController();
  TextEditingController workAddr = TextEditingController();
  TextEditingController refFullName = TextEditingController();
  TextEditingController refContact = TextEditingController();
  TextEditingController refRelationship = TextEditingController();
  TextEditingController refEmail = TextEditingController();
  TextEditingController emerFullName = TextEditingController();
  TextEditingController emerContact = TextEditingController();
  TextEditingController emerRelationship = TextEditingController();
  TextEditingController emerEmail = TextEditingController();
  int profile;
  String datePick;
  String cloudinaryImage;
  String role;
  bool isLoading = true;
  final _picker = ImagePicker();
  File imageFile;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),

    );
  }
  @override
  void initState() {
    if(widget.id != null){
      profile = widget.id;
      print(profile);
    }
    if(widget.role != null){
      role = widget.role;
      print(role);
    }



      if(widget.name != null && widget.email != null && widget.bday != null && widget.contact != null
          && widget.reason  != null && widget.noOfPeople != null && widget.relationship != null && widget.fbLinks != null
        && widget.company != null && widget.workPhone != null && widget.refFullName != null && widget.refContact != null && widget.refEmail != null
          && widget.refRelationship != null
      ){

        _title.text = widget.name;
        _email.text = widget.email;
        _bday.text = widget.bday;
        _contact.text = widget.contact;
        noOfPeople.text = widget.noOfPeople;
        reason.text = widget.reason;
        relationship.text = widget.relationship;
        _fbLinks.text = widget.fbLinks;
        company.text = widget.company;
        workAddr.text = widget.workAddr;
        position.text = widget.position;
        workPhone.text = widget.workPhone;
        refFullName.text = widget.refFullName;
        refContact.text = widget.refContact;
        refRelationship.text = widget.refRelationship;
        refEmail.text = widget.refEmail;

        emerFullName.text = widget.emerFullName;
        emerContact.text = widget.emerContact;
        emerRelationship.text = widget.emerRelationship;
        emerEmail.text = widget.emerEmail;
      }

    super.initState();
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
      appBar: AppBar(
        title: Text(MyApp.title),

      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left:8.0,right: 8.0),
          child: Container(
            child: Form(
                key: _formkey,
              child: Column(
                children: [


                  Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Container(

                        width: 200,
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
                    label: Text('Update Profile Image'),
                    onPressed: getImage,
                  ),
                  SizedBox(height: 20.0),
                  Center(child: Text('Personal Information',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),

                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: _bday,
                    decoration: InputDecoration(labelText: 'Birthdate'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter birthday";
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
                      _bday.text =DateFormat('yyyy-MM-dd').format(DateTime.parse(data));

                    }
                  ),
                  // SizedBox(height: 20.0),
                  // TextFormField(
                  //
                  //   controller: _contact,
                  //   decoration: InputDecoration(labelText: 'Contact'),
                  //   validator: (String value) {
                  //     if (value.isEmpty) {
                  //       return "Please enter contact number";
                  //     }
                  //
                  //     return null;
                  //   },
                  // ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: _fbLinks,
                    decoration: InputDecoration(labelText: 'Fb Links'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter fb link";
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 30.0),
                  Center(child: Text('Employee Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                  SizedBox(height: 30.0),
                  TextFormField(

                    controller: position,
                    decoration: InputDecoration(labelText: 'Position'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter position";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(

                    controller: company,
                    decoration: InputDecoration(labelText: 'Company'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter position";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(

                    controller: workAddr,
                    decoration: InputDecoration(labelText: 'Work Address'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter position";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(

                    controller: workPhone,
                    decoration: InputDecoration(labelText: 'Work Phone'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter position";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  Center(child: Text('Get To Know Me More',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                  SizedBox(height: 20.0),
                  Container(
                    child: role != 'landlord' ? TextFormField(

                      controller: reason,
                      decoration: InputDecoration(labelText: 'Why Are you moving? '),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Please enter contact number";
                        }

                        return null;
                      },
                    ) : Text(''),
                  ),

                  SizedBox(height: 20.0),
                  Container(
                    child: role != 'landlord' ?  TextFormField(

                      controller: noOfPeople,
                      decoration: InputDecoration(labelText: 'Number of people moving-in?'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Please enter no of people";
                        }

                        return null;
                      },
                    ) : Text(''),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    child: role != 'landlord' ?  TextFormField(

                      controller: relationship,
                      decoration: InputDecoration(labelText: 'Relationship between you and other people included?'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Please enter no of people";
                        }

                        return null;
                      },
                    ) : Text(''),
                  ),
                  SizedBox(height: 30.0),
                  Center(child: Text('References',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: refFullName,
                    decoration: InputDecoration(labelText: 'Reference Full Name '),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter full name ";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: refEmail,
                    decoration: InputDecoration(labelText: 'Reference Email'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter email";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: refContact,
                    decoration: InputDecoration(labelText: 'Reference Contact'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter reference contact";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: refRelationship,
                    decoration: InputDecoration(labelText: 'Reference Relationship'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter reference relationship";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  Center(child: Text('Emergency Contact',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: emerFullName,
                    decoration: InputDecoration(labelText: 'Emergency Full Name'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter Emergency Full Name";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: emerContact,
                    decoration: InputDecoration(labelText: 'Emergency Contact'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter Emergency Contact";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: emerEmail,
                    decoration: InputDecoration(labelText: 'Emergency Email'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter Emergency Email";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(

                    controller: emerRelationship,
                    decoration: InputDecoration(labelText: 'Emergency Relationship'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter Emergency Relationship";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: isLoading == true ? Text('Save') : Text('Saving...'),
                          onPressed: (){
                            setState(() {
                              isLoading = false;
                            });
                            uploadProfile();
                          },
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Cancel'),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      )
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
  void uploadProfile(){
    String realImg = "data:image/png;base64,";
    String image = imageFile == null ? null : getStringImage(imageFile);
    String img;

    if(image != null){
      img =realImg + image;
      uploadProfileImage(img);
    }
    else{
      img ='';
    }
  }
  void profileUpdate(id,cloudinaryUrl) async{
    String reasonOfRenting;
    String noOfpeople;
    String relation;
    if(role == 'landlord'){
      reasonOfRenting = 'N/A';
      noOfpeople = 'N/A';
      relation = 'N/A';
    }
    else{
      reasonOfRenting = reason.text;
      noOfpeople = noOfPeople.text;
      relation = relationship.text;
      print(relation);
      print(noOfpeople);
      print(reasonOfRenting);
    }
    var data = {
      'position':position.text,
      'company':company.text,
      'company_addr':workAddr.text,
      'company_phone': workPhone.text,
      'birthdate': _bday.text,
      'fb_links': _fbLinks.text,
      'reason': reasonOfRenting,
      'num_of_people':noOfpeople,
      'relationship':relation,
      'avatar_original': cloudinaryUrl,
      'ref_fullname': refFullName.text,
      'ref_email':refEmail.text,
      'ref_contact':refContact.text,
      'ref_relationship':refRelationship.text,

      'profile_id': id,
      'emer_fullname':emerFullName.text,
      'emer_email':emerEmail.text,
      'emer_contact':emerContact.text,
      'emer_relationship':emerRelationship.text,



    };
    print(id);
    if (_formkey.currentState.validate()) {
      var res = await CallApi().updateData(data, 'updatedProfile/user=$id');

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
    }

  }
  void uploadProfileImage(profileImage) async{
    var data = {
      'showroom_img':profileImage,
    };
    var res = await CallApi().postData(data, 'uploadImage');

    var body = jsonDecode(res.body);

    Map<String, dynamic> imageMapping = Map<String, dynamic>.from(body);
    if (body['success']) {
      setState(() {
        cloudinaryImage = imageMapping['data_url']['secure_url'];
        profileUpdate(profile,cloudinaryImage);
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property Image upload failed !')),
      );
    }
  }
}

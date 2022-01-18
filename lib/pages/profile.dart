import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/pages/profileUpdate.dart';

import '../main.dart';

class Profile extends StatefulWidget {
  final int userInfo;
  final String role;
  const Profile({
    Key key,this.userInfo,
    this.role,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userData;
  var data;
  var bday;
  var contact;
  var position;
  var company;
  var workPhone;
  var avatarOriginal;
  var avatar;
  var workAddr;
  var fbLinks;
  var noOfPeople;
  var relationship;
  var reason;
  var refFullName;
  var refEmail;
  var refContact;
  var refRelationship;
  var emerFullName;
  var emerEmail;
  var emerContact;
  var emerRelationship;
  var profileId;
  String role;

  // int userID;
  @override
  void initState() {
      if(widget.role != null){
        role = widget.role;

      }
    super.initState();
    _getUserInfo(widget.userInfo);

  }
  Future<void> _getUserInfo(id) async {

    var res = await CallApi().getData('getLoginUser/user=$id}');
    var userInfo = jsonDecode(res.body);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(userInfo);
    setState(() {

      userData = myMap['data'];



      if(userData['birthdate'] == null && userData['id'] != null && userData['position']  == null && userData['company_phone'] == null && userData['company_addr'] == null
           && userData['fb_links'] == null &&  userData['reason'] == null &&  userData['num_of_people'] == null
           &&  userData['relationship'] == null  ){
          bday = userData['birthdate'];

          profileId = userData['id'];

          // contact = userData['user']['contact'];
          position = userData['position'];
          company = userData['company'];
          workPhone = userData['company_phone'];
          workAddr = userData['company_addr'];
          fbLinks = userData['fb_links'];
          reason = userData['reason'];
          relationship = userData['relationship'];
          noOfPeople = userData['num_of_people'];
          // print(noOfPeople);


       }
      else{
        bday = userData['birthdate'];

        profileId = userData['id'];

        // contact = userData['user']['contact'];
        position = userData['position'];
        company = userData['company'];
        workPhone = userData['company_phone'];
        workAddr = userData['company_addr'];
        fbLinks = userData['fb_links'];
        reason = userData['reason'];
        relationship = userData['relationship'];
        noOfPeople = userData['num_of_people'];
      }
       if( userData['company_phone'] != null){
         contact =  userData['company_phone'];
       }
       if(userData['user']['avatar_original'] != null){

         avatarOriginal = "${userData['user']['avatar_original']}";
        print(avatarOriginal);
       }
       else{
         avatar = userData['user']['avatar'];
       }

       if(userData['references'].isEmpty){
         refFullName = 'N/A';
         refEmail = 'N/A';
         refContact ='N/A';
         refRelationship = 'N/A';

       }
       else{

         refFullName = userData['references'][0]['ref_fullname'];
         refEmail = userData['references'][0]['ref_email'];
         refContact = userData['references'][0]['ref_contact'];
         refRelationship = userData['references'][0]['ref_relationship'];
       }
      if(userData['emergency'].isEmpty){
        emerFullName = 'N/A';
        emerEmail = 'N/A';
        emerContact = 'N/A';
        emerRelationship = 'N/A';

      }
      else{
        emerFullName = userData['emergency'][0]['emer_fullname'];
        emerEmail = userData['emergency'][0]['emer_email'];
        emerContact = userData['emergency'][0]['emer_contact'];
        emerRelationship = userData['emergency'][0]['emer_relationship'];

      }



    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),

      ),
      body: RefreshIndicator(
        onRefresh: (){
          return _getUserInfo(widget.userInfo);
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(emerRelationship),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(avatarOriginal != null ? "$avatarOriginal" : "$avatar",),
                          fit: BoxFit.fill
                      ),
                    ),
                  ),

                  ],
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 20.0),
                    Center(child: Text('Personal Information',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),


                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                          Expanded(child: Row(
                            children: [

                              Expanded(child: Text(userData != null ? 'Full Name: ${userData['user']['name']} ': '')),
                              SizedBox(width: 30.0),
                            ],
                          )),

                         Expanded(
                             child:Row(
                               children: [
                                 Icon(Icons.email),
                                 SizedBox(width: 10.0),
                                 Expanded(child: Text(userData!= null ? '${userData['user']['email']} ' :'')),
                               ],
                             )
                         ),

                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded),
                              SizedBox(width: 10.0),
                              Text(bday != null ? 'Birthdate: $bday' : 'Birthdate: N/A'),

                            ],
                          ),
                        ),

                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.phone),
                              SizedBox(width: 10.0),
                              Text(contact != null ? 'Contact: $contact ': 'Contact: N/A'),
                            ],
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 30.0),
                    Center(child: Text('Employment  Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [
                            Icon(Icons.work),
                            SizedBox(width: 10.0),
                            Text('Position / Company'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [
                            Icon(Icons.phone),
                            SizedBox(width: 10.0),
                            Text('Work Phone'),

                          ],
                        )),





                      ],
                    ),
                    SizedBox(
                      height: 10.0
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [

                            SizedBox(width: 35.0),
                            Expanded(child: Text(position != null ? '$position / $company ': 'N/A')),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [
                            SizedBox(width: 35.0),
                            Text(workPhone != null ? '$workPhone': 'N/A'),

                          ],
                        )),






                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [
                            Icon(CupertinoIcons.location),
                            SizedBox(width: 10.0),
                            Text('Work Address'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [
                            Icon(Icons.face_outlined),
                            SizedBox(width: 10.0),
                            Text('Facebook Link'),

                          ],
                        )),






                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [

                            SizedBox(width: 35.0),
                            Text(workAddr != null ? '$workAddr ': 'N/A'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [

                            SizedBox(width: 35.0),
                            Expanded(child: Text(fbLinks != null ? '$fbLinks ': 'N/A')),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 30.0),
                    Center(child: Text('Get To Know Me More',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text('Why are you moving?'),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [
                            Text(reason != null ? '$reason ': 'N/A'),
                          ],
                        )),








                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text('Number of people moving in?'),

                          ],
                        )),








                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(noOfPeople != null ? '$noOfPeople ': 'N/A'),

                          ],
                        )),








                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text('Relationship between you and other people included?'),

                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(relationship != null ? '$relationship ': 'N/A'),

                          ],
                        )),








                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(child: Text('References',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(refFullName != null ? 'Full Name: $refFullName' : 'Full Name: N/A'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [


                            Text(refEmail != null ? 'Email: $refEmail' : 'Email: N/A'),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(refContact != null ? 'Contact: $refContact' : 'Contact: N/A'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [


                            Text(refRelationship != null ? 'Relationship: $refRelationship' : 'Relationship: N/A'),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 30.0),
                    Center(child: Text('Emergency',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21.0))),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(emerFullName != null ? 'Full Name: $emerFullName' : 'Full Name: N/A'),

                          ],
                        )),
                        Expanded(child: Row(
                          children: [


                            Text(emerEmail != null ? 'Email: $emerEmail' : 'Email: N/A'),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(child: Row(
                          children: [


                            Text(emerContact != null ? 'Contact: $emerContact' : 'Contact: N/A'),
                          ],
                        )),
                        Expanded(child: Row(
                          children: [


                            Text(emerRelationship != null ? 'Relationship: $emerRelationship' : 'Relationship: N/A'),

                          ],
                        )),







                      ],
                    ),
                    SizedBox(height: 40.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [


                             SizedBox(
                              width: 250.0,
                              child: ElevatedButton(

                                onPressed: (){
                                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                                  new ProfileUpdate(name: userData['user']['name'],email: userData['user']['email'],
                                    emerContact: emerContact,emerEmail: emerEmail,emerFullName: emerFullName,emerRelationship: emerRelationship,
                                    avatar: avatar,avatarOriginal: avatarOriginal,workAddr: workAddr,workPhone: workPhone,bday: bday,company: company,
                                      contact: contact,noOfPeople: noOfPeople,reason: reason,relationship: relationship,refContact: refContact,refEmail: refEmail,
                                  refFullName: refFullName,refRelationship: refRelationship,fbLinks: fbLinks,position: position, id:profileId,role: role),
                                  );
                                  Navigator.of(context).push(route);
                                },
                               child:Text('Update Profile ')
                              ),
                            ),



                      ],
                    ),
                    SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

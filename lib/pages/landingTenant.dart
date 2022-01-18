import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_telaco/api/api.dart';
import 'package:flutter_telaco/api/googleSignInApi.dart';
import 'package:flutter_telaco/pages/inquiryTenant.dart';
import 'package:flutter_telaco/pages/profile.dart';
import 'package:flutter_telaco/pages/search.dart';
import 'package:flutter_telaco/pages/viewCalendar.dart';
import 'package:intl/intl.dart';
import 'package:rating_dialog/rating_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:transparent_image/transparent_image.dart';
import '../main.dart';
import 'bookmarked.dart';
import 'home.dart';
import 'maintenanceTenant.dart';
import 'messageTenant.dart';
import 'notification.dart';
import 'overviewProperty.dart';

class TenantDashboard extends StatefulWidget {
  @override
  _TenantDashboardState createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  var userData;

  var userClicked;
  var id;
  var userId;
  var tenantData;
  var role;
  bool popUpRatings;
  List listOfProperty = [];
  List propertyBookmarked = [];
  List isBookmarked = [];
  var propertyName;
  var propertyId;
  int notifCount;
  String providerId;
  Timer  timer;
  bool loading = false;
  bool isLoading = true;
  String content = '';
  final formatCurrency = new NumberFormat.currency(locale: "en_US",symbol: "₱");
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    _getUserInfo();
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
  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    print('Landing Tenant');
    print(userJson);

    var user = jsonDecode(userJson);
    
    setState(() {
      userData = user;

      providerId = userData['provider_id'];
      userId = userData['id'];
      print(userId);
      role = userData['user_type'];


      tenant(userId);
      getAllNotifications(userId);
    });
  }
  void tenant(id) async{
    var res = await CallApi().getData('tenant/$id');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);

    var dataTenant = myMap['data']['id'];

    var response = await CallApi().getData('collections/$dataTenant');
    var body = jsonDecode(response.body);

    Map<String, dynamic> bookmarkMap = Map<String, dynamic>.from(body);
    if(body['success']){
      setState(() {
        tenantData = dataTenant;
        propertyBookmarked = bookmarkMap['bookmarked'];

        propertyBookmarked.forEach((item) {
          isBookmarked.add(item['property_id']);
        });
        getReviewsByTenant();
        _property();

      });
    }

  }
  void getAllNotifications(id) async{
    var res = await CallApi().getData('getAllNotificationPerTenant/$id');
    var items = jsonDecode(res.body);
    setState(() {
      notifCount = items['notif_count'];
    });

  }
  void getReviewsByTenant() async {
    var response = await CallApi().getData('getReviewByTenant/$tenantData');
    var body = jsonDecode(response.body);
    Map<String, dynamic> propertyMap = Map<String, dynamic>.from(body);

     propertyName = propertyMap['property'][0]['title'];
     propertyId = propertyMap['property'][0]['id'];
    if(body['data'].isEmpty){
      popUpRatings = true;

    }
    else{
      popUpRatings = false;

    }
  }

void _ratingReviews()  {
  final _dialog = RatingDialog(
    // your app's name?
    title: 'Ratings and Reviews',
    // encourage your user to leave a high rating?
    message:
    'Please write your Ratings and Reviews to your current property: ${propertyName != null ? propertyName.toUpperCase() : ''}',
    // your app's logo?
    // image: const FlutterLogo(size: 100),
    submitButton: 'Submit',
    onCancelled: () => print('cancelled'),
    onSubmitted: (response) {
      // print('rating: ${response.rating}, comment: ${response.comment}');
      if(popUpRatings){
        createRatingsAndReviews(response.comment,response.rating);
        setState(() {
          popUpRatings = false;
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to  Create Reviews ')));
      }



    },

  );
  showDialog(
    context: context,
    builder: (context) => _dialog,
  );
}
void createRatingsAndReviews(comment,rating) async{

   var data = {
     'tenant_id': tenantData,
     'property_id':propertyId ,
     'comment': comment,
     'ratings':rating,
   };
   var res = await CallApi().postData(data, 'createRatings');

   var body = jsonDecode(res.body);

   if (body['success']) {
     _showMsg(body['message']);


   }
   else {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Unable to  Create Reviews ')),
     );
   }
 }
 Future<void> _property() async {
    var res = await CallApi().getData('collections/$tenantData');
    var items = jsonDecode(res.body);

    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      listOfProperty = myMap['property'];



    });
    loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    color: Colors.deepOrange,
                  ),
                  child: Center(
                    child: Text(
                      userData != null ? 'Welcome ! ${userData['name']}  ' : '',
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                  )),
            ),
            ListTile(
              leading: Icon(Icons.house,color: Colors.deepOrange[600]),
              title: const Text('Property'),
              onTap: () {

              },
            ),
            ListTile(
                leading: Icon(Icons.message,color: Colors.deepOrange[600]),
                title:  Text('Message'),
                onTap: (){
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new MessageTenantScreen(userInfo: userId),
                  );
                  Navigator.of(context).push(route);
                }),
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
              leading: Icon(Icons.calendar_today_rounded,color: Colors.deepOrange[600]),
              title: const Text('Calendar'),
              onTap: () {
                var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                new ViewCalendar(user: userId),
                );
                Navigator.of(context).push(route);
              },
            ),
            ListTile(
              leading: Icon(Icons.apartment_sharp,color: Colors.deepOrange[600]),
              title: const Text('Inquiries'),
              onTap: () {
                var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                new InquiryTenant(user: userId),
                );
                Navigator.of(context).push(route);
                },
            ),
            ListTile(
              leading: Icon(Icons.handyman,color: Colors.deepOrange[600]),
              title: const Text('Maintenance Request'),
              onTap: () {
                var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                new MaintenanceRequest(user: userId),
                );
                Navigator.of(context).push(route);
              },
            ),
            ListTile(
                leading: Icon(Icons.person_outline_rounded ,color: Colors.deepOrange[600]),
                title:  Text('Profile '),
                onTap: (){
                  var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                  new Profile(userInfo: userId,role:role),
                  );
                  Navigator.of(context).push(route);
                }),
            ListTile(
              leading: Icon(CupertinoIcons.heart_fill,color: Colors.deepOrange[600]),
              title: const Text('Bookmarked'),
              onTap: () {
                var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                new Bookmarked(user: userId),
                );
                Navigator.of(context).push(route);
              },
            ),

            ListTile(
              leading: Icon(Icons.exit_to_app,color: Colors.deepOrange[600]),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: getGrid(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent[800],

        onPressed: _ratingReviews, child: Icon(Icons.star,color: Colors.amberAccent,size: 40.0,),
      ),
    );
  }

  void logout() async {
    var res = await CallApi().getData('mobile/logout');
    var body = jsonDecode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      print(providerId);
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


  Widget getGrid() {
    return RefreshIndicator(
      onRefresh: (){
        return _property();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Form(
              key: _formkey,
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(hintText: 'Search a city',suffixIcon: IconButton(
                  icon:  Icon(Icons.search,color: Colors.deepOrange[800],size: 35.0,),

                  onPressed: (){

                    if(_searchController.text != ""){
                      var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                      new Search(searchData: _searchController.text,tenant: tenantData),
                      );
                      Navigator.of(context).push(route);
                    }
                    else{
                      showTopSnackBar(
                        context,
                        CustomSnackBar.info(
                          message:
                          "Please enter a city",
                        ),
                      );

                    }

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
                  _searchController.text = value;
                  if (value.isEmpty) {
                    return 'Please enter city name';
                  }
                  return null;
                },
              ),
            )

          ),
          Expanded(
              child: loading != false ? Container(

            child: StaggeredGridView.countBuilder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                crossAxisCount: 1,
                itemCount: listOfProperty.length,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemBuilder: (context, index) {
                  int id = listOfProperty[index]['id'];
                  bool isSaved = isBookmarked.contains(id);
                  return Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[


                      Card(
                        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                        child: Column(children: <Widget>[
                          Row(

                        mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                            children:[
                              IconButton(icon:  Icon( isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,size: 30.0,color: Colors.deepOrange[600]),
                                onPressed: (){
                                  // bookmarked(listOfProperty[index]['id']);

                                  setState(() {
                                    if(isSaved){
                                      deleteBookmark(listOfProperty[index]['id']);
                                      isBookmarked.remove(listOfProperty[index]['id']);

                                    }
                                    else{
                                      bookmarked(listOfProperty[index]['id']);
                                      isBookmarked.add(listOfProperty[index]['id']);

                                    }


                                  });
                                },
                              ),

                            ],
                          ),
                          FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: "${listOfProperty[index]['showroom_img']}",
                              height: 250,
                              //
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fitWidth
                          ),

                          SizedBox(height: 20.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home,size: 18.0,color: Colors.deepOrange[600]),
                            SizedBox(width: 17.0),
                            Text('${listOfProperty[index]['title']}'),
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
                                child:   Text('${formatCurrency.format(listOfProperty[index]['price'])}',
                                ),

                              )
                            ],
                          ),
                          SizedBox(height: 20.0),
                         Row(
                           children: [
                             Icon(Icons.location_city,size: 18.0,color: Colors.deepOrange[600]),
                             SizedBox(width: 17.0),
                             Text('${listOfProperty[index]['address']+ ' Brgy.'+listOfProperty[index]['barangay']+' City '+listOfProperty[index]['city']}'),
                           ],
                         ),
                          SizedBox(height: 30.0),
                          TextButton(
                            style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.deepOrange)),
                          onPressed: () async {
                            var route  = new MaterialPageRoute(builder: (BuildContext context) =>
                            new OverviewProperty(title:listOfProperty[index]['title'],description: listOfProperty[index]['description'],
                              addr:listOfProperty[index]['address'],city:listOfProperty[index]['city'],brgy:listOfProperty[index]['barangay'],
                              image:listOfProperty[index]['showroom_img'],landlord:listOfProperty[index]['landlord_id'],property:listOfProperty[index]['id'],
                                price:listOfProperty[index]['price'], lat:listOfProperty[index]['latitude'],lng:listOfProperty[index]['longtitude'],tenant: userId,


                            ),

                            );
                            Navigator.of(context).push(route);
                                    },
                            child: Text(
                            'View Property',
                            style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 30.0),
                        ]),
                      ),
                    ],
                  ));
                },
                staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
          )
              : Center(
                  child:
                  isLoading != false ? SpinKitDoubleBounce(
                  size: 80.0,
                  color: Colors.deepOrange[800],
                  ) :Text(''))),

        ],
      ),
    );
  }


void bookmarked(propertyId) async{
    var data = {
      'tenant_id': tenantData,
      'property_id':propertyId ,
    };
  var res = await CallApi().postData(data, 'isBookmarked');

  var body = jsonDecode(res.body);

    if (body['success']) {
      _showMsg(body['message']);

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Update Property')),
      );
    }
}
void deleteBookmark(id) async{

    var res = await CallApi().deleteData( 'mobileBookmarkDestroy/$id');

    var body = jsonDecode(res.body);

    if (body['success']) {
      _showMsg(body['message']);


    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to  Update Property')),
      );
    }
  }

}

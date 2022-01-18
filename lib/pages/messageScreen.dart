import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter_telaco/api/api.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  final int myId;
  final int recieverId;
  final String recieverName;
  final String avatarOriginal;
  final String avatar;
  const MessageScreen({
    Key key,
    this.myId,
    this.recieverId,
    this.recieverName,
    this.avatarOriginal,
    this.avatar,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List messages = [];
  List realTimeMessage = [];
  int myUserId;
  int userReceiverId;
  String receiverProfile;
  String receiverProfileOriginal;
  String senderProfile;
  String senderProfileOriginal;
  var messageFrom;
  int senderId;
  int receiverId;
  bool loading = false;
  final _scrollController =  ScrollController(
    // initialScrollOffset: 0.0,
    // keepScrollOffset: true,
  );
  TextEditingController _message = TextEditingController();
  Channel _channel;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
void scrollToBottom() {
  final double end = _scrollController.position.maxScrollExtent;
  _scrollController.animateTo(end, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
}
  void initialscrollToBottom() {
    final double end = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(end);
  }
  @override
  void initState() {
    if(widget.myId != null  && widget.recieverId != null){
      myUserId = widget.myId;

      userReceiverId = widget.recieverId;
      print(userReceiverId);
      print(myUserId);

    }

    getAllMessages();
    _initPusher();

    super.initState();

  }

  void getAllMessages() async{
    var res = await CallApi().getData('getMessages/$userReceiverId/$myUserId');
    print(userReceiverId);
    print(myUserId);
    var items = jsonDecode(res.body);
    print(items['messages']);
    Map<String, dynamic> myMap = Map<String, dynamic>.from(items);
    setState(() {
      messages = myMap['data'];

      if(myMap['sender']['avatar_original'] != null){
        receiverProfileOriginal = myMap['sender']['avatar_original'];
      }
      else{
        receiverProfile = myMap['sender']['avatar'];

      }
      loading = true;


    });
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initialscrollToBottom());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
          child: Row(

            children: [
              Container(
                width: 45,
                height: 45,
                decoration:BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image:NetworkImage(widget.avatarOriginal != null ? '${widget.avatarOriginal}':'${widget.avatar}')
                      ,   fit: BoxFit.fill
                  ),
                ) ,
              ),
              SizedBox(width: 15.0),
              Text(widget.recieverName),
            ],
          ),
        ),

      ),
      body: messageContainer(),
      bottomNavigationBar:BottomAppBar(
        child:    bottomChatArea(),
        elevation: 0,
      )

    );
  }
  Widget messageContainer(){
    return loading ? SingleChildScrollView(

      physics: ScrollPhysics(),
      controller: _scrollController,
      child: Column(

        children: [
          ListView.builder(
              itemCount: messages.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,

              itemBuilder: (context,index){
                return Column(
                  children: [
                    Container(
                      child: widget.myId == messages[index]['from'] ?   Padding(
                        padding: const EdgeInsets.only(top:20.0),
                        child: Column(

                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(receiverProfileOriginal != null ? '$receiverProfileOriginal':'$receiverProfile')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                ),
                                SizedBox(
                                  width: 250,

                                  child: Card(
                                    color: Colors.blueAccent,
                                    child: Row(

                                      children: [


                                        SizedBox(width: 20.0),
                                        Expanded(
                                        child:Padding(
                                          padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                          child: Text(messages[index]['message'],style: TextStyle(
                                            color: Colors.white,
                                          ),),
                                        ),
                                        ),

                                      ],
                                    ) ,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 245.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                      child: Text('${DateFormat('dd MMMM y  ').format(DateTime.tryParse(messages[index]['created_at']))}'),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ): Padding(
                        padding: const EdgeInsets.only(left:12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(widget.avatarOriginal != null ? '${widget.avatarOriginal}':'${widget.avatar}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                ),
                                SizedBox(
                                  width: 250,

                                  child: Card(

                                    child: Row(

                                      children: [


                                        SizedBox(width: 20.0),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                            child: Text(messages[index]['message']),
                                          ),
                                        ),

                                      ],
                                    ) ,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 290.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                      child: Text('${DateFormat('dd MMMM y  ').format(DateTime.tryParse(messages[index]['created_at']))}'),
                                    )),
                              ],
                            ),

                          ],
                        ),
                      ),

                    ),


                  ],
                );

              }
          ),
          ListView.builder(
              itemCount: realTimeMessage.length + 1,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              reverse: false,

              itemBuilder: (context,index){

                print(index);
                print(realTimeMessage.length);

                print(realTimeMessage);
                if(index == realTimeMessage.length){
                  return Container(
                    height: 70,
                  );
                }
                return Column(
                  children: [
                    Container(
                      child: myUserId.toString() == realTimeMessage[index]['from'] ?
                      Padding(
                        padding: const EdgeInsets.only(top:20.0),
                        child: Column(

                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(receiverProfileOriginal != null ? '$receiverProfileOriginal':'$receiverProfile')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ) ,
                                ),
                                SizedBox(
                                  width: 250,

                                  child: Card(
                                    color: Colors.blueAccent,
                                    child: Row(

                                      children: [


                                        SizedBox(width: 20.0),
                                        Expanded(
                                        child:Padding(
                                          padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                          child: Text(realTimeMessage[index]['message'],style: TextStyle(
                                            color: Colors.white,
                                          ),),
                                        ),
                                        ),

                                      ],
                                    ) ,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 245.0,
                                    child: Text('${realTimeMessage[index]['created_at']}')),
                              ],
                            ),
                          ],
                        ),
                      ): Padding(
                        padding: const EdgeInsets.only(top:20.0,left:12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:NetworkImage(widget.avatarOriginal != null ? '${widget.avatarOriginal}':'${widget.avatar}')
                                        ,   fit: BoxFit.fill
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                    child: Card(
                                      child: Row(
                                        children: [
                                          SizedBox(width: 20.0),
                                          Expanded(
                                            child:Padding(
                                              padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                                              child: Text('${realTimeMessage[index]['message']}',style: TextStyle(

                                              ),),
                                            ),
                                          ),
                                        ],
                                      ),

                                    ),
                                ),
                                // Text('${realTimeMessage[index]['message']}')
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 290.0,
                                    child: Text('${realTimeMessage[index]['created_at']}')),
                              ],
                            ),
                          ],
                        ),
                      )


                    ),


                  ],
                );

              }
          ),
        ],
      ),
    ) : Center(
      child: SpinKitDoubleBounce(
        size: 80.0,
        color: Colors.deepOrange[800],
      ),
    );
  }
  Widget bottomChatArea(){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          chatTextArea(),
          IconButton(icon: Icon(Icons.send),
              onPressed:(){
                sendMessage();


              }
          )
        ],
      ),
    );
  }
  void sendMessage() async{
    var data = {
      'from': widget.myId,
      'to': widget.recieverId,
      'message': _message.text,
      'user_id': widget.myId,

    };
    if (_formkey.currentState.validate()) {
      var res = await CallApi().postData(data, 'sendMessage');
      var items = jsonDecode(res.body);

      if (items['success']) {
        scrollToBottom();
        _message.clear();
      }
      else {
        _showMsg(items['message']);
      }
    }
    return;
  }
  Widget chatTextArea() {
    return Expanded(
        child: Form(
          key: _formkey,
          child: TextFormField(
            controller: _message,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
                focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
                ),
              filled: true,
              fillColor: Colors.white60,
              contentPadding: EdgeInsets.all(10.0),
              hintText: 'Type your message here... ',
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return "Please enter email";
              }
              return null;
            }
          ),
        )
    );
  }
  Future<void> _initPusher() async{
    try{
        await Pusher.init('d26ddde02d2c931d7e03',PusherOptions(cluster: 'ap1'));
    }
    catch(e){
      print(e);
    }

  //  pusher connection
    Pusher.connect(
      onConnectionStateChange: (val){
        print(val.currentState);
      },
      onError: (err){
        print(err.message);
    });

  //  pusher subscribe
    _channel = await Pusher.subscribe('chat');


  //  bind
    _channel.bind('NewChatMessage', (onEvent) {
        if(mounted){
          final data =  json.decode(onEvent.data);

         setState(() {

           realTimeMessage.add({
              'message':data['message'],
              'from':data['from'].toString(),
             'to':data['to'].toString(),
             'created_at':DateFormat('d MMMM y').format(DateTime.now()),

           });




         });

        }
    });

  }
}

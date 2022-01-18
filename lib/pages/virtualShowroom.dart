import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:transparent_image/transparent_image.dart';

import '../main.dart';

class VirtualShowroom extends StatefulWidget {
  final String showroomImage;
  const VirtualShowroom(
      {Key key,this.showroomImage,
      }
      ) : super(key: key);

  @override
  _VirtualShowroomState createState() => _VirtualShowroomState();
}

class _VirtualShowroomState extends State<VirtualShowroom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text( MyApp.title),
        ),
      body:  Panorama(
        child: Image.network(widget.showroomImage != null ? "${widget.showroomImage}" : '')
      ),
    );

  }
}

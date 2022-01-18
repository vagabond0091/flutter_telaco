import 'package:flutter/material.dart';

class CalendarPopup extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(

      child: AlertDialog(
        title: Text('this'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
      ),
    );
  }
}



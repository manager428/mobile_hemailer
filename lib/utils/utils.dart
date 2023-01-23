import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showSuccessToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}
void showOnlineChatAnother(String msg){
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIos: 1,
      backgroundColor: Color.fromRGBO(0, 200, 0, 0.8),
      textColor: Colors.black,
      fontSize: 16.0);
}

TextStyle normalStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

TextStyle cardHeaderStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);

String baseURL = "http://192.168.110.62/";
String onlineSocketURI = "ws://192.168.110.62:8090/AgentChatServer";
String chatSocketURI = "ws://192.168.110.62:8080/ChatServer";

// String baseURL = "https://hemailer.com/";
// String onlineSocketURI = "wss://www.hemailer.com/agentsocket/AgentChatServer";
// String chatSocketURI = "wss://www.hemailer.com/websocket/ChatServer";

enum ConfirmAction { CANCEL, YES }
Future<ConfirmAction> confirmDialog(
    BuildContext context, title, content) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$title'),
        content: Text('$content'),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('YES'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.YES);
            },
          )
        ],
      );
    },
  );
}

Future<List<String>> customFieldDialog(
    BuildContext context, String content, String linkUrl) async {
  List<String> customField = List<String>();
  customField.add(content);
  customField.add(linkUrl);
  TextEditingController _txtContent = new TextEditingController();
  TextEditingController _txtLinkUrl = new TextEditingController();
  _txtContent.text = content;
  _txtLinkUrl.text = linkUrl;

  return showDialog<List<String>>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Custom Field On'),
        content: Column(
          children: <Widget>[
            Expanded(
                child: new TextField(
              controller: _txtContent,
              autofocus: true,
              decoration: new InputDecoration(labelText: 'Content'),
            )),
            Expanded(
                child: new TextField(
              controller: _txtLinkUrl,
              autofocus: true,
              decoration: new InputDecoration(labelText: 'Link Url'),
            ))
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop(customField);
            },
          ),
          FlatButton(
            child: const Text('OK'),
            onPressed: () {
              customField.clear();
              customField.add(_txtContent.text);
              customField.add(_txtLinkUrl.text);
              Navigator.of(context).pop(customField);
            },
          )
        ],
      );
    },
  );
}

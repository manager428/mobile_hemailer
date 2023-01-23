import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


class ChatHistoryScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic clientInfo;
  ChatHistoryScreen({Key key, @required this.userInfo, this.clientInfo})
      : super(key: key);
  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  TextEditingController _txtMsg = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  List<dynamic> allChatMsg = new List<dynamic>();
  bool _progressBarActive = false;
  int msgCount = 0;
  var filePath;
  bool _attachExist = false;
  String attachFileName = "";
  bool _bWriting = false;
  bool _bOnline = false;
  var previousMsgAt;
  var recentMsg;
  final dbRef = FirebaseDatabase.instance.reference();
  DatabaseReference chatRef;

  @override
  void initState() {
    super.initState();
    previousMsgAt = new DateTime.now().subtract(Duration(hours: 10));
    setState(() {
      _bOnline = widget.clientInfo["online"];
    });
    chatRef = dbRef.child("TEAMCHAT").child(widget.userInfo.parentID);
    chatRef.orderByChild("timestamp").onChildAdded.listen((Event event) {
      var oneMsg = event.snapshot.value;
      if (oneMsg != null) {
        if (mounted) {
          setState(() {
            if ((widget.clientInfo["id"] == oneMsg["sender_id"] &&
                    oneMsg["receiver_id"] == widget.userInfo.id) ||
                widget.clientInfo["id"] == oneMsg["receiver_id"] &&
                    oneMsg["sender_id"] == widget.userInfo.id) {
              var calTime =
                  localTime(oneMsg["created_at"]);
              oneMsg["created_at"] = calTime.toLocal().toString().substring(0, 16);
              allChatMsg.add(oneMsg);
              msgCount++;
            }
          });
        }
      }
    });
    // writing status
    dbRef
        .child("TEAMCHAT")
        .child("Writing")
        .child(widget.clientInfo["id"] + "_" + widget.userInfo.id)
        .onValue
        .listen((event) {
      if (mounted) {
        setState(() {
          _bWriting =
              event.snapshot.value == null ? false : event.snapshot.value;
        });
      }
    });
    dbRef
        .child("ONLINE")
        .child(widget.clientInfo["id"])
        .child('web')
        .onValue
        .listen((event) {
      if (mounted) {
        setState(() {
          _bOnline =
              event.snapshot.value != null ? event.snapshot.value : false;
        });
      }
    });
  }

  void sendMSG() {
    var curDateTime = new DateTime.now();

    if (filePath != null) {
      String base64Image = base64Encode(filePath.readAsBytesSync());
      String fileName = filePath.path.split("/").last;
      String ext = fileName.split(".").last;
      final body = {
        "file_name": fileName,
        "extension": ext,
        "img_data": base64Image,
      };
      ApiService.uploadChatFile(body).then((response) {
        if (response != null && response["status"]) {
          // print(response);
          var messageJSON = {
            "sender_id": widget.userInfo.id,
            "receiver_id": widget.clientInfo["id"],
            "message": _txtMsg.text,
            "read_status": "NO",
            "created_at": HttpDate.format(curDateTime),
            "zoneOffest": -curDateTime.timeZoneOffset.inMinutes,
            "attach_file": URLS.BASE_HTTP_URL + response["file_url"],
            "attach_real_name": response["real_name"],
            "timestamp": ServerValue.timestamp
          };
          setState(() {
            _attachExist = false;
            filePath = null;
            attachFileName = "";
          });
          chatRef.push().set(messageJSON);
          if (_bOnline == false &&
              DateTime.now().difference(previousMsgAt).inMinutes > 3) {
            final pushBody = {
              "sender_id": widget.userInfo.id,
              "receiver_id": widget.clientInfo["id"],
              "message": _txtMsg.text,
            };
            ApiService.sendNotification(pushBody).then((response) {});
            previousMsgAt = DateTime.now();
          }
          _txtMsg.text = "";
        } else {
          showErrorToast("Something error");
        }
      });
    } else {
      var messageJSON = {
        "sender_id": widget.userInfo.id,
        "receiver_id": widget.clientInfo["id"],
        "message": _txtMsg.text,
        "read_status": "NO",
        "created_at": HttpDate.format(curDateTime),
        "zoneOffest": -curDateTime.timeZoneOffset.inMinutes,
        "attach_file": "",
        "attach_real_name": "",
        "timestamp": ServerValue.timestamp
      };
      if (_txtMsg.text != "") {
        chatRef.push().set(messageJSON);
        if (_bOnline == false &&
            DateTime.now().difference(previousMsgAt).inMinutes > 3) {
          final pushBody = {
            "sender_id": widget.userInfo.id,
            "receiver_id": widget.clientInfo["id"],
            "message": _txtMsg.text,
          };
          ApiService.sendNotification(pushBody).then((response) {});
          previousMsgAt = DateTime.now();
        }
        _txtMsg.text = "";
      }
    }
  }

  void readMsg() {
    chatRef
        .orderByChild("read_status")
        .equalTo("NO")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> msgMap = snapshot.value;
      if (msgMap != null) {
        msgMap.forEach((key, value) {
          if (widget.clientInfo["id"] == value["sender_id"] &&
              value["receiver_id"] == widget.userInfo.id) {
            chatRef.child(key).child('read_status').set("YES");
          }
        });
      }
    });
  }

  Future<void> getFileFromPicker() async {
    filePath = await FilePicker.getFile(type: FileType.any);
    if (filePath != null) {
      String fileName = filePath.path.split("/").last;
      setState(() {
        _attachExist = true;
        attachFileName = fileName;
      });
    }
  }

  Future<void> getFileFromPicker1() async {
    var filePath1 = await FilePicker.getFile(type: FileType.image);

    if (filePath1 != null) {
      String fileName = filePath1.path.split("/").last;

      setState(() {
        filePath = filePath1;
        _attachExist = true;
        attachFileName = fileName;
      });
    }
  }

  void clearAttach() {
    setState(() {
      _attachExist = false;
      filePath = null;
    });
  }

  Future<void> deleteClientHistory() async {
    // delete chat history on database
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      chatRef.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> msgMap = snapshot.value;
        if (msgMap != null) {
          msgMap.forEach((key, value) {
            if ((widget.clientInfo["id"] == value["sender_id"] &&
                    value["receiver_id"] == widget.userInfo.id) ||
                (widget.clientInfo["id"] == value["receiver_id"] &&
                    value["sender_id"] == widget.userInfo.id)) {
              chatRef.child(key).remove();
            }
          });
        }
        if (mounted) {
          setState(() {
            allChatMsg.clear();
            msgCount = 0;
          });
        }
      });
    }
  }

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void writingOn() {
    dbRef
        .child("TEAMCHAT")
        .child("Writing")
        .child(widget.userInfo.id + "_" + widget.clientInfo["id"])
        .set(true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      dbRef
          .child("TEAMCHAT")
          .child("Writing")
          .child(widget.userInfo.id + "_" + widget.clientInfo["id"])
          .set(false);
    });
  }

  DateTime localTime(String isoString) {
    return HttpDate.parse(isoString);
  }

  @override
  Widget build(BuildContext context) {
    final msgSenderRow = Row(
      children: <Widget>[
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          flex: 1,
          child: Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                child: IconButton(
                  icon: Icon(
                    Icons.attach_file,
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    showMaterialModalBottomSheet(
                      isDismissible: true,
                      expand: false,
                      bounce: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        height: 300,
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Upload and Sending",
                                style: TextStyle(
                                  color: Color(0xff4285f4),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                leading: Image.asset(
                                  'assets/photo.png',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  'Upload from Photo',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  getFileFromPicker1();
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                leading: Image.asset(
                                  'assets/file.png',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  'Upload from File',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  getFileFromPicker();
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(30.0),
                                color: Color(0xff4285f4),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 4 * 3,
                                  padding: EdgeInsets.fromLTRB(
                                      80.0, 15.0, 80.0, 15.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel",
                                      textAlign: TextAlign.center,
                                      style: normalStyle.copyWith(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 8,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                    hintText: "Type message...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0))),
                controller: _txtMsg,
                onTap: () {
                  readMsg();
                },
                onChanged: (value) {
                  writingOn();
                },
                maxLines: null,
              ),
            )),
        Expanded(
          flex: 1,
          child: Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: CircleBorder(
                      side: BorderSide(color: Colors.blue, width: 1)),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    sendMSG();
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        )
      ],
    );
    final msgAttachRow = Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Material(
            color: Colors.white,
            child: Center(
              child: Icon(
                Icons.file_upload,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 2.0),
            child: Text(attachFileName),
          ),
        ),
        Expanded(
          flex: 1,
          child: Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    clearAttach();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
    final writingRow = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 4.0, 10.0, 0.0),
          child: Text(
            widget.clientInfo["username"] + " is typing",
            style: normalStyle.copyWith(fontSize: 12.0),
          ),
        ),
        ScalingText(
          '...',
          style: normalStyle.copyWith(fontSize: 24.0),
        ),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with " + widget.clientInfo["username"]),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  title: SelectableText(widget.clientInfo["email"]),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(msgCount.toString() + " Messages"),
                  ),
                  leading: Badge(
                    badgeContent: Text(' '),
                    badgeColor:
                        _bOnline ? Color(0xff00c851) : Color(0xffc23616),
                    elevation: 6.0,
                    padding: EdgeInsets.all(5.0),
                    // position:
                    //     BadgePosition.bottomRight(bottom: 0.0, right: 1.0),
                    child: Container(
                      width: 54.0,
                      height: 54.0,
                      decoration: new BoxDecoration(
                        color: const Color(0xff7c94b6),
                        image: new DecorationImage(
                          image: NetworkImage(
                              widget.clientInfo["photo_url"] == ""
                                  ? baseURL + 'uploads/avatar/profile.jpg'
                                  : baseURL + widget.clientInfo["photo_url"]),
                        ),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(27.0)),
                        border: new Border.all(
                          color: _bOnline ? Colors.green : Colors.red,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      deleteClientHistory();
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: allChatMsg != null ? allChatMsg.length : 0,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Visibility(
                              visible: allChatMsg[index]["attach_file"] != ""
                                  ? true
                                  : false,
                              child: Row(
                                mainAxisAlignment: allChatMsg[index]
                                            ["sender_id"] ==
                                        widget.userInfo.id
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Card(
                                    color: allChatMsg[index]["sender_id"] ==
                                            widget.userInfo.id
                                        ? Color(0xffdaf5fc)
                                        : Color(0xfff1f6f8),
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            1.0, 1.0, 1.0, 1.0),
                                        child: allChatMsg[index]["attach_real_name"] != "" &&
                                                (allChatMsg[index]["attach_real_name"]
                                                            .split(".")
                                                            .last ==
                                                        "jpg" ||
                                                    allChatMsg[index]["attach_real_name"]
                                                            .split(".")
                                                            .last ==
                                                        "png" ||
                                                    allChatMsg[index]["attach_real_name"]
                                                            .split(".")
                                                            .last ==
                                                        "jpeg" ||
                                                    allChatMsg[index]["attach_real_name"]
                                                            .split(".")
                                                            .last ==
                                                        "JPG" ||
                                                    allChatMsg[index]["attach_real_name"]
                                                            .split(".")
                                                            .last ==
                                                        "JPEG")
                                            ? Container(
                                                constraints: new BoxConstraints(
                                                    maxWidth: 100,
                                                    maxHeight: 80),
                                                child: FullScreenWidget(
                                                  backgroundColor: Colors.grey,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                    child: Image.network(allChatMsg[index]["attach_file"] == ""
                                                        ? baseURL +
                                                            'uploads/avatar/profile.jpg'
                                                        : allChatMsg[index]
                                                            ["attach_file"]),
                                                    
                                                  ),
                                                ),
                                              )
                                                : Container(
                                                constraints: new BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width - 84),
                                                child: SelectableText(
                                                  allChatMsg[index]
                                                      ["attach_real_name"],
                                                  style: normalStyle,
                                                ))),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: allChatMsg[index]["message"] == ""
                                  ? false
                                  : true,
                              child: Row(
                                mainAxisAlignment: allChatMsg[index]
                                            ["sender_id"] ==
                                        widget.userInfo.id
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Card(
                                    color: allChatMsg[index]["sender_id"] ==
                                            widget.userInfo.id
                                        ? Color(0xffdaf5fc)
                                        : Color(0xfff1f6f8),
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            15.0, 5.0, 15.0, 5.0),
                                        child: Container(
                                            constraints: new BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    84),
                                            child: SelectableText(
                                              allChatMsg[index]["message"],
                                              style: normalStyle,
                                            ))),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: allChatMsg[index]
                                          ["sender_id"] ==
                                      widget.userInfo.id
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 10.0,
                                ),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 2.0, 15.0, 2.0),
                                    child: SelectableText(
                                      allChatMsg[index]["created_at"],
                                      style:
                                          normalStyle.copyWith(fontSize: 11.0),
                                    )),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ],
                        );
                      })),
              Visibility(
                visible: _bWriting,
                child: writingRow,
              ),
              Visibility(
                visible: _attachExist,
                child: Container(
                  margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: msgAttachRow,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                ),
              ),
              msgSenderRow
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:badges/badges.dart';
import 'package:flag/flag.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/screens/chat/onlinechat_hist_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:hemailer/screens/chat/schedule_message.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OnlineChatScreen extends StatefulWidget {
  final UserModel userInfo;
  OnlineChatScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _OnlineChatScreenState createState() => _OnlineChatScreenState();
}

class _OnlineChatScreenState extends State<OnlineChatScreen> {
  List<dynamic> filteredSubs = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> allClients = new List<dynamic>();
  List<dynamic> savedClients = new List<dynamic>();
  List<dynamic> newMsgCounts;
  bool _progressBarActive = false;
  final assetsAudioPlayer = AssetsAudioPlayer();
  int newConntectedClient = 0;
  
  var dbRef;
  DatabaseReference chatRef;
  DatabaseReference onlineRef;
  var childAddedListener;
  bool _bOnline = true;

  // OnlineChatSocket onlineSocket;
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference();
    dbRef.child("ONLINE").child(widget.userInfo.id).child('web').set(true);
    onlineRef =
        dbRef.child("ONLINECHAT").child(widget.userInfo.id).child('online');
    chatRef = dbRef.child("ONLINECHAT").child(widget.userInfo.id).child('msg');
    
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContacts(body).then((response) {
      savedClients = response["contacts"];
      
      onlineRef.onValue.listen((event) {
        Map<dynamic, dynamic> onlineMap = event.snapshot.value;
        if (onlineMap != null) {
          if (mounted) {
            allClients.clear();
            setState(() {
              onlineMap.forEach((key, value) {
                if (value["connected"] == "READY" && value["online"] && value.containsKey("email")) {
                  newConntectedClient++;
                }
                value["new_msg"] = "0";
                value["writing"] = false;
                if (value.containsKey("email")){
                  value["returned"] = false;
                  savedClients.forEach((element) {
                    if(element["email"] == value["email"]){
                      value["returned"] = true;
                    }
                  });
                  allClients.add(value);
                }
              });
            });
            allClients.sort((b, a) => a['id'].compareTo(b['id']));
            filterSearchResults(txtSearch.text);
            if (newConntectedClient > 0) {
              assetsAudioPlayer.stop();
              assetsAudioPlayer.open(
                Audio("assets/alert_4s.mp3"),
              );
              assetsAudioPlayer.loop = true;
              assetsAudioPlayer.play();
            }else{
              assetsAudioPlayer.stop();
            }
          }
        }
      });
      
      setState(() {
        _progressBarActive = false;
      });
    });

    dbRef
          .child("ONLINECHAT")
          .child(widget.userInfo.id)
          .child("Writing")
          .onValue
          .listen((event) {
        Map<dynamic, dynamic> onlineMap = event.snapshot.value;
        if (onlineMap != null) {
          if (mounted) {
            setState(() {
              onlineMap.forEach((key, value) {
                for (var client in allClients) {
                  var tmpID = client["id"] + "_" + widget.userInfo.id;
                  if (tmpID == key) {
                    client["writing"] = value;
                  }
                }
              });
            });
          }
        }
      });
      getNewMsgCount();  

    
  }

  @override
  void dispose() {
    if (childAddedListener != null) {
      childAddedListener.cancel();
      childAddedListener = null;
    }

    dbRef.child("ONLINE").child(widget.userInfo.id).child('web').set(false);
    if (assetsAudioPlayer.isPlaying.value){
      assetsAudioPlayer.stop();
    }
    super.dispose();
  }

  void getNewMsgCount() {
    setState(() {
      for (var client in allClients) {
        client["new_msg"] = "0";
      }
    });
    if (childAddedListener != null) {
      childAddedListener.cancel();
      childAddedListener = null;
    }
    // set unread msg..
    childAddedListener = dbRef
        .child("ONLINECHAT")
        .child(widget.userInfo.id)
        .child('msg')
        .orderByChild("read_status")
        .equalTo("NO")
        .onChildAdded
        .listen((Event event) {
      var oneMsg = event.snapshot.value;
      if (oneMsg != null) {
        if (mounted) {
          setState(() {
            for (var client in allClients) {
              if (client["id"] == oneMsg["sender_id"] &&
                  oneMsg["receiver_id"] == widget.userInfo.id) {
                client["new_msg"] =
                    (int.parse(client["new_msg"]) + 1).toString();
              }
            }
          });
        }
      }
    });
  }

  Future<void> deleteClient(dynamic clientInfo) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      dbRef
          .child("ONLINECHAT")
          .child(widget.userInfo.id)
          .child("Writing")
          .child(widget.userInfo.id + "_" + clientInfo["id"])
          .remove();
      dbRef
          .child("ONLINECHAT")
          .child(widget.userInfo.id)
          .child("Writing")
          .child(clientInfo["id"] + "_" + widget.userInfo.id)
          .remove();
      chatRef.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> msgMap = snapshot.value;
        if (msgMap != null) {
          msgMap.forEach((key, value) {
            if ((clientInfo["id"] == value["sender_id"] &&
                    value["receiver_id"] == widget.userInfo.id) ||
                (clientInfo["id"] == value["receiver_id"] &&
                    value["sender_id"] == widget.userInfo.id)) {
              chatRef.child(key).remove();
            }
          });
        }
        onlineRef.child(clientInfo["id"]).remove();
      });
      final body = {
        "email_id": clientInfo["id"],
        "user_id": widget.userInfo.id,
      };
      ApiService.deleteOnlineClient(body).then((response) {
        if (response != null && response["status"]) {
        } else {
          showErrorToast("Something error");
        }
      });
    }
  }

  void saveClient(dynamic clientInfo, index) {
    final body = {
      "email_id": clientInfo["id"],
      "user_id": widget.userInfo.id,
    };
    ApiService.saveOnlineClient(body).then((response) {
      if (response != null && response["status"]) {
        showSuccessToast("Saved");
        setState(() {
          filteredSubs[index]["returned"] = true;
        });
      } else {
        showErrorToast("Something error");
      }
    });
  }

  void selectClient(dynamic clientInfo, BuildContext context) {
    
    newConntectedClient = 0;
    onlineRef.child(clientInfo["id"]).child('connected').set('connected');
    assetsAudioPlayer.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineChatHistoryScreen(
          clientInfo: clientInfo,
          userInfo: widget.userInfo,
          allClients: allClients,
        ),
      ),
    ).then((value) {
      newConntectedClient = 0;
      onlineRef.onValue.listen((event) {
        Map<dynamic, dynamic> onlineMap = event.snapshot.value;
        if (onlineMap != null) {
          if (mounted) {
            allClients.clear();
            setState(() {
              onlineMap.forEach((key, value) {
                if (value["connected"] == "READY" && value["online"] && value.containsKey("email")) {
                  newConntectedClient++;
                }
                value["new_msg"] = "0";
                value["writing"] = false;
                if (value.containsKey("email")){
                  value["returned"] = false;
                  savedClients.forEach((element) {
                    if(element["email"] == value["email"]){
                      value["returned"] = true;
                    }
                  });
                  allClients.add(value);
                }
              });
            });
            allClients.sort((b, a) => a['id'].compareTo(b['id']));
            filterSearchResults(txtSearch.text);
            if (newConntectedClient > 0) {
              assetsAudioPlayer.open(
                Audio("assets/alert_4s.mp3"),
              );
              assetsAudioPlayer.loop = true;
              assetsAudioPlayer.play();
            } else {
              assetsAudioPlayer.stop();
            }
          }
        }
      });
      getNewMsgCount();
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      allClients.forEach((item) {
        print(item["online"]);
        if (item["name"]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()) && item["online"] == _bOnline) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredSubs.clear();
        filteredSubs.addAll(dummyListData);
      });
      return;
    } else {
      List<dynamic> dummyListData = List<dynamic>();
      allClients.forEach((item) {
        if (item["online"] == _bOnline) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredSubs.clear();
        filteredSubs.addAll(dummyListData);
      });
      
    }
  }

  void addSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleMessageScreen(
          userInfo: widget.userInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Chat"),
      ),
      drawer: AppDrawer(
        userInfo: widget.userInfo,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55.0),
        child: FloatingActionButton(
          mini: true,
          child: Icon(Icons.settings),
          onPressed: () {
            addSchedule(context);
          },
          tooltip: "Schedule message",
          backgroundColor: Colors.redAccent,
        ),
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
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Offline",
                      style: normalStyle,
                      textAlign: TextAlign.right,
                    ),
                    Switch(
                      value: _bOnline,
                      onChanged: (value) {
                        setState(() {
                          _bOnline = value;
                        });
                        filterSearchResults(txtSearch.text);
                      },
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    ),
                    Text(
                      "Online",
                      style: normalStyle,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 6.0),
                child: TextField(
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  controller: txtSearch,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.0),
                      labelText: "Search",
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0)))),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredSubs != null ? filteredSubs.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              color: Colors.grey[200],
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Text(filteredSubs[index]["name"], 
                                        style: TextStyle(
                                          color: filteredSubs[index]["returned"]
                                              ? Colors.blueAccent[400]
                                              : Colors.black,),
                                      ),
                                    ),
                                    Visibility(
                                      visible: filteredSubs[index]
                                                  ["connected"] ==
                                              "READY"
                                          ? true
                                          : false,
                                      child: Badge(
                                        badgeContent: Text(
                                          'Connecting...',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        badgeColor: Color(0xff00c851),
                                        shape: BadgeShape.square,
                                        elevation: 6.0,
                                        padding: EdgeInsets.all(5.0),
                                      ),
                                    ),
                                    Visibility(
                                      visible: filteredSubs[index]["writing"],
                                      child: ScalingText(
                                        '...',
                                        style: normalStyle.copyWith(
                                            fontSize: 30.0),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Text(filteredSubs[index]["email"], 
                                        style: TextStyle(
                                          color: filteredSubs[index]["returned"]
                                              ? Colors.blueAccent[400]
                                              : Colors.black,),
                                      ),
                                    ),
                                    Visibility(
                                        visible: filteredSubs[index]
                                                    ["new_msg"] !=
                                                "0"
                                            ? true
                                            : false,
                                        child: Badge(
                                          badgeContent: Text(
                                            filteredSubs[index]["new_msg"],
                                            style:
                                                TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                          badgeColor: Colors.red,
                                          elevation: 6.0,
                                          padding: EdgeInsets.all(3.0),
                                        )),
                                    Expanded(
                                      flex: 1,
                                      child: Flag(filteredSubs[index]["country_code"], height: 20,)
                                    ),
                                  ],
                                ),
                                leading: Badge(
                                  badgeContent: Text(' '),
                                  badgeColor: filteredSubs[index]["online"]
                                      ? Color(0xff00c851)
                                      : Color(0xffc23616),
                                  elevation: 6.0,
                                  padding: EdgeInsets.all(5.0),
                                  // position: BadgePosition.bottomRight(
                                  //     bottom: 0.0, right: 1.0),
                                  child: Container(
                                    width: 54.0,
                                    height: 54.0,
                                    decoration: new BoxDecoration(
                                      color: const Color(0xff7c94b6),
                                      image: new DecorationImage(
                                        image: new NetworkImage(baseURL +
                                            'uploads/avatar/profile.jpg'),
                                      ),
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(27.0)),
                                      border: new Border.all(
                                        color: filteredSubs[index]["online"]
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  print("AAAA");
                                  selectClient(filteredSubs[index], context);
                                },
                              ),
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Save',
                                color: Colors.blue,
                                icon: Icons.save,
                                onTap: () {
                                  saveClient(filteredSubs[index], index);
                                },
                              ),
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  deleteClient(filteredSubs[index]);
                                },
                              ),
                            ],
                          ),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

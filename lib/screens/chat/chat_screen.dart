import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/screens/chat/chat_hist_screen.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userInfo;
  ChatScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> filteredSubs = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> allClients;
  List<dynamic> newMsgCounts;
  bool _progressBarActive = false;

  bool bFirst = true;
  final dbRef = FirebaseDatabase.instance.reference();
  DatabaseReference chatRef;
  var childAddedListener;
  var onlineListener;
  // ChatSocket chatSocket;
  @override
  void initState() {
    super.initState();
    dbRef.child("ONLINE").child(widget.userInfo.id).child('web').set(true);
    chatRef = dbRef.child("TEAMCHAT").child(widget.userInfo.parentID);
    getChatUsers();
  }

  @override
  void dispose() {
    print("OKOKOK");
    if (childAddedListener != null) {
      childAddedListener.cancel();
      childAddedListener = null;
    }
    if (onlineListener != null) {
      onlineListener.cancel();
      onlineListener = null;
    }

    dbRef.child("ONLINE").child(widget.userInfo.id).child('web').set(false);
    super.dispose();
  }

  void getChatUsers() {
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getChatUsers(body).then((response) {
      setState(() {
        allClients = response;
        for (var client in allClients) {
          client["online"] = false;
          client["writing"] = false;
        }
        _progressBarActive = false;
      });
      // set online status
      onlineListener = dbRef.child("ONLINE").onValue.listen((event) {
        Map<dynamic, dynamic> onlineMap = event.snapshot.value;
        if (onlineMap != null) {
          if (mounted) {
            setState(() {
              onlineMap.forEach((key, value) {
                for (var client in allClients) {
                  if (client["id"] == key) {
                    client["online"] = value["web"];
                  }
                }
              });
            });
          }
        }
      });

      getNewMsgCount();
      dbRef.child("TEAMCHAT").child("Writing").onValue.listen((event) {
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
      filterSearchResults(txtSearch.text);
    });
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
    childAddedListener = chatRef
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

  void selectClient(dynamic clientInfo, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatHistoryScreen(
          clientInfo: clientInfo,
          userInfo: widget.userInfo,
        ),
      ),
    ).then((onValue) {
      getNewMsgCount();
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      allClients.forEach((item) {
        if (item["username"]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredSubs.clear();
        filteredSubs.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredSubs.clear();
        filteredSubs.addAll(allClients);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      drawer: AppDrawer(
        userInfo: widget.userInfo,
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
                padding: const EdgeInsets.all(6.0),
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
                          //                           <-- Card widget
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: Text(filteredSubs[index]["username"]),
                                ),
                                Visibility(
                                  visible: filteredSubs[index]["writing"],
                                  child: ScalingText(
                                    '...',
                                    style: normalStyle.copyWith(fontSize: 30.0),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: Text(filteredSubs[index]["email"]),
                                ),
                                Visibility(
                                    visible:
                                        filteredSubs[index]["new_msg"] != "0"
                                            ? true
                                            : false,
                                    child: Badge(
                                      badgeContent: Text(
                                        filteredSubs[index]["new_msg"],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      badgeColor: Colors.red,
                                      elevation: 6.0,
                                      padding: EdgeInsets.all(5.0),
                                    )),
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
                                    image: new NetworkImage(filteredSubs[index]
                                                ["photo_url"] ==
                                            ""
                                        ? baseURL + 'uploads/avatar/profile.jpg'
                                        : baseURL +
                                            filteredSubs[index]["photo_url"]),
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
                              selectClient(filteredSubs[index], context);
                            },
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

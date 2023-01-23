import 'dart:io';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/analytic_model.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:firebase_database/firebase_database.dart';

class AnalyticsDetailScreen extends StatefulWidget {
  final UserModel userInfo;
  final String curDomain, guid;
  AnalyticsDetailScreen(
      {Key key, @required this.userInfo, this.curDomain, this.guid})
      : super(key: key);
  @override
  _AnalyticsDetailState createState() => _AnalyticsDetailState();
}

class _AnalyticsDetailState extends State<AnalyticsDetailScreen> {
  bool _progressBarActive = false;

  List<AnalyticItem> allItems = new List<AnalyticItem>();
  final dbRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    allItems.clear();
    dbRef
    .child(widget.userInfo.id)
    .child('DOMAINS')
    .once()
    .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> domainMap = snapshot.value;

      setState(() {
        domainMap.forEach((keyDomain, valDomain) {
          dbRef
              .child(widget.userInfo.id)
              .child(keyDomain)
              .orderByChild("guid")
              .equalTo(widget.guid)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> itemMap = snapshot.value;
            setState(() {
              if (itemMap != null){
                itemMap.forEach((key, val) {
                  if (val["url"] != null) {
                    print(val["guid"]);
                    var calTime = localTime(val["time"]);
                    var deviceName = "Desktop";
                    //&& diffMinutes < 60
                    if (val["isMobile"]) {
                      deviceName = "Mobile";
                    } else if (val["isTablet"]) {
                      deviceName = "Tablet";
                    }

                    allItems.add(new AnalyticItem(
                        val["location"],
                        val["ip"],
                        deviceName,
                        val["osName"],
                        calTime.toLocal().toString().substring(0, 16),
                        val["guid"],
                        msToTime(val["timeSpentOnSite"]),
                        val["url"],
                        val['isNew'],
                        val['browser'],
                        key,
                        val['country_code']));
                  }
                });
              }
              
            });
          });
        });
      });
    });
  }

  void removeItem(index) {
    dbRef
        .child(widget.userInfo.id)
        .child(widget.curDomain)
        .child(allItems[index].key)
        .remove();
    setState(() {
      allItems.removeAt(index);
    });
  }

  String msToTime(var duration) {
    if (duration == null) {
      return "";
    }
    var miliSeconds = duration;
    var seconds = (miliSeconds / 1000) % 60;
    var minutes = (miliSeconds / (1000 * 60)) % 60;
    var hours = (miliSeconds / (1000 * 60 * 60)) % 24;

    String strHours = (hours < 10)
        ? "0" + hours.floor().toString()
        : hours.floor().toString();
    String strMinutes = (minutes < 10)
        ? "0" + minutes.floor().toString()
        : minutes.floor().toString();
    String strSeconds = (seconds < 10)
        ? "0" + seconds.floor().toString()
        : seconds.floor().toString();
    return strHours + ":" + strMinutes + ":" + strSeconds;
  }

  DateTime localTime(String isoString) {
    return HttpDate.parse(isoString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Detail"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: allItems != null ? allItems.length : 0,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 3.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: Text(allItems[index].url),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: allItems[index].isNew
                                      ? Container(
                                          decoration: new BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                2.0, 1.0, 2.0, 1.0),
                                            child: Center(
                                              child: Text(
                                                "New",
                                                style: normalStyle.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 12.0),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(""),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      removeItem(index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.blueAccent,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(allItems[index].location),
                                ),
                                Expanded(
                                      flex: 7,
                                      child:
                                          Flag(allItems[index].country_code == null ? 'ca': allItems[index].country_code, height: 20,)
                                ),
                                 Expanded(
                                      flex: 1,
                                      child:
                                          Text('')
                                    ),
                                Expanded(
                                  flex: 7,
                                  child: Text(allItems[index].ip),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(allItems[index].device),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(allItems[index].browser),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    allItems[index].osName,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(allItems[index].landedAt),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(allItems[index].timeSpent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

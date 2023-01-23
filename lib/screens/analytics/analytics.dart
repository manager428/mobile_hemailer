import 'dart:io';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/analytic_model.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/analytics/analytic_detail.dart';
import 'package:hemailer/screens/analytics/analytic_history.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class AnalyticsScreen extends StatefulWidget {
  final UserModel userInfo;
  AnalyticsScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<AnalyticsScreen> {
  bool _progressBarActive = false;
  List<DropdownMenuItem> itemsDomain = [];
  String curDomain;
  int cntDesktop, cntMobile, cntTablet, cntTotal;
  List<AnalyticItem> allActiveUsers = new List<AnalyticItem>();
  final dbRef = FirebaseDatabase.instance.reference();
  var userRef;
  List<Color> colorList = [
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];
  List<String> domainList = new List<String>();

  @override
  void initState() {
    super.initState();
    allActiveUsers.clear();
    domainList.clear();
    cntDesktop = 0;
    cntMobile = 0;
    cntTablet = 0;
    cntTotal = cntDesktop + cntMobile + cntTablet;
    dbRef
        .child(widget.userInfo.id)
        .child('DOMAINS')
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> domainMap = snapshot.value;
      bool _bFirst = true;
      setState(() {
        domainMap.forEach((key, value) {
          if (_bFirst) {
            curDomain = key;
            _bFirst = false;
          }
          domainList.add(key);
        });
      });
      refreshDomain();
      dbChangeEvent();
    });
  }

  void refreshDomain() {
    itemsDomain.clear();
    domainList.forEach((val) {
      itemsDomain.add(new DropdownMenuItem(
        child: Text(val.toString().replaceAll("_", ".")),
        value: val,
      ));
    });
  }

  void removeDomain() {
    dbRef.child(widget.userInfo.id).child(curDomain).remove();
    dbRef.child(widget.userInfo.id).child('DOMAINS').child(curDomain).remove();
    setState(() {
      domainList.remove(curDomain);
      if (domainList.length > 0) {
        curDomain = domainList[0];
      } else {
        curDomain = "";
      }
    });
    refreshDomain();
    dbChangeEvent();
  }

  void dbChangeEvent() {
    var startDate =
        new DateTime.now().subtract(new Duration(days: 12)).toUtc().millisecondsSinceEpoch/1000.toInt();
    var endDate =
        new DateTime.now().add(new Duration(days: 12)).toUtc().millisecondsSinceEpoch/1000.toInt();
    dbRef
        .child(widget.userInfo.id)
        .child(curDomain)
        .orderByChild("timestamp")
        .startAt(startDate)
        .endAt(endDate)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        refreshData(event.snapshot.value);
      }
    });
  }

  void refreshData(Map<dynamic, dynamic> valMap) {
    var curTime = new DateTime.now();
    cntMobile = cntTablet = cntDesktop = 0;
    allActiveUsers.clear();
    if (mounted) {
      setState(() {
        valMap.forEach((key, val) {
          if (val["url"] != null) {
            var calTime = localTime(val["time"]);
            var diffMinutes = curTime.difference(calTime.toLocal()).inMinutes;
            var deviceName = "Desktop";
            if (val["active"] && diffMinutes < 60) {
              if (val["isMobile"]) {
                cntMobile++;
                deviceName = "Mobile";
              } else if (val["isTablet"]) {
                cntTablet++;
                deviceName = "Tablet";
              } else {
                cntDesktop++;
              }

              allActiveUsers.add(new AnalyticItem(
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
                  val['country_code'],));
            }
          }
        });

        cntTotal = cntMobile + cntDesktop + cntTablet;
      });
    }
  }

  void goToAnalyticDetail(String guid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsDetailScreen(
            guid: guid, curDomain: curDomain, userInfo: widget.userInfo),
      ),
    ).then((value) {
      dbChangeEvent();
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
    Map<String, double> dataActiveMap = new Map();
    dataActiveMap.putIfAbsent(
        "Dektop : " + cntDesktop.toString(), () => cntDesktop.toDouble());
    dataActiveMap.putIfAbsent(
        "Mobile : " + cntMobile.toString(), () => cntMobile.toDouble());
    dataActiveMap.putIfAbsent(
        "Tablet  : " + cntTablet.toString(), () => cntTablet.toDouble());

    final activeChart = PieChart(
      dataMap: dataActiveMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 5,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      colorList: colorList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 10,
    );

    final domainRow = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 30.0, 0.0),
            child: DropdownButton(
              items: itemsDomain,
              value: curDomain,
              onChanged: (value) {
                setState(() {
                  curDomain = value;
                });
                dbChangeEvent();
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15.0, 6.0, 5.0, 5.0),
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(20),
              ),
              textColor: Colors.red,
              color: Colors.white,
              onPressed: () {
                removeDomain();
              },
              icon: Icon(
                Icons.delete_forever,
                size: 18,
              ),
              label: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real time Analytics"),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textColor: Colors.white,
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    settings: const RouteSettings(name: '/analytics-history'),
                    builder: (context) =>
                        new AnalyticsHistoryScreen(userInfo: widget.userInfo)));
              },
              icon: Icon(
                Icons.insert_chart,
                size: 25,
              ),
              label: Text(
                'History',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        userInfo: widget.userInfo,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              domainRow,
              Text(
                'Active Users : ' + cntTotal.toString(),
                style: normalStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Card(
                margin: EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 10.0),
                child: activeChart,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: allActiveUsers != null ? allActiveUsers.length : 0,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 3.0),
                      child: Material(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 9,
                                      child: Text(allActiveUsers[index].url),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: allActiveUsers[index].isNew
                                          ? Container(
                                              decoration: new BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              8.0))),
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
                                  ],
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child:
                                          Text(allActiveUsers[index].location),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child:
                                          Flag(allActiveUsers[index].country_code == null ? 'ca': allActiveUsers[index].country_code, height: 20,)
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child:
                                          Text('')
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Text(allActiveUsers[index].ip),
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
                                      child: Text(allActiveUsers[index].device),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child:
                                          Text(allActiveUsers[index].browser),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        allActiveUsers[index].osName,
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
                                      child:
                                          Text(allActiveUsers[index].landedAt),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child:
                                          Text(allActiveUsers[index].timeSpent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            goToAnalyticDetail(allActiveUsers[index].guid);
                          },
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

import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/analytic_model.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/analytics/analytic_detail.dart';
import 'package:hemailer/screens/analytics/analytics.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class AnalyticsHistoryScreen extends StatefulWidget {
  final UserModel userInfo;
  AnalyticsHistoryScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _AnalyticsHistoryState createState() => _AnalyticsHistoryState();
}

class _AnalyticsHistoryState extends State<AnalyticsHistoryScreen> {
  bool _progressBarActive = false;
  List<DropdownMenuItem> itemsDomain = [];
  String curDomain;
  int cntNew, cntRecurring, cntTotal;
  String avgSpent, bounceRate;
  List<AnalyticItem> allItems = new List<AnalyticItem>();
  final dbRef = FirebaseDatabase.instance.reference();
  var userRef;
  List<Color> colorList = [
    Colors.green,
    Colors.blue,
  ];
  List<String> domainList = new List<String>();
  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();
  TextEditingController _txtStartDate = new TextEditingController();
  TextEditingController _txtEndDate = new TextEditingController();
  var _firstDayOfTheweek, _endDayOfTheWeek;
  String startDate, endDate;

  @override
  void initState() {
    super.initState();
    _firstDayOfTheweek = now
        .subtract(new Duration(days: now.weekday == 0 ? 6 : now.weekday - 1));
    _endDayOfTheWeek = _firstDayOfTheweek.add(new Duration(days: 6));
    startDate = format.format(_firstDayOfTheweek);
    endDate = format.format(_endDayOfTheWeek);
    _txtStartDate.text = startDate;
    _txtEndDate.text = endDate;

    allItems.clear();
    domainList.clear();
    cntNew = cntRecurring = 0;
    avgSpent = bounceRate = "";
    cntTotal = cntNew + cntRecurring;
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
    if (startDate == "" || endDate == "") {
      return;
    }
    var sDate = DateTime.parse(startDate)
        .subtract(new Duration(days: 1)).toUtc().millisecondsSinceEpoch/1000.toInt();
        
    var eDate =
        DateTime.parse(endDate).add(new Duration(days: 1)).toUtc().millisecondsSinceEpoch/1000.toInt();
    print(sDate);
    dbRef
        .child(widget.userInfo.id)
        .child(curDomain)
        .orderByChild("timestamp")
        .startAt(sDate)
        .endAt(eDate)
        .onValue
        .listen((event) {
          if (event.snapshot.value != null) {
            refreshData(event.snapshot.value);
          }else{
            print("bbbb");
            setState(() {
              allItems.clear();
            });
            
          }
    });
  }

  void refreshData(Map<dynamic, dynamic> valMap) {
    cntNew = cntRecurring = 0;
    avgSpent = bounceRate = "";
    allItems.clear();
    int timeSpentPerUser = 0;
    int sumTimeSpent = 0;
    int pageViewsPerUser = 0;
    int sumSinglePageViews = 0;
    int sumPageViews = 0;
    String prevGUID = "";
    DateTime prevLandingAt;
    bool bFirst = true;
    var sortedEntries = valMap.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value["guid"].compareTo(e1.value["guid"]);
        return diff;
      });
    valMap
      ..clear()
      ..addEntries(sortedEntries);
    setState(() {
      var sDate = DateTime.parse(startDate);
      var eDate = DateTime.parse(endDate)
          .add(new Duration(hours: 23, minutes: 59, seconds: 59));
      
      valMap.forEach((key, val) {
        if (val["url"] != null) {
          
          var calTime = localTime(val["time"]);

          if (calTime.toLocal().compareTo(sDate) >= 0 && calTime.toLocal().compareTo(eDate) < 0) {
            var deviceName = "Desktop";

            if (val["isMobile"]) {
              deviceName = "Mobile";
            } else if (val["isTablet"]) {
              deviceName = "Tablet";
            }
            if (bFirst) {
              prevGUID = val['guid'];
              prevLandingAt = calTime.toLocal();
              bFirst = false;
            }
            timeSpentPerUser +=
                val['timeSpentOnSite'] != null ? val['timeSpentOnSite'] : 0;
            pageViewsPerUser += 1;
            if (prevGUID.toString() != val["guid"].toString()) {
              if (val["isNew"]) {
                cntNew++;
              } else {
                cntRecurring++;
              }
              allItems.add(new AnalyticItem(
                  val["location"],
                  val["ip"],
                  deviceName,
                  val["osName"],
                  calTime.toLocal().toString().substring(0, 16),
                  val["guid"],
                  msToTime(timeSpentPerUser),
                  val["url"],
                  val['isNew'],
                  val['browser'],
                  key,
                  val['country_code']));
              if (pageViewsPerUser == 1) {
                sumSinglePageViews++;
              }
              timeSpentPerUser = 0;
              pageViewsPerUser = 0;
            } else {
              if (prevLandingAt.difference(calTime.toLocal()).inMinutes.abs() > 60) {
                if (val["isNew"]) {
                  cntNew++;
                } else {
                  cntRecurring++;
                }
                allItems.add(new AnalyticItem(
                    val["location"],
                    val["ip"],
                    deviceName,
                    val["osName"],
                    calTime.toLocal().toString().substring(0, 16),
                    val["guid"],
                    msToTime(timeSpentPerUser),
                    val["url"],
                    val['isNew'],
                    val['browser'],
                    key,
                    val['country_code']));
                if (pageViewsPerUser == 1) {
                  sumSinglePageViews++;
                }
                timeSpentPerUser = 0;
                pageViewsPerUser = 0;
              }
            }
            prevGUID = val['guid'].toString();
            prevLandingAt = calTime.toLocal();
            sumTimeSpent +=
                val['timeSpentOnSite'] != null ? val['timeSpentOnSite'] : 0;
            sumPageViews += 1;
          }
        }
      });

      cntTotal = cntNew + cntRecurring;
      if (cntTotal != 0) {
        avgSpent = msToTime((sumTimeSpent / cntTotal).floor());
        bounceRate =
            (sumSinglePageViews / sumPageViews * 100).toStringAsFixed(2);
      }
    });
    
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
    try {
      return HttpDate.parse(isoString);
    } on Exception catch(e) {
      return DateTime.parse(isoString);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataActiveMap = new Map();
    dataActiveMap.putIfAbsent(
        "New : " + cntNew.toString(), () => cntNew.toDouble());
    dataActiveMap.putIfAbsent("Returning : " + cntRecurring.toString(),
        () => cntRecurring.toDouble());

    final userChart = PieChart(
      dataMap: dataActiveMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 5,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: true,
      colorList: colorList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 20,
    );
    final rowDateRange = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 3.0, 10.0, 0.0),
              child: DateTimeField(
                format: format,
                controller: _txtStartDate,
                onChanged: (value) {
                  if (startDate != _txtStartDate.text) {
                    startDate = _txtStartDate.text;
                    dbChangeEvent();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Start date',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 6.0),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 3.0, 10.0, 0.0),
              child: DateTimeField(
                format: format,
                controller: _txtEndDate,
                onChanged: (value) {
                  if (endDate != _txtEndDate.text) {
                    endDate = _txtEndDate.text;
                    dbChangeEvent();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'End date',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 6.0),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
            )),
      ],
    );
    final domainRow = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0, 3.0, 30.0, 0.0),
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
            padding: EdgeInsets.fromLTRB(15.0, 3.0, 5.0, 5.0),
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
        title: const Text("Analytics History"),
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
                    settings: const RouteSettings(name: '/analytics'),
                    builder: (context) =>
                        new AnalyticsScreen(userInfo: widget.userInfo)));
              },
              icon: Icon(
                Icons.insert_chart,
                size: 25,
              ),
              label: Text(
                'Real Time',
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
              rowDateRange,
              domainRow,
              Card(
                margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 3.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.0, 12.0, 6.0, 3.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    'Avg Spent Time : ' + avgSpent,
                                    textAlign: TextAlign.left,
                                    style: normalStyle.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.0, 12.0, 6.0, 3.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    'All Users : ' + cntTotal.toString(),
                                    textAlign: TextAlign.center,
                                    style: normalStyle.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 3.0, 6.0, 0.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Bounce Rate :  ' + bounceRate + " %",
                              textAlign: TextAlign.left,
                              style: normalStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    userChart
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: allItems != null ? allItems.length : 0,
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
                                      child: Text(allItems[index].url),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: allItems[index].isNew
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
                                      child: Text(allItems[index].location),
                                    ),
                                    Expanded(
                                      flex: 1,
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
                          onTap: () {
                            goToAnalyticDetail(allItems[index].guid);
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

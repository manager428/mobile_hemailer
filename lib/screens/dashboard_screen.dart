import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userInfo;
  HomeScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var stastics;
  bool _progressBarActive = false;
  List<Color> colorList = [
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  List<Color> colorPriceList = [
    Colors.blue,
    Colors.red,
  ];
  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();
  TextEditingController _txtStartDate = new TextEditingController();
  TextEditingController _txtEndDate = new TextEditingController();
  var _firstDayOfTheweek, _endDayOfTheWeek;
  var startDate, endDate;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
    refreshDashboard();
    getMessage();
    _register();
  }

  _register() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
      final body = {
        "user_id": widget.userInfo.id,
        "token": token,
      };
      ApiService.updateToken(body).then((response) {});
    });
  }

  void refreshDashboard() {
    final body = {
      "user_id": widget.userInfo.id,
      "start_date": _txtStartDate.text,
      "end_date": _txtEndDate.text
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getStatistics(body).then((response) {
      setState(() {
        stastics = response;
        _progressBarActive = false;
      });
    });
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      // print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    final rowDateRange = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: DateTimeField(
                format: format,
                controller: _txtStartDate,
                onChanged: (value) {
                  if (startDate != _txtStartDate.text) {
                    refreshDashboard();
                    startDate = _txtStartDate.text;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Start date',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
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
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: DateTimeField(
                format: format,
                controller: _txtEndDate,
                onChanged: (value) {
                  if (endDate != _txtEndDate.text) {
                    refreshDashboard();
                    endDate = _txtEndDate.text;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'End date',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
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
    final rowSentHistory1 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SENT EMAIL",
                    style: cardHeaderStyle.copyWith(color: Colors.blue),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["sent"] : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SCHEDULE EMAIL",
                    style: cardHeaderStyle.copyWith(color: Color(0xffffbb33)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["schedule"] : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowSentHistory2 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "RECEIVED",
                    style: cardHeaderStyle.copyWith(color: Color(0xff33b5e5)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["sent"] != "0"
                        ? stastics["received"] +
                            " (" +
                            (int.parse(stastics["received"]) /
                                    int.parse(stastics["sent"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "OPENED",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["sent"] != "0"
                        ? stastics["opened"] +
                            " (" +
                            (int.parse(stastics["opened"]) /
                                    int.parse(stastics["sent"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowEmails1 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "CONTACTS",
                    style: cardHeaderStyle.copyWith(color: Color(0xffaa66cc)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["allemails"] : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "CANCELLED",
                    style: cardHeaderStyle.copyWith(color: Color(0xffffbb33)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["allemails"] != "0"
                        ? stastics["cancelled"] +
                            " (" +
                            (int.parse(stastics["cancelled"]) /
                                    int.parse(stastics["allemails"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowEmails2 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "RECURRING",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["allemails"] != "0"
                        ? stastics["old_emails"] +
                            " (" +
                            (int.parse(stastics["old_emails"]) /
                                    int.parse(stastics["allemails"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "NEW SUB",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["allemails"] != "0"
                        ? stastics["new_emails"] +
                            " (" +
                            (int.parse(stastics["new_emails"]) /
                                    int.parse(stastics["allemails"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowEmails3 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "UNSUBSCRIBE",
                    style: cardHeaderStyle.copyWith(color: Color(0xffff3547)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["allemails"] != "0"
                        ? stastics["unsubscribe"] +
                            " (" +
                            (int.parse(stastics["unsubscribe"]) /
                                    int.parse(stastics["allemails"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "NEW OPTINS",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["new_subscribers"] : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowRecurring = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Recurring Email",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["recurring_emails"] : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: widget.userInfo.invoiceOn == "YES"
              ? Card(
                  margin: EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Recurring Invoice",
                          style: cardHeaderStyle.copyWith(
                              color: Color(0xff00c851)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                        child: Text(
                          stastics != null
                              ? stastics["recurring_invoices"]
                              : "0",
                          style: normalStyle,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(""),
        )),
      ],
    );

    Map<String, double> dataEmailMap = new Map();
    dataEmailMap.putIfAbsent(
        "New Sub" + (stastics != null ? " : " + stastics["new_emails"] : ""),
        () => stastics != null ? double.parse(stastics["new_emails"]) : 0);
    dataEmailMap.putIfAbsent(
        "Recurring" + (stastics != null ? " : " + stastics["old_emails"] : ""),
        () => stastics != null ? double.parse(stastics["old_emails"]) : 0);
    dataEmailMap.putIfAbsent(
        "Cancelled" + (stastics != null ? " : " + stastics["cancelled"] : ""),
        () => stastics != null ? double.parse(stastics["cancelled"]) : 0);
    dataEmailMap.putIfAbsent(
        "Unsubscribe" +
            (stastics != null ? " : " + stastics["unsubscribe"] : ""),
        () => stastics != null ? double.parse(stastics["unsubscribe"]) : 0);

    final emailsChart = PieChart(
      dataMap: dataEmailMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 2.7,
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

    Map<String, double> dataPriceMap = new Map();
    dataPriceMap.putIfAbsent(
        "Total" +
            (stastics != null && stastics["sum_expense"]["sum_price"] != null
                ? " : " + stastics["sum_expense"]["sum_price"] + "\$"
                : ""),
        () => stastics != null && stastics["sum_expense"]["sum_price"] != null
            ? double.parse(stastics["sum_expense"]["sum_price"])
            : 0);
    dataPriceMap.putIfAbsent(
        "Expense" +
            (stastics != null && stastics["sum_expense"]["sum_expense"] != null
                ? " : " + stastics["sum_expense"]["sum_expense"] + "\$"
                : ""),
        () => stastics != null && stastics["sum_expense"]["sum_expense"] != null
            ? double.parse(stastics["sum_expense"]["sum_expense"])
            : 0);

    final priceChart = PieChart(
      dataMap: dataPriceMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 2.7,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      colorList: colorPriceList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 10,
    );
    final rowProfit = Card(
      margin: EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "PROFIT",
                  style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    stastics != null &&
                            stastics["sum_expense"]["sum_price"] != null &&
                            stastics["sum_expense"]["sum_expense"] != null
                        ? (double.parse(stastics["sum_expense"]["sum_price"]) -
                                    double.parse(
                                        stastics["sum_expense"]["sum_expense"]))
                                .toString() +
                            ("\$")
                        : "",
                    style: normalStyle),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 12), child: priceChart),
        ],
      ),
    );
    final rowContracts1 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SENT CONTRACTS",
                    style: cardHeaderStyle.copyWith(color: Color(0xff4285f4)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null ? stastics["contracts"]["sent"] : "",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "RECEIVED CONTRACTS",
                    style: cardHeaderStyle.copyWith(color: Color(0xff33b5e5)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["contracts"]["sent"] != "0"
                        ? stastics["contracts"]["received"] +
                            " (" +
                            (int.parse(stastics["contracts"]["received"]) /
                                    int.parse(stastics["contracts"]["sent"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
    final rowContracts2 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "OPENED CONTRACTS",
                    style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["contracts"]["sent"] != "0"
                        ? stastics["contracts"]["opened"] +
                            " (" +
                            (int.parse(stastics["contracts"]["opened"]) /
                                    int.parse(stastics["contracts"]["sent"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
        Container(
            child: Expanded(
          child: Card(
            margin: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SIGNED CONTRACTS",
                    style: cardHeaderStyle.copyWith(color: Colors.red),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    stastics != null && stastics["contracts"]["sent"] != "0"
                        ? stastics["contracts"]["signed"] +
                            " (" +
                            (int.parse(stastics["contracts"]["signed"]) /
                                    int.parse(stastics["contracts"]["sent"]) *
                                    100)
                                .round()
                                .toString() +
                            "%)"
                        : "0",
                    style: normalStyle,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                rowDateRange,
                rowSentHistory1,
                rowSentHistory2,
                rowEmails1,
                rowEmails2,
                rowEmails3,
                rowRecurring,
                Card(
                  margin: EdgeInsets.all(12.0),
                  child: emailsChart,
                ),
                rowProfit,
                rowContracts1,
                rowContracts2
              ],
            ),
          ),
        ),
      ),
    );
  }
}

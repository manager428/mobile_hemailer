import 'package:badges/badges.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/contacts/detail_screen.dart';
import 'package:hemailer/screens/contacts/send_email_screen.dart';
import 'package:hemailer/screens/contacts/send_invoice_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

class RecurringScreen extends StatefulWidget {
  final UserModel userInfo;
  RecurringScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _RecurringScreenState createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<dynamic> filteredSubs = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> allSubs;
  bool _progressBarActive = false;

  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();
  TextEditingController _txtStartDate = new TextEditingController();
  TextEditingController _txtEndDate = new TextEditingController();
  var _firstDayOfTheweek, _endDayOfTheWeek;
  var startDate, endDate;
  var weeksDay = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  var months = [
    'January',
    'Feburay',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  var endMode = ['After', 'On', 'Never'];
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
    refreshRecurrings();
  }

  void refreshRecurrings() {
    final body = {
      "user_id": widget.userInfo.id,
      "start_date": _txtStartDate.text,
      "end_date": _txtEndDate.text
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getRecurring(body).then((response) {
      setState(() {
        allSubs = response;
        _progressBarActive = false;
      });
      filterSearchResults(txtSearch.text);
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      allSubs.forEach((item) {
        if (item["contactInfo"]["name"]
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
        filteredSubs.addAll(allSubs);
      });
    }
  }

  Future<void> delRecurring(dynamic reminderInfo) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "del_id": reminderInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteRecurring(body).then((response) {
        setState(() {
          allSubs.remove(reminderInfo);
          filteredSubs.remove(reminderInfo);
          _progressBarActive = false;
        });
      });
    }
  }

  void editRecurring(dynamic reminderInfo, BuildContext context) {
    final body = {
      "user_id": widget.userInfo.id,
      "contact_id": reminderInfo["receiver_id"]
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContactsAllAndOne(body).then((response) {
      if (reminderInfo["invoice_tmp"] == "1") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendInvoiceScreen(
              recurringInfo: reminderInfo,
              allContacts: response["allContacts"],
              contactInfo: response["contactInfo"],
              userInfo: widget.userInfo,
            ),
          ),
        ).then((val) {
          refreshRecurrings();
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendEmailScreen(
              recurringInfo: reminderInfo,
              allContacts: response["allContacts"],
              contactInfo: response["contactInfo"],
              userInfo: widget.userInfo,
            ),
          ),
        ).then((val) {
          refreshRecurrings();
        });
      }
    });
  }

  void _gotoContacPage(dynamic reminderInfo, BuildContext context) {
    final body = {
      "user_id": widget.userInfo.id,
      "contact_id": reminderInfo["receiver_id"]
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContactsAllAndOne(body).then((response) {
      setState(() {
        _progressBarActive = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactDetailScreen(
            allContacts: response["allContacts"],
            contactInfo: response["contactInfo"],
            userInfo: widget.userInfo,
          ),
        ),
      );
    });
  }

  String getScheduleText(dynamic item) {
    String result = "Repeat ";
    if (item["repeat_mode"] == "1") {
      result += "every day";
    } else if (item["repeat_mode"] == "2") {
      result += "Weekly every " + weeksDay[int.parse(item["repeat_weekly"])];
    } else if (item["repeat_mode"] == "3") {
      result += "Monthly on the " + item["repeat_monthly"];
    } else if (item["repeat_mode"] == "4") {
      result += "Yearly on the " +
          item["repeat_yearly_monthly"] +
          " of " +
          months[int.parse(item["repeat_yearly"])];
    } else {
      if (item["repeat_custom_mode"] == "1") {
        result += "every " + item["custom_interval"] + " days ";
      } else if (item["repeat_custom_mode"] == "2") {
        result += "every " +
            item["custom_interval"] +
            " weeks on " +
            weeksDay[int.parse(item["repeat_weekly"])];
      } else if (item["repeat_custom_mode"] == "3") {
        result += "every " +
            item["custom_interval"] +
            " months on " +
            item["repeat_monthly"];
      } else if (item["repeat_custom_mode"] == "4") {
        result += "every " +
            item["custom_interval"] +
            " years on " +
            item["repeat_yearly_monthly"] +
            " of " +
            months[int.parse(item["repeat_yearly"])];
      }
    }
    return result;
  }

  String getPreviousNext(dynamic item) {
    String result = "Previous: ";
    if (item["previous_email"] == null) {
      result += " --------- ";
    } else {
      result += item["previous_email"];
    }
    result += " Next: ";
    if (item["repeat_end_mode"] == "1" &&
        int.parse(item["end_emails_count"]) <=
            int.parse(item["current_email_count"])) {
      result += "---------";
    } else if (item["repeat_end_mode"] == "2" &&
        item["next_email"]
                .toString()
                .compareTo(item["end_repeat_day"].toString()) ==
            1) {
      result += "---------";
    } else {
      result += item["next_email"];
    }
    return result;
  }

  String getEnds(dynamic item) {
    String result = "Ends: " + endMode[int.parse(item["repeat_end_mode"]) - 1];
    if (item["repeat_end_mode"] == "1") {
      result += " " + item["end_emails_count"] + " Emails";
    } else if (item["repeat_end_mode"] == "2") {
      result += " on " + item["end_repeat_day"];
    }
    return result;
  }

  Widget getStatusBadge(dynamic item) {
    String txtStatus;
    var badgeColor;
    if (item["repeat_end_mode"] == "1" &&
        int.parse(item["end_emails_count"]) <=
            int.parse(item["current_email_count"])) {
      txtStatus = "Complete";
      badgeColor = Color(0xffff3547);
    } else if (item["repeat_end_mode"] == "2" &&
        item["next_email"]
                .toString()
                .compareTo(item["end_repeat_day"].toString()) ==
            1) {
      txtStatus = "Complete";
      badgeColor = Color(0xffff3547);
    } else {
      txtStatus = "Active";
      badgeColor = Color(0xff00c851);
    }
    return Badge(
      badgeColor: badgeColor,
      shape: BadgeShape.square,
      toAnimate: false,
      // borderRadius: 8.0,
      padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
      badgeContent: Text(
        txtStatus,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rowDateRange = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 10.0),
              child: DateTimeField(
                format: format,
                controller: _txtStartDate,
                onChanged: (value) {
                  if (startDate != _txtStartDate.text) {
                    refreshRecurrings();
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
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 10.0),
              child: DateTimeField(
                format: format,
                controller: _txtEndDate,
                onChanged: (value) {
                  if (endDate != _txtEndDate.text) {
                    refreshRecurrings();
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
    return Scaffold(
      appBar: AppBar(
        title: widget.userInfo.invoiceOn == "YES"
            ? Text("Recurring Email & Invoice")
            : Text("Recurring Email"),
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
              rowDateRange,
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredSubs != null ? filteredSubs.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 9,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text("To:"),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: InkWell(
                                                child: Padding(
                                                  padding: EdgeInsets.all(2.0),
                                                  child: Text(
                                                    filteredSubs[index]
                                                            ["receiver_name"] +
                                                        " (" +
                                                        filteredSubs[index]
                                                            ["receiver_email"] +
                                                        ")",
                                                    style: normalStyle.copyWith(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                onTap: () {
                                                  _gotoContacPage(
                                                      filteredSubs[index],
                                                      context);
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text("From:"),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text(
                                                    filteredSubs[index]
                                                        ["sender"],
                                                    style: normalStyle),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text("Template:"),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text(
                                                    filteredSubs[index]
                                                        ["tmp_name"],
                                                    style: normalStyle.copyWith(
                                                        color: Colors.red)),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text("Schedule:"),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2.0),
                                                      child: Text(
                                                        getScheduleText(
                                                            filteredSubs[
                                                                index]),
                                                        style: normalStyle
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2.0),
                                                      child: Text(
                                                          "First: " +
                                                              filteredSubs[
                                                                      index][
                                                                  "first_create_on"] +
                                                              " " +
                                                              filteredSubs[
                                                                          index]
                                                                      [
                                                                      "sending_time"]
                                                                  .toString()
                                                                  .substring(
                                                                      0, 5),
                                                          style: normalStyle),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2.0),
                                                      child: Text(getEnds(
                                                          filteredSubs[index])),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2.0),
                                                      child: Text(
                                                        getPreviousNext(
                                                            filteredSubs[
                                                                index]),
                                                        style: normalStyle
                                                            .copyWith(
                                                                color: Colors
                                                                    .blue),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text("Count:"),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Text(
                                                    filteredSubs[index]
                                                        ["current_email_count"],
                                                    style: normalStyle),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: getStatusBadge(
                                                    filteredSubs[index]),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(""),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              child: filteredSubs[index]
                                                          ["invoice_tmp"] ==
                                                      "1"
                                                  ? Badge(
                                                      badgeColor:
                                                          Colors.indigoAccent,
                                                      shape: BadgeShape.square,
                                                      toAnimate: false,
                                                      // borderRadius: 8.0,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10.0,
                                                              3.0,
                                                              10.0,
                                                              3.0),
                                                      badgeContent: Text(
                                                        "Invoice",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                  : Text(""),
                                              flex: 2,
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            delRecurring(filteredSubs[index]);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.blueAccent,
                                            size: 20.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 60.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            editRecurring(
                                                filteredSubs[index], context);
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.blueAccent,
                                            size: 20.0,
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
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

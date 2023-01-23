import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';

import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hemailer/utils/agents_search_dlg.dart';

class ScheduleMessageScreen extends StatefulWidget {
  final UserModel userInfo;
  ScheduleMessageScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _ScheduleMessageScreenState createState() => _ScheduleMessageScreenState();
}

class _ScheduleMessageScreenState extends State<ScheduleMessageScreen> {
  bool _progressBarActive = false;
  TextEditingController _oTimeMo = new TextEditingController();
  TextEditingController _cTimeMo = new TextEditingController();
  TextEditingController _oTimeTu = new TextEditingController();
  TextEditingController _cTimeTu = new TextEditingController();
  TextEditingController _oTimeWe = new TextEditingController();
  TextEditingController _cTimeWe = new TextEditingController();
  TextEditingController _oTimeTh = new TextEditingController();
  TextEditingController _cTimeTh = new TextEditingController();
  TextEditingController _oTimeFr = new TextEditingController();
  TextEditingController _cTimeFr = new TextEditingController();
  TextEditingController _oTimeSa = new TextEditingController();
  TextEditingController _cTimeSa = new TextEditingController();
  TextEditingController _oTimeSu = new TextEditingController();
  TextEditingController _cTimeSu = new TextEditingController();
  TextEditingController _txtToMessage = new TextEditingController();
  TextEditingController _txtMessage = new TextEditingController();
  TextEditingController _respondMessage = new TextEditingController();
  List<dynamic> selectedContacts = new List<dynamic>();
  List<dynamic> allAgents = new List<dynamic>();
  var newDateTime;
  var selTime;
  var timeList = [
    {"time": "30 seconds", "value": 30},
    {"time": "1 minute", "value": 60},
    {"time": "1:30", "value": 90}
  ];
  @override
  void initState() {
    super.initState();

    // getAgents();
    getSchedule();
  }

  // void getAgents() {
  //   final body = {
  //     "id": widget.userInfo.id,
  //   };

  //   setState(() {
  //     _progressBarActive = true;
  //   });
  //   ApiService.getAgents(body).then((response) {
  //     setState(() {
  //       allAgents = response;
  //       _progressBarActive = false;
  //     });
  //     print(allAgents);
  //   });
  // }
  void getSchedule() {
    final body = {
      "id": widget.userInfo.id,
    };

    setState(() {
      _progressBarActive = true;
    });
    ApiService.getSchedule(body).then((response) {
      setState(() {
        if (response.length == 0) {
          setState(() {
            _txtMessage.text = "Sorry. we are closed leave us a message.";
          });
        } else {
          setState(() {
            _txtMessage.text = response[0]['message'];
            _oTimeMo.text =
                response[0]['oTimeMo'] != '0' ? response[0]['oTimeMo'] : '';
            _cTimeMo.text =
                response[0]['cTimeMo'] != '0' ? response[0]['cTimeMo'] : '';
            _oTimeTu.text =
                response[0]['oTimeTu'] != '0' ? response[0]['oTimeTu'] : '';
            _cTimeTu.text =
                response[0]['cTimeTu'] != '0' ? response[0]['cTimeTu'] : '';
            _oTimeWe.text =
                response[0]['oTimeWe'] != '0' ? response[0]['oTimeWe'] : '';
            _cTimeWe.text =
                response[0]['cTimeWe'] != '0' ? response[0]['cTimeWe'] : '';
            _oTimeTh.text =
                response[0]['oTimeTh'] != '0' ? response[0]['oTimeTh'] : '';
            _cTimeTh.text =
                response[0]['cTimeTh'] != '0' ? response[0]['cTimeTh'] : '';
            _oTimeFr.text =
                response[0]['oTimeFr'] != '0' ? response[0]['oTimeFr'] : '';
            _cTimeFr.text =
                response[0]['cTimeFr'] != '0' ? response[0]['cTimeFr'] : '';
            _oTimeSa.text =
                response[0]['oTimeSa'] != '0' ? response[0]['oTimeSa'] : '';
            _cTimeSa.text =
                response[0]['cTimeSa'] != '0' ? response[0]['cTimeSa'] : '';
            _oTimeSu.text =
                response[0]['oTimeSu'] != '0' ? response[0]['oTimeSu'] : '';
            _cTimeSu.text =
                response[0]['cTimeSu'] != '0' ? response[0]['cTimeSu'] : '';
          });
        }
        getRespond();
      });
    });
  }

  void getRespond() {
    final body = {
      "id": widget.userInfo.id,
    };

    ApiService.getRespond(body).then((response) {
      setState(() {
        if (response != null) {
          _respondMessage.text = response[0]['respond_message'];
          if (response[0]['after_time'] != "0") {
            selTime = response[0]['after_time'];
          }
        }

        _progressBarActive = false;
      });
    });
  }

  void updateSchedule() {
    if (_txtMessage == null || _txtMessage.text == '') {
      showErrorToast("Please fill the closed message");
    } else {
      // String _agentNames = '';
      // for (var i = 0; i < selectedContacts.length; i++) {
      //   _agentNames = _agentNames + selectedContacts[i]['id'] + '#';
      // }
      final body = {
        "oTimeMo": _oTimeMo.text,
        "cTimeMo": _cTimeMo.text,
        "oTimeTu": _oTimeTu.text,
        "cTimeTu": _cTimeTu.text,
        "oTimeWe": _oTimeWe.text,
        "cTimeWe": _cTimeWe.text,
        "oTimeTh": _oTimeTh.text,
        "cTimeTh": _cTimeTh.text,
        "oTimeFr": _oTimeFr.text,
        "cTimeFr": _cTimeFr.text,
        "oTimeSa": _oTimeSa.text,
        "cTimeSa": _cTimeSa.text,
        "oTimeSu": _oTimeSu.text,
        "cTimeSu": _cTimeSu.text,
        "message": _txtMessage.text,
        "id": widget.userInfo.id,
        "respond_message": _respondMessage.text,
        "after_time": selTime == null ? 0 : selTime,
      };
      print(body);
      setState(() {
        _progressBarActive = true;
      });
      ApiService.updateSchedule(body).then((response) {
        print(response);
        if (response != null && response['status']) {
          getSchedule();
          showSuccessToast("Successfully updated");
        } else {
          setState(() {
            _progressBarActive = false;
          });
          showErrorToast(response['err_code']);
        }
      });
    }
  }

  void addToContacts(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContactSearchDlg(
              contacts: allAgents,
              selectedContacts: selectedContacts,
              onSelectedContactsListChanged: (contacts) {
                selectedContacts = contacts;
                if (selectedContacts.length > 0) {
                  _txtToMessage.text = selectedContacts.length > 1
                      ? selectedContacts[0]['username'] +
                          " + " +
                          (selectedContacts.length - 1).toString() +
                          " contacts"
                      : selectedContacts[0]['username'];
                } else {
                  _txtToMessage.text = "";
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        maxLines: 8,
        maxLength: 250,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 2)),
          labelText: 'Message',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtMessage,
      ),
    );
    final afterTime = Container(
      child: DropdownButton(
        items: timeList
            .map((var item) => DropdownMenuItem<String>(
                child: Text(item['time']), value: item['value'].toString()))
            .toList(),
        value: selTime,
        hint: Text("Select after time"),
        onChanged: (value) {
          setState(() {
            selTime = value;
          });
          print(selTime.runtimeType);
        },
      ),
    );

    final respondMessage = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        maxLines: 8,
        maxLength: 250,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 2)),
          labelText: 'Respond Message',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _respondMessage,
      ),
    );
    final toMessageRow = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 6.0, 6.0, 0.0),
            child: TextField(
              enabled: false,
              style: normalStyle,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                labelText: 'To',
                contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
              ),
              controller: _txtToMessage,
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 6.0, 6.0, 0.0),
              child: IconButton(
                  icon: Icon(
                    Icons.person_add,
                    size: 35.0,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    addToContacts(context);
                  }),
            )),
      ],
    );
    final scheduleTitle = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Day of The Week",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Opend Time",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Closed Time",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ))),
      ],
    );
    final scheduleTimeMo = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Monday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeMo,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeMo.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeMo,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeMo.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeTu = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Tuesday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeTu,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeTu.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeTu,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeTu.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeWe = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Wednesday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeWe,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeWe.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeWe,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeWe.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeTh = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Thursday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeTh,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeTh.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeTh,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeTh.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeFr = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Friday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeFr,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeFr.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeFr,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeFr.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeSa = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Saturday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeSa,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeSa.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeSa,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeSa.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final scheduleTimeSu = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
                child: Text(
                  "Sunday",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff00c851), fontSize: 20),
                ))),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'OpendTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _oTimeSu,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _oTimeSu.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 6.0, 10.0, 15.0),
              child: TextField(
                style: normalStyle,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'ClosedTime',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                ),
                controller: _cTimeSu,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  var _time;

                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15);
                  } else {
                    _time = '';
                  }
                  setState(() {
                    _cTimeSu.text = _time;
                  });
                  print(_time);
                },
              ),
            )),
      ],
    );
    final btnRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(50.0),
          child: FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            splashColor: Colors.blueAccent,
            onPressed: () {
              updateSchedule();
            },
            child: Text(
              "Save",
              style: normalStyle,
            ),
          ),
        )),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(50.0),
          child: FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            splashColor: Colors.blueAccent,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: normalStyle,
            ),
          ),
        )),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Schedule Message"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Center(
                  child: Column(
                children: <Widget>[
                  afterTime,
                  respondMessage,
                  scheduleTitle,
                  SizedBox(height: 5),
                  scheduleTimeMo,
                  scheduleTimeTu,
                  scheduleTimeWe,
                  scheduleTimeTh,
                  scheduleTimeFr,
                  scheduleTimeSa,
                  scheduleTimeSu,
                  // dateTime,
                  // toMessageRow,
                  SizedBox(height: 20),
                  notesRow,
                  Divider(),
                  btnRow
                ],
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

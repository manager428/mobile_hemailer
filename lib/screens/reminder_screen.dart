import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/notes/add_notes_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'contacts/detail_screen.dart';

class ReminderScreen extends StatefulWidget {
  final UserModel userInfo;
  ReminderScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<dynamic> filteredSubs = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> allSubs;
  bool _progressBarActive = false;
  bool _bReminder = true;
  @override
  void initState() {
    super.initState();
    refreshReminders(true);
  }

  void refreshReminders(bool reminder) {
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    if (reminder) {
      ApiService.getReminders(body).then((response) {
        setState(() {
          allSubs = response;
          _progressBarActive = false;
        });
        filterSearchResults(txtSearch.text);
      });
    } else {
      ApiService.getImportants(body).then((response) {
        setState(() {
          allSubs = response;
          _progressBarActive = false;
        });
        filterSearchResults(txtSearch.text);
      });
    }
  }

  void _gotoContacPage(dynamic reminderInfo, BuildContext context) {
    final body = {
      "user_id": widget.userInfo.id,
      "contact_id": reminderInfo["email_id"]
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

  Future<void> delReminder(dynamic reminderInfo) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "note_id": reminderInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      if (_bReminder) {
        ApiService.deleteReminder(body).then((response) {
          setState(() {
            allSubs.remove(reminderInfo);
            filteredSubs.remove(reminderInfo);
            _progressBarActive = false;
          });
        });
      } else {
        ApiService.deleteImportant(body).then((response) {
          setState(() {
            allSubs.remove(reminderInfo);
            filteredSubs.remove(reminderInfo);
            _progressBarActive = false;
          });
        });
      }
    }
  }

  void editReminder(dynamic reminderInfo, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddScreen(
          noteInfo: reminderInfo,
          contactInfo: reminderInfo["contactInfo"],
          userInfo: widget.userInfo,
        ),
      ),
    ).then((val) {
      refreshReminders(_bReminder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Reminder"),
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
                padding: const EdgeInsets.all(1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Important",
                      style: normalStyle,
                      textAlign: TextAlign.right,
                    ),
                    Switch(
                      value: _bReminder,
                      onChanged: (value) {
                        refreshReminders(value);
                        setState(() {
                          _bReminder = value;
                        });
                      },
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    ),
                    Text(
                      "Reminder",
                      style: normalStyle,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 1.0),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                flex: 9,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: CircleAvatar(
                                              child: Text(
                                            filteredSubs[index]["contactInfo"]
                                                    ["name"][0]
                                                .toString()
                                                .toUpperCase(),
                                            style: normalStyle,
                                          )),
                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 2.0),
                                                child: InkWell(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      filteredSubs[index]
                                                              ["contactInfo"]
                                                          ["name"],
                                                      style:
                                                          normalStyle.copyWith(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _gotoContacPage(
                                                        filteredSubs[index],
                                                        context);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(0.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    filteredSubs[index]
                                                            ["contactInfo"]
                                                        ["email"],
                                                    style: normalStyle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: filteredSubs[index]
                                                      ["note_important"] ==
                                                  "YES"
                                              ? Icon(Icons.flag,
                                                  color: Colors.red, size: 30.0)
                                              : Text(""),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          filteredSubs[index]["title"],
                                          style: normalStyle,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 5,
                                          child: Row(
                                            children: <Widget>[
                                              _bReminder == false
                                                  ? Text("")
                                                  : Icon(Icons.alarm_on,
                                                      color: _bReminder
                                                          ? Colors.red
                                                          : Colors.black),
                                              _bReminder == false
                                                  ? Text(filteredSubs[index]
                                                      ["start"])
                                                  : Text(
                                                      " " +
                                                          filteredSubs[index]
                                                              ["schedule_day"] +
                                                          " " +
                                                          filteredSubs[index]
                                                              ["schedule_time"],
                                                      style:
                                                          normalStyle.copyWith(
                                                              color: _bReminder
                                                                  ? Colors
                                                                      .red[300]
                                                                  : Colors
                                                                      .black),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              delReminder(filteredSubs[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.blueAccent,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              editReminder(
                                                  filteredSubs[index], context);
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
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

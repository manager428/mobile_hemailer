import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/contacts/add_contacts_screen.dart';
import 'package:hemailer/screens/contacts/detail_screen.dart';
import 'package:hemailer/screens/expense/expense_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/search_option_dlg.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

class ContactsScreen extends StatefulWidget {
  final UserModel userInfo;
  ContactsScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> allContacts;
  List<dynamic> filteredContacts = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  bool _progressBarActive = false;
  bool _bNewSub = false;
  bool _bRecurring = false;
  bool _bCancelled = false;
  bool _bFlag = false;
  bool _bUnSub = false;
  bool _bOnline = false;
  bool _bCustomize = false;

  String startDate = "";
  String endDate = "";
  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();

  List<dynamic> selectedOption = new List<dynamic>();
  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  void refreshContacts() {
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContacts(body).then((response) {
      setState(() {
        allContacts = response["contacts"];
        _progressBarActive = false;
        endDate = format.format(now);
        startDate = response["start_date"];
      });
      filterSearchResults(txtSearch.text);
    });
  }

  Future<void> deleteContact(dynamic contactInfo, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "email_id": contactInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteContact(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
            filteredContacts.remove(contactInfo);
            allContacts.remove(contactInfo);
          });
        }
      });
    }
  }

  void addContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContactAddScreen(contactInfo: null, userInfo: widget.userInfo),
      ),
    ).then((val) {
      refreshContacts();
    });
  }

  void expenseList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseScreen(userInfo: widget.userInfo),
      ),
    );
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      allContacts.forEach((item) {
        if (item["name"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["email"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["phone"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["notes"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["address"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredContacts.clear();
        filteredContacts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredContacts.clear();
        filteredContacts.addAll(allContacts);
      });
    }
  }

  void showOptionDlg(BuildContext context) {
    selectedOption.clear();
    selectedOption.add(startDate);
    selectedOption.add(endDate);
    selectedOption.add(_bNewSub);
    selectedOption.add(_bRecurring);
    selectedOption.add(_bCancelled);
    selectedOption.add(_bFlag);
    selectedOption.add(_bUnSub);
    selectedOption.add(_bOnline);
    selectedOption.add(_bCustomize);
    showDialog(
        context: context,
        builder: (context) {
          return SearchOptionDlg(
              selectedOption: selectedOption,
              onSelectedOptionChanged: (tmpSelected) {
                selectedOption = tmpSelected;
                startDate = selectedOption[0];
                endDate = selectedOption[1];
                _bNewSub = selectedOption[2];
                _bRecurring = selectedOption[3];
                _bCancelled = selectedOption[4];
                _bFlag = selectedOption[5];
                _bUnSub = selectedOption[6];
                _bOnline = selectedOption[7];
                _bCustomize = selectedOption[8];
                final body = {
                  "user_id": widget.userInfo.id,
                  "new_sub": _bNewSub ? "YES" : "NO",
                  "recurring": _bRecurring ? "YES" : "NO",
                  "cancelled": _bCancelled ? "YES" : "NO",
                  "flagged": _bFlag ? "YES" : "NO",
                  "unsubscribe": _bUnSub ? "YES" : "NO",
                  "online_chat": _bOnline ? "YES" : "NO",
                  "customize_on": _bCustomize ? "YES" : "NO",
                };
                setState(() {
                  _progressBarActive = true;
                });
                ApiService.getSearchContacts(body).then((response) {
                  setState(() {
                    allContacts = response["data"];
                    _progressBarActive = false;
                  });
                  filterSearchResults(txtSearch.text);
                });
              });
        });
  }

  Widget getEmailItem(dynamic contactInfo) {
    if (contactInfo["active"] == "NO") {
      return Text(
        contactInfo["email"],
        style: TextStyle(color: Colors.red),
      );
    } else if (contactInfo["cancel_subscriber"] == "YES") {
      return Text(
        contactInfo["email"],
        style: TextStyle(color: Color(0xFFda9305)),
      );
    } else {
      var days2ago = new DateTime.now().subtract(new Duration(days: 2));
      if (DateTime.parse(contactInfo["created_at"]).isAfter(days2ago)) {
        return Text(
          contactInfo["email"],
          style: TextStyle(color: Color(0xFF32CD32)),
        );
      }
    }
    return Text(contactInfo["email"]);
  }

  Widget getCircleAvatar(dynamic contactInfo) {
    if (int.parse(contactInfo["recurring_count"]) > 0 &&
        contactInfo["customize_on"] == "YES") {
      if (contactInfo["new_subscriber"] == "YES") {
        return CircleAvatar(
          radius: 23,
          backgroundColor: Colors.yellowAccent,
          child: CircleAvatar(
            radius: 21.5,
            backgroundColor: Colors.red,
            child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0x8800C851),
                child: Text(contactInfo["name"][0].toString().toUpperCase())),
          ),
        );
      } else {
        return CircleAvatar(
          radius: 23,
          backgroundColor: Colors.deepOrange,
          child: CircleAvatar(
            radius: 21.5,
            backgroundColor: Colors.red,
            child: CircleAvatar(
                radius: 20,
                child: Text(contactInfo["name"][0].toString().toUpperCase())),
          ),
        );
      }
    } else if (int.parse(contactInfo["recurring_count"]) > 0) {
      if (contactInfo["new_subscriber"] == "YES") {
        return CircleAvatar(
          radius: 21.5,
          backgroundColor: Colors.amber,
          child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x8800C851),
              child: Text(contactInfo["name"][0].toString().toUpperCase())),
        );
      } else {
        return CircleAvatar(
          radius: 21.5,
          backgroundColor: Colors.amber,
          child: CircleAvatar(
              radius: 20,
              child: Text(contactInfo["name"][0].toString().toUpperCase())),
        );
      }
    } else if (contactInfo["customize_on"] == "YES") {
      if (contactInfo["new_subscriber"] == "YES") {
        return CircleAvatar(
          radius: 21.5,
          backgroundColor: Colors.red,
          child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x8800C851),
              child: Text(contactInfo["name"][0].toString().toUpperCase())),
        );
      } else {
        return CircleAvatar(
          radius: 21.5,
          backgroundColor: Colors.red,
          child: CircleAvatar(
              radius: 20,
              child: Text(contactInfo["name"][0].toString().toUpperCase())),
        );
      }
    } else {
      if (contactInfo["new_subscriber"] == "YES") {
        return CircleAvatar(
            backgroundColor: Color(0x8800C851),
            child: Text(contactInfo["name"][0].toString().toUpperCase()));
      } else {
        return CircleAvatar(
            child: Text(contactInfo["name"][0].toString().toUpperCase()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
      ),
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        userInfo: widget.userInfo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addContact(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        controller: txtSearch,
                        decoration: InputDecoration(
                            labelText: "Search",
                            hintText: "Search",
                            contentPadding: EdgeInsets.all(0.0),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)))),
                      ),
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
                              Icons.find_replace,
                              size: 25.0,
                            ),
                            color: Colors.blue,
                            onPressed: () {
                              showOptionDlg(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Material(
                      color: Colors.white,
                      child: Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                            color: Colors.white,
                            shape: CircleBorder(
                                side:
                                    BorderSide(color: Colors.red, width: 1.4)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.attach_money,
                              size: 30.0,
                            ),
                            color: Colors.redAccent,
                            onPressed: () {
                              expenseList(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: filteredContacts != null
                          ? filteredContacts.length
                          : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Text(filteredContacts[index]["name"]),
                                ),
                                Visibility(
                                    visible: filteredContacts[index]
                                                ["note_important"] !=
                                            "0"
                                        ? true
                                        : false,
                                    child: Icon(
                                      Icons.flag,
                                      color: Colors.red,
                                    )),
                              ],
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: getEmailItem(filteredContacts[index]),
                                ),
                                Visibility(
                                    visible: filteredContacts[index]
                                                ["note_important"] !=
                                            "0"
                                        ? true
                                        : false,
                                    child: Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0))),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              8.0, 1.0, 8.0, 1.0),
                                          child: Text(
                                            filteredContacts[index]
                                                ["note_important"],
                                            style: normalStyle.copyWith(
                                                color: Colors.white,
                                                fontSize: 12.0),
                                          ),
                                        ))),
                              ],
                            ),
                            leading: getCircleAvatar(filteredContacts[index]),
                            trailing: InkWell(
                              onTap: () {
                                deleteContact(filteredContacts[index], context);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.blueAccent,
                                size: 20.0,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactDetailScreen(
                                    contactInfo: filteredContacts[index],
                                    userInfo: widget.userInfo,
                                    allContacts: allContacts,
                                  ),
                                ),
                              ).then((val) {
                                refreshContacts();
                              });
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

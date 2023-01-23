import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SubscriberScreen extends StatefulWidget {
  final UserModel userInfo;
  SubscriberScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _SubscriberScreenState createState() => _SubscriberScreenState();
}

class _SubscriberScreenState extends State<SubscriberScreen> {
  List<dynamic> filteredSubs = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> allSubs;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getSubscribers(body).then((response) {
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
        if (item["name"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["email"]
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

  List<Widget> _createItem(dynamic subInfo) {
    List<Widget> noteList = new List<Widget>();
    noteList.add(Padding(
        padding: EdgeInsets.fromLTRB(6.0, 3.0, 0.0, 0.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              "name: " + subInfo["name"],
              style: normalStyle.copyWith(color: Colors.blue, fontSize: 18),
            ))));
    noteList.add(Padding(
        padding: EdgeInsets.fromLTRB(6.0, 3.0, 0.0, 0.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              "email: " + subInfo["email"],
              style: normalStyle.copyWith(color: Colors.blue, fontSize: 17),
            ))));
    String extraNotes = subInfo["notes"];
    List<String> fieldList = extraNotes.split(",");
    for (int i = 0; i < fieldList.length - 1; i++) {
      noteList.add(Padding(
          padding: EdgeInsets.fromLTRB(6.0, 3.0, 0.0, 0.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                fieldList[i],
                style: normalStyle,
              ))));
    }
    if (widget.userInfo.userLevel == "Super Admin") {
      noteList.add(Padding(
          padding: EdgeInsets.fromLTRB(6.0, 3.0, 0.0, 0.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                "user name: " + subInfo["user_name"],
                style: normalStyle,
              ))));
    }

    return noteList;
  }

  Future<void> deleteSub(dynamic subInfo, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "sub_id": subInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteContactSub(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            allSubs.remove(subInfo);
            _progressBarActive = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opt-in Subscriber"),
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
                      labelText: "Search",
                      hintText: "Search",
                      contentPadding: EdgeInsets.all(0.0),
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
                                    flex: 8,
                                    child: Column(
                                        children:
                                            _createItem(filteredSubs[index]))),
                                Expanded(
                                  flex: 2,
                                  child: Visibility(
                                    visible: filteredSubs[index]["user_id"] ==
                                            widget.userInfo.id
                                        ? true
                                        : false,
                                    child: InkWell(
                                      onTap: () {
                                        deleteSub(filteredSubs[index], context);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.blueAccent,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                )
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

import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ContactSubScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  ContactSubScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _ContactSubScreenState createState() => _ContactSubScreenState();
}

class _ContactSubScreenState extends State<ContactSubScreen> {
  List<dynamic> allSubs;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    final body = {
      "user_id": widget.userInfo.id,
      "name": widget.contactInfo["name"],
      "email": widget.contactInfo["email"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContactSubs(body).then((response) {
      setState(() {
        allSubs = response;
        _progressBarActive = false;
      });
    });
  }

  List<Widget> _createItem(dynamic subInfo) {
    List<Widget> noteList = new List<Widget>();
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
      backgroundColor: Colors.white,
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
                      shrinkWrap: true,
                      itemCount: allSubs != null ? allSubs.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            allSubs[index]["created_at"],
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: _createItem(allSubs[index]),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      deleteSub(allSubs[index], context);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.blueAccent,
                                      size: 20.0,
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

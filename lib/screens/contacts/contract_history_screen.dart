import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ContractHitoryScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  ContractHitoryScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _ContractHitoryScreenState createState() => _ContractHitoryScreenState();
}

class _ContractHitoryScreenState extends State<ContractHitoryScreen> {
  List<dynamic> allSubs;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    final body = {
      "user_id": widget.userInfo.id,
      "email_id": widget.contactInfo["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContractHistory(body).then((response) {
      setState(() {
        allSubs = response;
        _progressBarActive = false;
      });
    });
  }

  Future<void> deleteItem(dynamic subInfo, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "hist_id": subInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteContractHistory(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            allSubs.remove(subInfo);
            _progressBarActive = false;
          });
        }
      });
    }
  }

  Widget getBadgeItem(dynamic histInfo) {
    var badgeColor;
    String txtStatus;
    if (histInfo["sign_status"] == "YES") {
      txtStatus = "signed";
      badgeColor = Color(0xffdc3545);
    } else {
      if (histInfo["opened_status"] == "YES") {
        txtStatus = "opened";
        badgeColor = Color(0xff00c851);
      } else {
        if (histInfo["received_status"] == "YES") {
          txtStatus = "received";
          badgeColor = Color(0xff33b5e5);
        } else {
          txtStatus = "sent";
          badgeColor = Color(0xff007bff);
        }
      }
    }
    return Badge(
      badgeColor: badgeColor,
      shape: BadgeShape.square,
      toAnimate: false,
      // borderRadius: 8.0,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      badgeContent: Text(txtStatus, style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Sent Contracts"),
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
                          //                           <-- Card widget
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 9,
                                  child: Column(
                                    children: <Widget>[
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "TEMPLATE: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["tmp_name"],
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "STATUS: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                            flex: 6,
                                            child: Container(
                                              child:
                                                  getBadgeItem(allSubs[index]),
                                            )),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "SENT AT: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["created_at"],
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "RECEIVED AT: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["received_at"] !=
                                                    null
                                                ? allSubs[index]["received_at"]
                                                : "",
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "OPENED AT: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["opened_at"] != null
                                                ? allSubs[index]["opened_at"]
                                                : "",
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "SIGNED AT: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["signed_at"] != null
                                                ? allSubs[index]["signed_at"]
                                                : "",
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "IP ADRESS: ",
                                            style: normalStyle.copyWith(
                                                color: Colors.blue),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Text(
                                            allSubs[index]["ip_adress"] != null
                                                ? allSubs[index]["ip_adress"]
                                                : "",
                                            style: normalStyle,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      deleteItem(allSubs[index], context);
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

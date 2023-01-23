import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SalesHitoryScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  SalesHitoryScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _SalesHitoryScreenState createState() => _SalesHitoryScreenState();
}

class _SalesHitoryScreenState extends State<SalesHitoryScreen> {
  List<dynamic> allSubs;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshFunnelHistory();
  }

  void refreshFunnelHistory() {
    final body = {
      "user_id": widget.userInfo.id,
      "email_id": widget.contactInfo["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getSalesFunnelHistory(body).then((response) {
      setState(() {
        allSubs = response;
        _progressBarActive = false;
      });
    });
  }

  Future<void> deleteItem(
      String funnelID, String funnelCreatedAt, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "funn_id": funnelID,
        "receiver_id": widget.contactInfo["id"],
        "created_at": funnelCreatedAt,
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteSalesFunnelHistory(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
          });
          refreshFunnelHistory();
        }
      });
    }
  }

  Widget getBadgeItem(dynamic histInfo) {
    var badgeColor;
    String txtStatus;

    if (histInfo["opened_status"] == "YES") {
      txtStatus = "opened";
      badgeColor = Color(0xff00c851);
    } else {
      if (histInfo["received_status"] == "YES") {
        txtStatus = "received";
        badgeColor = Color(0xff33b5e5);
      } else {
        if (histInfo["sent_schedule_status"] == "SEND") {
          txtStatus = "sent";
          badgeColor = Color(0xff007bff);
        } else {
          if (histInfo["receiver_active"] == "NO") {
            txtStatus = "disabled";
            badgeColor = Color(0xff8a8a8a);
          } else {
            if (histInfo["active"] == "NO") {
              txtStatus = "stopped";
              badgeColor = Color(0xffdc3545);
            } else {
              txtStatus = "schedule";
              badgeColor = Color(0xffffc107);
            }
          }
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

  List<Widget> getSaleHistItem() {
    String prevFunnelID = "0";
    String prevFunnelName = "";
    String prevCreatedAt = "";
    bool _bFirst = true;
    List<Widget> tmpItems = new List<Widget>();
    List<Widget> funnelItems = new List<Widget>();
    if (allSubs != null) {
      for (var funnel in allSubs) {
        if (prevFunnelID != funnel["funnel_id"] ||
            prevCreatedAt != funnel["created_at"]) {
          if (!_bFirst) {
            funnelItems.add(getOneFunnelItem(
                tmpItems, prevFunnelID, prevFunnelName, prevCreatedAt));
          }
          _bFirst = false;
          tmpItems.clear();
          tmpItems.add(getOneTmpItem(funnel));
          prevFunnelID = funnel["funnel_id"];
          prevFunnelName = funnel["funnel_name"];
          prevCreatedAt = funnel["created_at"];
        } else {
          tmpItems.add(getOneTmpItem(funnel));
        }
      }
      if (allSubs.length > 0) {
        funnelItems.add(getOneFunnelItem(
            tmpItems, prevFunnelID, prevFunnelName, prevCreatedAt));
      }
    }

    return funnelItems;
  }

  Widget getOneFunnelItem(List<Widget> tmpItems, String funnelID,
      String funnelName, String funnelCreatedAt) {
    return Card(
      //                           <-- Card widget
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    "Funnel Name: ",
                    style: normalStyle.copyWith(color: Colors.red),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    funnelName,
                    style: normalStyle.copyWith(color: Colors.blue),
                  ),
                ),
              ]),
              SizedBox(
                height: 3.0,
              ),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    "Created At: ",
                    style: normalStyle.copyWith(color: Colors.red),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    funnelCreatedAt,
                    style: normalStyle,
                  ),
                ),
              ]),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: tmpItems,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        deleteItem(funnelID, funnelCreatedAt, context);
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
            ],
          )),
    );
  }

  Widget getOneTmpItem(dynamic tmpHistInfo) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Row(children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              "TEMPLATE: ",
              style: normalStyle.copyWith(color: Colors.blue),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              tmpHistInfo["tmp_name"],
              style: normalStyle,
            ),
          ),
        ]),
        SizedBox(
          height: 1.0,
        ),
        Row(children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              "STATUS: ",
              style: normalStyle.copyWith(color: Colors.blue),
            ),
          ),
          Flexible(
              flex: 6,
              child: Container(
                child: getBadgeItem(tmpHistInfo),
              )),
        ]),
        SizedBox(
          height: 1.0,
        ),
        Row(children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              "SENT AT: ",
              style: normalStyle.copyWith(color: Colors.blue),
            ),
          ),
          Flexible(
            flex: 6,
            child: Text(
              tmpHistInfo["created_at"],
              style: normalStyle,
            ),
          ),
        ]),
        SizedBox(
          height: 1.0,
        ),
        Row(children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              "RECEIVED AT: ",
              style: normalStyle.copyWith(color: Colors.blue),
            ),
          ),
          Flexible(
            flex: 6,
            child: Text(
              tmpHistInfo["received_at"] != null
                  ? tmpHistInfo["received_at"]
                  : "",
              style: normalStyle,
            ),
          ),
        ]),
        SizedBox(
          height: 1.0,
        ),
        Row(children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              "OPENED AT: ",
              style: normalStyle.copyWith(color: Colors.blue),
            ),
          ),
          Flexible(
            flex: 6,
            child: Text(
              tmpHistInfo["opened_at"] != null ? tmpHistInfo["opened_at"] : "",
              style: normalStyle,
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Sent Sales Funnel"),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: getSaleHistItem(),
          ),
        ),
      ),
    );
  }
}

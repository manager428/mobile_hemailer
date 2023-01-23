import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_user_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final dynamic contactInfo;
  final UserModel userInfo;
  UserDetailScreen({Key key, @required this.contactInfo, this.userInfo})
      : super(key: key);
  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  dynamic contactCurrentInfo;
  bool _bUnsubscribe,
      _bSelfDestruct,
      _bChangeEmail,
      _bSalesFunnel,
      _bContracts,
      _bOptForm,
      _bChatOn,
      _bOnlineChat,
      _bInvoice,
      _bStatus,
      _bPaymentGateway,
      _bAnalytics;
  @override
  void initState() {
    super.initState();
    setState(() {
      contactCurrentInfo = widget.contactInfo;
      _bUnsubscribe = contactCurrentInfo["unsubscribe"] == "YES" ? true : false;
      _bSelfDestruct =
          contactCurrentInfo["self_destruct"] == "YES" ? true : false;
      _bChangeEmail =
          contactCurrentInfo["email_change"] == "YES" ? true : false;
      _bSalesFunnel =
          contactCurrentInfo["sales_funnel"] == "YES" ? true : false;
      _bContracts =
          contactCurrentInfo["contracts_sign"] == "YES" ? true : false;
      _bOptForm = contactCurrentInfo["optin_form"] == "YES" ? true : false;
      _bChatOn = contactCurrentInfo["chat_on"] == "YES" ? true : false;
      _bOnlineChat =
          contactCurrentInfo["onlinechat_on"] == "YES" ? true : false;
      _bInvoice = contactCurrentInfo["invoice_on"] == "YES" ? true : false;
      _bStatus = contactCurrentInfo["status"] == "Active" ? true : false;
      _bAnalytics = contactCurrentInfo["analytics_on"] == "YES" ? true : false;
      _bPaymentGateway =
          contactCurrentInfo["paymentgateway_on"] == "YES" ? true : false;
    });
  }

  void editUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserAddScreen(
            contactInfo: contactCurrentInfo, userInfo: widget.userInfo),
      ),
    ).then((val) {
      final body = {
        "id": contactCurrentInfo["id"],
      };
      ApiService.getOneUser(body).then((response) {
        setState(() {
          if (response != null) {
            contactCurrentInfo = response;
            _bUnsubscribe =
                contactCurrentInfo["unsubscribe"] == "YES" ? true : false;
            _bSelfDestruct =
                contactCurrentInfo["self_destruct"] == "YES" ? true : false;
            _bChangeEmail =
                contactCurrentInfo["email_change"] == "YES" ? true : false;
            _bSalesFunnel =
                contactCurrentInfo["sales_funnel"] == "YES" ? true : false;
            _bContracts =
                contactCurrentInfo["contracts_sign"] == "YES" ? true : false;
            _bOptForm =
                contactCurrentInfo["optin_form"] == "YES" ? true : false;
            _bChatOn = contactCurrentInfo["chat_on"] == "YES" ? true : false;
            _bOnlineChat =
                contactCurrentInfo["onlinechat_on"] == "YES" ? true : false;
            _bInvoice =
                contactCurrentInfo["invoice_on"] == "YES" ? true : false;
            _bStatus = contactCurrentInfo["status"] == "Active" ? true : false;
            _bAnalytics =
                contactCurrentInfo["analytics_on"] == "YES" ? true : false;
            _bPaymentGateway =
                contactCurrentInfo["paymentgateway_on"] == "YES" ? true : false;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _createControlItem(
        {IconData icon, String text, GestureTapCallback onTap}) {
      return Expanded(
          child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Material(
                child: InkWell(
                  onTap: onTap,
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(icon, color: Colors.white, size: 20.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
              child: Text(
                text,
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ));
    }

    Widget _createDetailItem({String txtKey, String txtValue}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 6),
            child: Text(
              txtKey,
              style: TextStyle(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
            child: SelectableText(
              txtValue,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      );
    }

    final switchRow1 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bUnsubscribe,
                      onChanged: null,
                      inactiveThumbColor:
                          _bUnsubscribe ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bUnsubscribe
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Unsubscribe"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bSelfDestruct,
                      onChanged: null,
                      inactiveThumbColor:
                          _bSelfDestruct ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bSelfDestruct
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Self Destruct"),
              ],
            ),
          ),
        ]);
    final switchRow2 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bChangeEmail,
                      onChanged: null,
                      inactiveThumbColor:
                          _bChangeEmail ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bChangeEmail
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Allow Change Email"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bInvoice,
                      onChanged: null,
                      inactiveThumbColor:
                          _bInvoice ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bInvoice
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Invoice"),
              ],
            ),
          ),
        ]);
    final switchRow3 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bSalesFunnel,
                      onChanged: null,
                      inactiveThumbColor:
                          _bSalesFunnel ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bSalesFunnel
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Sales Funnel"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bContracts,
                      onChanged: null,
                      inactiveThumbColor:
                          _bContracts ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bContracts
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Contracts"),
              ],
            ),
          ),
        ]);
    final switchRow4 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bOptForm,
                      onChanged: null,
                      inactiveThumbColor:
                          _bOptForm ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bOptForm
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Opt-in Forms"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bChatOn,
                      onChanged: null,
                      inactiveThumbColor:
                          _bChatOn ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bChatOn
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Chat"),
              ],
            ),
          ),
        ]);
    final switchRow5 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bOnlineChat,
                      onChanged: null,
                      inactiveThumbColor:
                          _bOnlineChat ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bOnlineChat
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Online Chat"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bStatus,
                      onChanged: null,
                      inactiveThumbColor:
                          _bStatus ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bStatus
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Status"),
              ],
            ),
          ),
        ]);
    final switchRow6 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Switch(
                      value: _bPaymentGateway,
                      onChanged: null,
                      inactiveThumbColor:
                          _bPaymentGateway ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bPaymentGateway
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Payment Gateway"),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Switch(
                      value: _bAnalytics,
                      onChanged: null,
                      inactiveThumbColor:
                          _bAnalytics ? Colors.blue : Colors.white70,
                      inactiveTrackColor: _bAnalytics
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade400,
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Analytics Website"),
              ],
            ),
          ),
        ]);
    final notesRow = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 6),
                child: Text(
                  "Notes",
                  style: TextStyle(),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
          child: Text(
            contactCurrentInfo["notes"],
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("User Detail"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editUser(context);
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Center(
                child: Column(
              children: <Widget>[
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: new NetworkImage(
                          contactCurrentInfo["photo_url"] == ""
                              ? baseURL + 'uploads/avatar/profile.jpg'
                              : baseURL + contactCurrentInfo["photo_url"]),
                    ),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(50.0)),
                    border: new Border.all(
                      color: contactCurrentInfo["status"] == "Active"
                          ? Colors.green
                          : Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    contactCurrentInfo["username"],
                    style: normalStyle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 6.0, 50.0, 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _createControlItem(
                          icon: Icons.chat_bubble,
                          text: "messages",
                          onTap: () {
                            launch("sms:" + contactCurrentInfo["phone"]);
                          }),
                      _createControlItem(
                          icon: Icons.call,
                          text: "call",
                          onTap: () {
                            launch("tel:" + contactCurrentInfo["phone"]);
                          }),
                      _createControlItem(
                          icon: Icons.mail,
                          text: "mail",
                          onTap: () {
                            launch("mailto:" +
                                contactCurrentInfo["email"] +
                                "?subject=&body=");
                          }),
                    ],
                  ),
                ),
                Divider(
                  thickness: 2.0,
                ),
                _createDetailItem(
                    txtKey: "Email", txtValue: contactCurrentInfo["email"]),
                Divider(),
                _createDetailItem(
                    txtKey: "Password",
                    txtValue: contactCurrentInfo["password"]),
                Divider(),
                _createDetailItem(
                    txtKey: "Phone", txtValue: contactCurrentInfo["phone"]),
                Divider(),
                _createDetailItem(
                    txtKey: "User Role", txtValue: contactCurrentInfo["level"]),
                Divider(),
                notesRow,
                Divider(),
                switchRow1,
                switchRow2,
                switchRow3,
                switchRow4,
                switchRow5,
                switchRow6,
                Divider(),
                _createDetailItem(
                    txtKey: "Created At",
                    txtValue: contactCurrentInfo["created_at"]),
                Divider(),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

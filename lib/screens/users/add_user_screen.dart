import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class UserAddScreen extends StatefulWidget {
  final dynamic contactInfo;
  final UserModel userInfo;
  UserAddScreen({Key key, @required this.contactInfo, this.userInfo})
      : super(key: key);
  @override
  _UserAddScreenState createState() => _UserAddScreenState();
}

class _UserAddScreenState extends State<UserAddScreen> {
  TextEditingController _txtName = new TextEditingController();
  TextEditingController _txtEmail = new TextEditingController();
  TextEditingController _txtPhone = new TextEditingController();
  TextEditingController _txtPassword = new TextEditingController();
  TextEditingController _txtNotes = new TextEditingController();
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
  bool _progressBarActive = false;

  List<DropdownMenuItem> itemsUserRole = [];
  List<String> userRoleText = ['User', 'Admin', 'Super Admin'];
  String userRole = "User";

  @override
  void initState() {
    super.initState();
    // edit page
    int length = userRoleText.length;
    if (widget.userInfo.userLevel == "Admin") {
      length = 1;
    }
    for (int i = 0; i < length; i++) {
      itemsUserRole.add(new DropdownMenuItem(
        child: new Text(userRoleText[i]),
        value: userRoleText[i],
      ));
    }
    if (widget.contactInfo != null) {
      initUser();
    } else {
      _bUnsubscribe = true;
      _bSelfDestruct = true;
      _bChangeEmail = true;
      _bSalesFunnel = false;
      _bContracts = false;
      _bOptForm = false;
      _bChatOn = false;
      _bOnlineChat = false;
      _bInvoice = false;
      _bPaymentGateway = false;
      _bAnalytics = false;
      _bStatus = true;
    }
  }

  void initUser() {
    _txtName.text = widget.contactInfo["username"];
    _txtEmail.text = widget.contactInfo["email"];
    _txtPhone.text = widget.contactInfo["phone"];
    _txtPassword.text = widget.contactInfo["password"];
    _txtNotes.text = widget.contactInfo["notes"];
    setState(() {
      _bUnsubscribe = widget.contactInfo["unsubscribe"] == "YES" ? true : false;
      _bSelfDestruct =
          widget.contactInfo["self_destruct"] == "YES" ? true : false;
      _bChangeEmail =
          widget.contactInfo["email_change"] == "YES" ? true : false;
      _bSalesFunnel =
          widget.contactInfo["sales_funnel"] == "YES" ? true : false;
      _bContracts =
          widget.contactInfo["contracts_sign"] == "YES" ? true : false;
      _bOptForm = widget.contactInfo["optin_form"] == "YES" ? true : false;
      _bChatOn = widget.contactInfo["chat_on"] == "YES" ? true : false;
      _bOnlineChat =
          widget.contactInfo["onlinechat_on"] == "YES" ? true : false;
      _bInvoice = widget.contactInfo["invoice_on"] == "YES" ? true : false;
      _bAnalytics = widget.contactInfo["analytics_on"] == "YES" ? true : false;
      _bPaymentGateway =
          widget.contactInfo["paymentgateway_on"] == "YES" ? true : false;
      _bStatus = widget.contactInfo["status"] == "Active" ? true : false;
    });
  }

  void saveUser(BuildContext context) {
    if (_txtName.text == "") {
      showErrorToast("Please fill name");
    } else if (_txtEmail.text == "") {
      showErrorToast("Please fill email");
    } else if (_txtPassword.text == "") {
      showErrorToast("Please fill password");
    } else {
      final body = {
        "id": widget.contactInfo == null ? "-1" : widget.contactInfo["id"],
        "user_id": widget.userInfo.id,
        "username": _txtName.text.trim(),
        "email": _txtEmail.text.trim(),
        "phone": _txtPhone.text.trim(),
        "password": _txtPassword.text.trim(),
        "notes": _txtNotes.text.trim(),
        "level": userRole,
        "status": _bStatus ? "Active" : "None",
        "self_destruct": _bSelfDestruct ? "YES" : "NO",
        "unsubscribe": _bUnsubscribe ? "YES" : "NO",
        "email_change": _bChangeEmail ? "YES" : "NO",
        "contracts_sign": _bContracts ? "YES" : "NO",
        "optin_form": _bOptForm ? "YES" : "NO",
        "sales_funnel": _bSalesFunnel ? "YES" : "NO",
        "chat_on": _bChatOn ? "YES" : "NO",
        "onlinechat_on": _bOnlineChat ? "YES" : "NO",
        "invoice_on": _bInvoice ? "YES" : "NO",
        "analytics_on": _bAnalytics ? "YES" : "NO",
        "paymentgateway_on": _bPaymentGateway ? "YES" : "NO",
        "login_level": widget.userInfo.userLevel,
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.saveUser(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null) {
          if (response["status"]) {
            showSuccessToast("Saved User");
            if (widget.contactInfo != null) {
              Navigator.pop(context);
            }
            cancelUser();
          } else {
            showErrorToast(response["err_code"]);
          }
        } else {
          showErrorToast("Something error");
        }
      });
    }
  }

  void cancelUser() {
    _txtName.text = "";
    _txtEmail.text = "";
    _txtPhone.text = "";
    _txtPassword.text = "";
    _txtNotes.text = "";
    setState(() {
      _bUnsubscribe = true;
      _bSelfDestruct = true;
      _bChangeEmail = true;
      _bSalesFunnel = false;
      _bContracts = false;
      _bOptForm = false;
      _bChatOn = false;
      _bOnlineChat = false;
      _bInvoice = false;
      _bPaymentGateway = false;
      _bAnalytics = false;
      _bStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          labelText: 'Name',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtName,
      ),
    );
    final emailRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
          labelText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtEmail,
      ),
    );
    final phoneRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.phone,
        decoration: new InputDecoration(
          labelText: 'Phone',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtPhone,
      ),
    );
    final passRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          labelText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtPassword,
      ),
    );
    final userroleRow = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 6.0, 0.0, 0.0),
          child: Text(
            "User Role",
            style: normalStyle,
            textAlign: TextAlign.right,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
          child: DropdownButton(
            items: itemsUserRole,
            value: userRole,
            onChanged: (value) {
              setState(() {
                userRole = value;
              });
            },
          ),
        )
      ],
    );

    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        maxLines: 4,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          labelText: 'Notes',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtNotes,
      ),
    );
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
                      onChanged: (value) {
                        setState(() {
                          _bUnsubscribe = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bSelfDestruct = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bChangeEmail = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bInvoice = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bSalesFunnel = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bContracts = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bOptForm = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bChatOn = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bOnlineChat = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bStatus = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bPaymentGateway = value;
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _bAnalytics = value;
                        });
                      },
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    )),
                Text("Analytics Websites"),
              ],
            ),
          ),
        ]);
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
              saveUser(context);
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
        title: widget.contactInfo != null
            ? const Text("Edit User")
            : const Text("Add User"),
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
                height: 30.0,
              ),
              Center(
                  child: Column(
                children: <Widget>[
                  nameRow,
                  emailRow,
                  passRow,
                  phoneRow,
                  notesRow,
                  userroleRow,
                  Divider(),
                  switchRow1,
                  switchRow2,
                  switchRow3,
                  switchRow4,
                  switchRow5,
                  switchRow6,
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

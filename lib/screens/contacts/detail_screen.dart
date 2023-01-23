import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/contacts/add_contacts_screen.dart';
import 'package:hemailer/screens/contacts/contract_history_screen.dart';
import 'package:hemailer/screens/contacts/email_history_screen.dart';
import 'package:hemailer/screens/contacts/sales_funnel_history_screen.dart';
import 'package:hemailer/screens/contacts/send_contract_screen.dart';
import 'package:hemailer/screens/contacts/send_email_screen.dart';
import 'package:hemailer/screens/contacts/send_invoice_screen.dart';
import 'package:hemailer/screens/contacts/send_sales_screen.dart';
import 'package:hemailer/screens/extra_info/extrainfo_screen.dart';
import 'package:hemailer/screens/notes/notes_screen.dart';
import 'package:hemailer/screens/payment/payment_screen.dart';
import 'package:hemailer/screens/subscribers/contact_sub_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hemailer/screens/chat/onlinechat_hist_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final dynamic contactInfo;
  final UserModel userInfo;
  final List<dynamic> allContacts;
  ContactDetailScreen(
      {Key key, @required this.contactInfo, this.userInfo, this.allContacts})
      : super(key: key);
  @override
  _ContactDetailScreenState createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  TextEditingController _txtNotes = new TextEditingController();
  String importantCount = "0";
  dynamic contactCurrentInfo;
  List<dynamic> allNotes = [];
  List<dynamic> allClients = new List<dynamic>();

  final dbRef = FirebaseDatabase.instance.reference();
  DatabaseReference chatRef;
  DatabaseReference onlineRef;
  var onlinechat;

  @override
  void initState() {
    super.initState();
    onlineRef =
        dbRef.child("ONLINECHAT").child(widget.userInfo.id).child('online');

    onlineRef.onValue.listen((event) {
      Map<dynamic, dynamic> onlineMap = event.snapshot.value;
      if (onlineMap != null) {
        if (mounted) {
          allClients.clear();
          setState(() {
            onlineMap.forEach((key, value) {
              if (widget.contactInfo['email'] == value['email']) {
                onlinechat = value;
              }
            });
          });
        }
      }
    });
    setState(() {
      contactCurrentInfo = widget.contactInfo;
      importantCount = contactCurrentInfo["note_important"];
    });
    refreshNotes();
  }

  void refreshNotes() {
    final body = {
      "email_id": widget.contactInfo["id"],
    };

    ApiService.getNotes(body).then((response) {
      setState(() {
        allNotes = response;
      });
    });
  }

  void showEditNotesDlg(BuildContext context) {
    _txtNotes.text = contactCurrentInfo["notes"];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Notes'),
            content: TextField(
              maxLines: 4,
              controller: _txtNotes,
              decoration: InputDecoration(
                hintText: "notes",
                border: OutlineInputBorder(),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                color: Colors.blueAccent,
                child: new Text('SAVE'),
                onPressed: () {
                  updateNotes();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void paymentList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          userInfo: widget.userInfo,
          contactInfo: contactCurrentInfo,
        ),
      ),
    );
  }

  void extraInfoList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraInfoScreen(
          userInfo: widget.userInfo,
          contactInfo: contactCurrentInfo,
        ),
      ),
    );
  }

  void notesList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesScreen(
          userInfo: widget.userInfo,
          contactInfo: contactCurrentInfo,
        ),
      ),
    ).then((val) {
      final body = {
        "email_id": contactCurrentInfo["id"],
      };
      ApiService.getOneContact(body).then((response) {
        setState(() {
          importantCount = response != null ? response["note_important"] : "0";
        });
        refreshNotes();
      });
    });
  }

  void editContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactAddScreen(
            contactInfo: contactCurrentInfo, userInfo: widget.userInfo),
      ),
    ).then((val) {
      final body = {
        "email_id": contactCurrentInfo["id"],
      };
      ApiService.getOneContact(body).then((response) {
        setState(() {
          if (response != null) {
            contactCurrentInfo = response;
          }
        });
      });
    });
  }

  void updateNotes() {
    final body = {
      "email_id": contactCurrentInfo["id"],
      "notes": _txtNotes.text.trim(),
    };
    ApiService.updateNotesContact(body).then((response) {
      if (response != null && response["status"]) {
        showSuccessToast("Saved Contact");
        setState(() {
          contactCurrentInfo["notes"] = _txtNotes.text;
        });
      } else {
        showErrorToast("Something error");
      }
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
              padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
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
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  showEditNotesDlg(context);
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
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
          child: SelectableText(
            contactCurrentInfo["notes"],
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ],
    );
    final extraPayRow = Padding(
      padding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                child: IconButton(
                  icon: Icon(Icons.attach_money,
                      color: Colors.lightBlueAccent, size: 30.0),
                  onPressed: () {
                    paymentList(context);
                  },
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                child: IconButton(
                  icon: Icon(Icons.add,
                      color: Colors.lightBlueAccent, size: 30.0),
                  color: Colors.redAccent,
                  onPressed: () {
                    extraInfoList(context);
                  },
                ),
              ),
            ),
          ),
          Material(
              color: Colors.white,
              child: Center(
                child: Row(
                  children: <Widget>[
                    Ink(
                      child: IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: allNotes.length == 0
                                ? Colors.lightBlueAccent
                                : Colors.redAccent,
                            size: 30.0),
                        color: Colors.redAccent,
                        onPressed: () {
                          notesList(context);
                        },
                      ),
                    ),
                    importantCount != "0"
                        ? Icon(Icons.flag, color: Colors.red, size: 30.0)
                        : SelectableText(""),
                    importantCount != "0"
                        ? new Container(
                            decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                              child: SelectableText(
                                importantCount,
                                style: normalStyle.copyWith(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                            ))
                        : SelectableText("")
                  ],
                ),
              )),
        ],
      ),
    );

    Widget _createPageItem(
        {IconData icon, String text, GestureTapCallback onTap}) {
      return Material(
        color: Colors.white,
        child: ListTile(
          title: Row(
            children: <Widget>[
              Icon(icon),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  text,
                  style: normalStyle.copyWith(
                      fontSize: 20, color: Colors.blueAccent),
                ),
              )
            ],
          ),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Contact Detail"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editContact(context);
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
              height: 30.0,
            ),
            Center(
                child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  minRadius: 30,
                  maxRadius: 45,
                  child: SelectableText(
                    contactCurrentInfo["name"].substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SelectableText(
                    contactCurrentInfo["name"],
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
                      onlinechat != null
                          ? _createControlItem(
                              icon: Icons.message,
                              text: "online chat",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OnlineChatHistoryScreen(
                                      clientInfo: onlinechat,
                                      userInfo: widget.userInfo,
                                    ),
                                  ),
                                );
                              })
                          : Expanded(
                              child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Material(
                                      child: InkWell(
                                        onTap: () {},
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black26,
                                          child: Icon(Icons.message,
                                              color: Colors.white, size: 20.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                                    child: Text(
                                      "online chat",
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                  ),
                                ],
                              ),
                            )),
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
                    txtKey: "Phone", txtValue: contactCurrentInfo["phone"]),
                Divider(),
                _createDetailItem(
                    txtKey: "Address", txtValue: contactCurrentInfo["address"]),
                Divider(),
                _createDetailItem(
                    txtKey: "City", txtValue: contactCurrentInfo["city"]),
                Divider(),
                _createDetailItem(
                    txtKey: "State/Province",
                    txtValue: contactCurrentInfo["state"]),
                Divider(),
                _createDetailItem(
                    txtKey: "Zipcode/Postal",
                    txtValue: contactCurrentInfo["zip_code"]),
                Divider(),
                notesRow,
                Divider(),
                extraPayRow,
                Divider(),
                _createPageItem(
                    icon: Icons.mail,
                    text: "Send Email",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendEmailScreen(
                            contactInfo: contactCurrentInfo,
                            userInfo: widget.userInfo,
                            allContacts: widget.allContacts,
                          ),
                        ),
                      );
                    }),
                Visibility(
                  visible: widget.userInfo.contractSign == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.receipt,
                      text: "Send Contract",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendContractScreen(
                              contactInfo: contactCurrentInfo,
                              userInfo: widget.userInfo,
                              allContacts: widget.allContacts,
                            ),
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: widget.userInfo.salesFunnel == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.receipt,
                      text: "Send Sales Funnel",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendSalesScreen(
                              contactInfo: contactCurrentInfo,
                              userInfo: widget.userInfo,
                              allContacts: widget.allContacts,
                            ),
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: widget.userInfo.invoiceOn == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.monetization_on,
                      text: "Send Invoice",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendInvoiceScreen(
                              contactInfo: contactCurrentInfo,
                              userInfo: widget.userInfo,
                              allContacts: widget.allContacts,
                            ),
                          ),
                        );
                      }),
                ),
                Divider(),
                _createPageItem(
                    icon: Icons.history,
                    text: "Sent Emails",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailHitoryScreen(
                              contactInfo: contactCurrentInfo,
                              userInfo: widget.userInfo),
                        ),
                      );
                    }),
                Visibility(
                  visible: widget.userInfo.contractSign == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.history,
                      text: "Sent Contracts",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContractHitoryScreen(
                                contactInfo: contactCurrentInfo,
                                userInfo: widget.userInfo),
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: widget.userInfo.salesFunnel == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.history,
                      text: "Sent Sales Funnel",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalesHitoryScreen(
                                contactInfo: contactCurrentInfo,
                                userInfo: widget.userInfo),
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: widget.userInfo.optForm == "YES" ? true : false,
                  child: _createPageItem(
                      icon: Icons.notification_important,
                      text: "Opt in subscriber",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactSubScreen(
                                contactInfo: contactCurrentInfo,
                                userInfo: widget.userInfo),
                          ),
                        );
                      }),
                ),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/utils/contacts_search_dlg.dart';

class SendSalesScreen extends StatefulWidget {
  final dynamic contactInfo;
  final List<dynamic> allContacts;
  final UserModel userInfo;
  SendSalesScreen(
      {Key key, @required this.contactInfo, this.userInfo, this.allContacts})
      : super(key: key);
  @override
  _SendSalesScreenState createState() => _SendSalesScreenState();
}

class _SendSalesScreenState extends State<SendSalesScreen> {
  TextEditingController _txtToEmail = new TextEditingController();
  TextEditingController _txtFromEmail = new TextEditingController();
  bool _progressBarActive = false;

  List<DropdownMenuItem> itemsExpire = [];
  List<String> expireText = [
    'Opened',
    '5 mintues',
    '10 minutes',
    '1 hour',
    '24 hours'
  ];
  List<String> expireValue = ['0', '5', '10', '60', '1440'];
  bool bSelfDestruct = false;
  String expireMinutes = "0";

  List<DropdownMenuItem> itemsFolder = [];
  List<DropdownMenuItem> itemsTemplate = [];

  String folderID = "Saved Template:0";
  String tmpID;
  String tmpThumb;

  List<dynamic> folders;
  List<dynamic> templates;

  List<String> tmpName = new List<String>();
  List<String> tmpScheduledAt = new List<String>();
  List<TextEditingController> _controllers = new List();
  List<dynamic> selectedContacts = new List<dynamic>();
  @override
  void initState() {
    super.initState();
    selectedContacts.add(widget.contactInfo);
    for (int i = 0; i < expireText.length; i++) {
      itemsExpire.add(new DropdownMenuItem(
        child: new Text(expireText[i]),
        value: expireValue[i],
      ));
    }
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getSalesFunnelTmp(body).then((response) {
      setState(() {
        _progressBarActive = false;
        folders = response["folder_data"];
        templates = response["tmp_data"];
        itemsFolder.add(new DropdownMenuItem(
          child: new Text("Saved Template"),
          value: "Saved Template:0",
        ));
        for (var folder in folders) {
          itemsFolder.add(new DropdownMenuItem(
            child: new Text(
              folder["name"],
              overflow: TextOverflow.ellipsis,
            ),
            value: folder["name"] + ":" + folder["id"],
          ));
        }
        getTemplateItems("Saved Template:0");
      });
    });
  }

  void getTemplateItems(String folderStrID) {
    String foldID = folderStrID.toString().split(":")[1];
    itemsTemplate.clear();
    for (var folder in templates) {
      if (folder["folder_id"] == foldID) {
        for (var tmp in folder["tmp_data"]) {
          itemsTemplate.add(new DropdownMenuItem(
            child: new Text(
              tmp["name"],
              overflow: TextOverflow.ellipsis,
            ),
            value: tmp["name"] + ":" + tmp["id"],
          ));
        }
      }
    }
  }

  void getTmpThumb(String tmpID) {
    String tmpStrID = tmpID.toString().split(":")[1];
    String folderStrID = folderID.toString().split(":")[1];
    for (var folder in templates) {
      if (folder["folder_id"] == folderStrID) {
        for (var tmp in folder["tmp_data"]) {
          if (tmp["id"] == tmpStrID) {
            setState(() {
              tmpName.clear();
              tmpScheduledAt.clear();
              _controllers.clear();
              for (var i = 0; i < tmp["selected_tmps"].length; i++) {
                if (tmp["selected_tmps"][i]["tmp_name"] == null) {
                  tmpName.add("");
                } else {
                  tmpName.add(tmp["selected_tmps"][i]["tmp_name"]);
                }
                // tmpScheduledAt.add(tmpData["scheduled_at"]);
                _controllers.add(new TextEditingController());
                _controllers[i].text = tmp["selected_tmps"][i]["scheduled_at"];
              }
            });
          }
        }
      }
    }
  }

  void sendContractTmp(BuildContext context) {
    if (_txtFromEmail.text == "") {
      showErrorToast("Please fill from email");
    } else if (selectedContacts.length == 0) {
      showErrorToast("Please select to email");
    } else if (tmpID == null) {
      showErrorToast("Please select template");
    } else {
      List<String> arrSelToEmailID = new List<String>();
      for (var to in selectedContacts) {
        arrSelToEmailID.add(to["id"]);
      }
      String selToEmailID = arrSelToEmailID.join(", ");
      String selTmpID = tmpID.toString().split(":")[1];
      String selFromEmail = _txtFromEmail.text;
      String selSelfDestruct = bSelfDestruct ? "YES" : "NO";
      String _scheduleDate = '';
      for (var i = 0; i < _controllers.length; i++) {
        _scheduleDate = _scheduleDate + _controllers[i].text + '#';
      }

      final body = {
        "user_id": widget.userInfo.id,
        "tmp_id": selTmpID,
        "receiver_id": selToEmailID,
        "sender": selFromEmail,
        "self_destruct": selSelfDestruct,
        "expired_minutes": expireMinutes,
        "schedule_date": _scheduleDate,
      };
      ApiService.sendSalesFunnelTmp(body).then((response) {
        if (response != null && response["status"]) {
          showSuccessToast("Sent successfully");
        } else {
          showErrorToast("Something error");
        }
      });
    }
  }

  void addToContacts(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContactSearchDlg(
              contacts: widget.allContacts,
              selectedContacts: selectedContacts,
              onSelectedContactsListChanged: (contacts) {
                selectedContacts = contacts;
                if (selectedContacts.length > 0) {
                  _txtToEmail.text = selectedContacts.length > 1
                      ? selectedContacts[0]["name"] +
                          " + " +
                          (selectedContacts.length - 1).toString() +
                          " contacts"
                      : selectedContacts[0]["name"];
                } else {
                  _txtToEmail.text = "";
                }
              });
        });
  }

  Widget getRowTmpNameScheduled() {
    List<Widget> col = new List<Widget>();
    for (var i = 0; i < tmpName.length; i++) {
      var widget = Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
              child: Text(
                tmpName[i],
                style: normalStyle,
              ),
            ),
          ),
          // Expanded(
          //   flex: 4,
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          //     child: Text(
          //       tmpScheduledAt[i],
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 4,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                child: TextField(
                  controller: _controllers[i],
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(border: InputBorder.none),
                  readOnly: true,
                )),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
              child: IconButton(
                icon: Icon(
                  MdiIcons.squareEditOutline,
                  color: Color(0xff4285f4),
                ),
                onPressed: () async {
                  DateTime date = DateTime(1900);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  var _date = _controllers[i].text.substring(0, 10);
                  var _time = _controllers[i].text.substring(11, 19);

                  date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    _date = date.toIso8601String().substring(0, 10);
                  }
                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                  if (time != null) {
                    _time = time.toString().substring(10, 15) + ':' + '00';
                  }

                  setState(() {
                    _controllers[i].text = _date + ' ' + _time;
                  });
                },
              ),
            ),
          )
        ],
      );
      col.add(widget);
    }
    return Column(
      children: col,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedContacts.length > 0) {
      _txtToEmail.text = selectedContacts.length > 1
          ? selectedContacts[0]["name"] +
              " + " +
              (selectedContacts.length - 1).toString() +
              " contacts"
          : selectedContacts[0]["name"];
    } else {
      _txtToEmail.text = "";
    }
    _txtFromEmail.text = widget.userInfo.userEmail;
    final titleButtonRow = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "New Sales Funnel",
              style: normalStyle.copyWith(
                  fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Padding(
                padding: EdgeInsets.all(6.0),
                child: FlatButton.icon(
                  color: Colors.blueAccent,
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ), //`Icon` to display
                  label: Text(
                    'Send',
                    style: normalStyle.copyWith(
                      color: Colors.white,
                    ),
                  ), //`Text` to display
                  onPressed: () {
                    sendContractTmp(context);
                  },
                ))),
      ],
    );
    final toEmailRow = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
            child: TextField(
              enabled: false,
              style: normalStyle,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                labelText: 'To',
                contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
              ),
              controller: _txtToEmail,
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
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
    final fromEmailRow = Padding(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
      child: TextField(
        enabled: widget.userInfo.emailChange == "YES" ? true : false,
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          labelText: 'From',
          contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
        ),
        controller: _txtFromEmail,
      ),
    );
    final folderRow = Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 12.0, 0.0, 0),
            child: Text(
              "Folder",
              style: normalStyle,
            ),
          ),
        ),
        Expanded(
            flex: 7,
            child: SearchableDropdown(
              items: itemsFolder,
              value: folderID,
              hint: new Text('Select Folder'),
              searchHint: new Text(
                'Select Folder',
                style: new TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  folderID = value;
                  tmpID = null;
                  tmpThumb = null;
                  getTemplateItems(folderID);
                });
              },
            )),
      ],
    );
    final templateRow = Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 12.0, 0.0, 0),
            child: Text(
              "Template",
              style: normalStyle,
            ),
          ),
        ),
        Expanded(
            flex: 7,
            child: SearchableDropdown(
              items: itemsTemplate,
              value: tmpID,
              isExpanded: false,
              hint: new Text('Select Template'),
              searchHint: new Text(
                'Select Template',
                style: new TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  tmpID = value;
                  getTmpThumb(tmpID);
                });
              },
            )),
      ],
    );
    final selfDestructRow =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 25.0),
        child: Text(
          "Self Destruct",
          style: normalStyle,
          textAlign: TextAlign.right,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: Switch(
            value: bSelfDestruct,
            onChanged: (value) {
              setState(() {
                bSelfDestruct = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )),
      Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Visibility(
            visible: bSelfDestruct,
            child: DropdownButton(
              items: itemsExpire,
              value: expireMinutes,
              onChanged: (value) {
                setState(() {
                  expireMinutes = value;
                });
              },
            ),
          ))
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Sales Funnel"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Center(
                  child: Column(
                children: <Widget>[
                  titleButtonRow,
                  toEmailRow,
                  fromEmailRow,
                  folderRow,
                  templateRow,
                  Visibility(
                    visible:
                        widget.userInfo.selfDestruct == "YES" ? true : false,
                    child: selfDestructRow,
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: getRowTmpNameScheduled(),
                  ),
                ],
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:intl/intl.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/utils/contacts_search_dlg.dart';

class SendEmailScreen extends StatefulWidget {
  final dynamic contactInfo;
  final dynamic recurringInfo;
  final List<dynamic> allContacts;
  final UserModel userInfo;
  SendEmailScreen(
      {Key key,
      @required this.contactInfo,
      this.userInfo,
      this.allContacts,
      this.recurringInfo})
      : super(key: key);
  @override
  _SendEmailScreenState createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
  TextEditingController _txtToEmail = new TextEditingController();
  TextEditingController _txtFromEmail = new TextEditingController();
  TextEditingController _txtNotes = new TextEditingController();

  List<DropdownMenuItem> itemsFolder = [];
  List<DropdownMenuItem> itemsTemplate = [];
  List<DropdownMenuItem> itemsExpire = [];
  List<String> expireText = [
    'Opened',
    '5 mintues',
    '10 minutes',
    '1 hour',
    '24 hours'
  ];
  List<String> expireValue = ['0', '5', '10', '60', '1440'];
  bool _progressBarActive = false;

  String folderID = "Saved Template:0";
  String tmpID;
  String tmpThumb;
  bool bSelfDestruct = false;
  bool bRecurring = false;
  bool bSchedule = false;
  String expireMinutes = "0";
  List<dynamic> folders;
  List<dynamic> templates;

  List<dynamic> selectedContacts = new List<dynamic>();

  //////// for recurring settings
  var format = new DateFormat("yyyy-MM-dd");
  final formatTime = DateFormat("HH:mm");
  var now = new DateTime.now();
  TextEditingController _txtRecurringAt = new TextEditingController();
  TextEditingController _txtRecurringEnd = new TextEditingController();
  TextEditingController _txtSendingTime = new TextEditingController();
  TextEditingController _txtEmailsCount = new TextEditingController();
  TextEditingController _txtCustomCount = new TextEditingController();
  
  TextEditingController _txtScheduleAt = new TextEditingController();
  TextEditingController _txtScheduleTime = new TextEditingController();

  List<DropdownMenuItem> itemsEnd = [];
  List<String> endText = ['After', 'On', 'Never'];
  String endVal = "1";
  List<DropdownMenuItem> itemsMode = [];
  List<String> modeText = ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'];
  String modeVal = "1";
  List<DropdownMenuItem> itemsWeeks = [];
  List<String> weeksText = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  int weekVal = 0;
  List<DropdownMenuItem> itemsMonths = [];
  int monthVal = 1;
  int yearMonthVal = 1;
  List<DropdownMenuItem> itemsYear = [];
  List<String> yearText = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'Octobor',
    'November',
    'December'
  ];
  int yearVal = 0;
  List<DropdownMenuItem> itemsCustomMode = [];
  List<String> modeCustomText = [
    'Daily(s)',
    'Weekly(s)',
    'Monthly(s)',
    'Yearly(s)'
  ];
  String modeCustomVal = "1";
  List<DropdownMenuItem> itemsMonthsYear = [];
  String recurringId = "-1";
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
    //////// for recurring setting init /////
    for (int i = 0; i < endText.length; i++) {
      itemsEnd.add(new DropdownMenuItem(
        child: new Text(endText[i]),
        value: (i + 1).toString(),
      ));
    }
    for (int i = 0; i < modeText.length; i++) {
      itemsMode.add(new DropdownMenuItem(
        child: new Text(modeText[i]),
        value: (i + 1).toString(),
      ));
    }
    for (int i = 0; i < weeksText.length; i++) {
      itemsWeeks.add(new DropdownMenuItem(
        child: new Text(weeksText[i]),
        value: i,
      ));
    }
    for (int i = 1; i <= 31; i++) {
      var temp = i.toString() + "th";
      if (i == 1) {
        temp = "First";
      } else if (i == 2) {
        temp = "Second";
      }
      itemsMonths.add(new DropdownMenuItem(
        child: new Text(temp),
        value: i,
      ));
      itemsMonthsYear.add(new DropdownMenuItem(
        child: new Text(temp),
        value: i,
      ));
    }
    for (int i = 0; i < yearText.length; i++) {
      itemsYear.add(new DropdownMenuItem(
        child: new Text(yearText[i]),
        value: i,
      ));
    }
    for (int i = 0; i < modeCustomText.length; i++) {
      itemsCustomMode.add(new DropdownMenuItem(
        child: new Text(modeCustomText[i]),
        value: (i + 1).toString(),
      ));
    }
    /////////////
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getTemplates(body).then((response) {
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
        if (widget.recurringInfo == null) {
          initRecurring();
          getTemplateItems("Saved Template:0");
        } else {
          setRecurring();
        }
      });
    });
  }

  void initRecurring() {
    _txtRecurringAt.text = format.format(now);
    _txtSendingTime.text = formatTime.format(now);
    _txtEmailsCount.text = "1";
    _txtCustomCount.text = "1";
    _txtRecurringEnd.text = format.format(now.add(Duration(days: 1)));
    weekVal = now.weekday % 7;
    monthVal = now.day;
    yearVal = now.month - 1;
    yearMonthVal = now.day;
    
  }

  void setRecurring() {
    bRecurring = true;
    bSelfDestruct =
        widget.recurringInfo["self_destruct"] == "YES" ? true : false;
    _txtNotes.text = widget.recurringInfo["self_destruct_content"];
    expireMinutes = widget.recurringInfo["expired_minutes"];
    folderID = "Saved Template:" + widget.recurringInfo["folder_id"];
    getTemplateItems(folderID);
    tmpID =
        widget.recurringInfo["tmp_name"] + ":" + widget.recurringInfo["tmp_id"];

    endVal = widget.recurringInfo["repeat_end_mode"];
    modeVal = widget.recurringInfo["repeat_mode"];
    modeCustomVal = widget.recurringInfo["repeat_custom_mode"];
    _txtRecurringAt.text = widget.recurringInfo["first_create_on"];
    _txtSendingTime.text =
        widget.recurringInfo["sending_time"].toString().substring(0, 5);
    _txtEmailsCount.text = widget.recurringInfo["end_emails_count"];
    _txtCustomCount.text = widget.recurringInfo["custom_interval"];
    _txtRecurringEnd.text = widget.recurringInfo["end_repeat_day"];
    weekVal = int.parse(widget.recurringInfo["repeat_weekly"]);
    monthVal = int.parse(widget.recurringInfo["repeat_monthly"]);
    yearVal = int.parse(widget.recurringInfo["repeat_yearly"]);
    yearMonthVal = int.parse(widget.recurringInfo["repeat_yearly_monthly"]);

    recurringId = widget.recurringInfo["id"];
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

  String getTmpThumb(String tmpID) {
    String tmpStrID = tmpID.toString().split(":")[1];
    String folderStrID = folderID.toString().split(":")[1];
    for (var folder in templates) {
      if (folder["folder_id"] == folderStrID) {
        for (var tmp in folder["tmp_data"]) {
          if (tmp["id"] == tmpStrID) {
            return tmp["tmp_thumb"];
          }
        }
      }
    }
    return null;
  }

  void sendEmailTmp(BuildContext context) {
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

      final body = {
        "user_id": widget.userInfo.id,
        "tmp_id": selTmpID,
        "receiver_id": selToEmailID,
        "sender": selFromEmail,
        "self_destruct": selSelfDestruct,
        "expired_minutes": expireMinutes,
        "self_destruct_content": _txtNotes.text,
        "recurring_on": bRecurring ? "YES" : "NO",
        "repeat_mode": modeVal,
        "custom_interval": _txtCustomCount.text,
        "repeat_custom_mode": modeCustomVal,
        "repeat_weekly": weekVal.toString(),
        "repeat_monthly": monthVal.toString(),
        "repeat_yearly": yearVal.toString(),
        "repeat_yearly_monthly": yearMonthVal.toString(),
        "first_create_on": _txtRecurringAt.text,
        "repeat_end_mode": endVal,
        "end_repeat_day": _txtRecurringEnd.text,
        "end_emails_count": _txtEmailsCount.text,
        "sending_time": _txtSendingTime.text,
        "folder": folderID.split(":")[1],
        "recurring_id": recurringId,
        "schedule_on": bSchedule ? "YES" : "NO",
        "schedule_at": _txtScheduleAt.text,
        "schedule_time": _txtScheduleTime.text
      };

      ApiService.sendEmailTmp(body).then((response) {
        if (response != null && response["status"]) {
          if (response["code"] != null) {
            if (widget.recurringInfo != null) {
              Navigator.of(context).pop();
            } else {
              showSuccessToast("Saved Recurring email successfully");
            }
          } else {
            showSuccessToast("Sent email successfully");
          }
        } else if (response != null && response["status"] == false) {
          showErrorToast(response["message"]);
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
            child: widget.recurringInfo == null
                ? Text(
                    "New Message",
                    style: normalStyle.copyWith(
                        fontSize: 25.0, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "Edit Recurring Email",
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
                    sendEmailTmp(context);
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
        style: normalStyle,
        enabled: widget.userInfo.emailChange == "YES" ? true : false,
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
                  tmpThumb = getTmpThumb(tmpID);
                });
              },
            )),
      ],
    );
    final selfDestructRow = Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 10.0),
      child: TextField(
        maxLines: 4,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Self Destruct Content',
          contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        ),
        controller: _txtNotes,
      ),
    );

    //////////// for Recurring ////
    final recurringRow = Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 25.0),
        child: Text(
          "Schedule",
          style: normalStyle,
          textAlign: TextAlign.right,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: Switch(
            value: bSchedule,
            onChanged:  (value) {
              setState(() {
                bSchedule = value;
                if (bRecurring){
                  bRecurring = false;
                }
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )),
      Padding(
        padding: EdgeInsets.only(left: 25.0),
        child: Text(
          "Recurring",
          style: normalStyle,
          textAlign: TextAlign.right,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: Switch(
            value: bRecurring,
            onChanged: widget.recurringInfo == null
                ? (value) {
                    setState(() {
                      bRecurring = value;
                      if (bSchedule){
                        bSchedule = false;
                      }
                    });
                  }
                : null,
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )),
    ]);
    final scheduleRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: DateTimeField(
              format: format,
              controller: _txtScheduleAt,
              decoration: InputDecoration(
                labelText: 'Scheduled on',
                contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
              ),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child:Text('')
        ),
        Expanded(
          flex: 3,
          child: DateTimeField(
            controller: _txtScheduleTime,
            format: formatTime,
            decoration: InputDecoration(
              labelText: 'Schedule Time',
              contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
            ),
            onShowPicker: (context, currentValue) async {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.convert(time);
            },
          ),
        )
    ],);
    final recurringMode = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Text(
              "Repeat this Email",
              style: normalStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: DropdownButton(
              items: itemsMode,
              value: modeVal,
              onChanged: (value) {
                setState(() {
                  modeVal = value;
                });
              },
            ),
          ),
        ),
        Expanded(flex: 1, child: Text("")),
      ],
    );
    final recurringEvery = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
          visible: modeVal == "1" || (modeVal == "5" && modeCustomVal == "1")
              ? false
              : true,
          child: Expanded(
            flex: modeVal == "2" ? 3 : 2,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Text(
                modeVal == "5" ? "On" : "Every",
                style: normalStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // weekly dropdown
        Visibility(
          visible: modeVal == "2" || (modeVal == "5" && modeCustomVal == "2")
              ? true
              : false,
          child: Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: DropdownButton(
                items: itemsWeeks,
                value: weekVal,
                onChanged: (value) {
                  var tempDate =
                      now.add(Duration(days: (value + 7 - now.weekday) % 7));
                  _txtRecurringAt.text = format.format(tempDate);
                  _txtRecurringEnd.text =
                      format.format(tempDate.add(Duration(days: 1)));
                  setState(() {
                    weekVal = value;
                  });
                },
              ),
            ),
          ),
        ),
        // Monthly DropDown
        Visibility(
          visible: modeVal == "3" || (modeVal == "5" && modeCustomVal == "3")
              ? true
              : false,
          child: Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: DropdownButton(
                items: itemsMonths,
                value: monthVal,
                onChanged: (value) {
                  var tempDate;
                  if (value < now.day) {
                    tempDate = new DateTime(now.year, now.month + 1, value);
                  } else {
                    tempDate = new DateTime(now.year, now.month, value);
                  }

                  _txtRecurringAt.text = format.format(tempDate);
                  _txtRecurringEnd.text =
                      format.format(tempDate.add(Duration(days: 1)));
                  setState(() {
                    monthVal = value;
                  });
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: modeVal == "4" || (modeVal == "5" && modeCustomVal == "4")
              ? true
              : false,
          child: Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: DropdownButton(
                items: itemsYear,
                value: yearVal,
                onChanged: (value) {
                  int count = 30;
                  var bigMonth = [1, 3, 5, 7, 8, 10, 12];
                  if (bigMonth.contains(value + 1)) {
                    count = 31;
                  } else if (value + 1 == 2) {
                    count = 29;
                  }
                  List<DropdownMenuItem> tmpDrowpDown = [];
                  for (int i = 1; i <= count; i++) {
                    var temp = i.toString() + "th";
                    if (i == 1) {
                      temp = "First";
                    } else if (i == 2) {
                      temp = "Second";
                    }
                    tmpDrowpDown.add(new DropdownMenuItem(
                      child: new Text(temp),
                      value: i,
                    ));
                  }
                  var tempDate;
                  if (value + 1 < now.month ||
                      (value + 1 == now.month && yearMonthVal < now.day)) {
                    tempDate =
                        new DateTime(now.year + 1, value + 1, yearMonthVal);
                  } else {
                    tempDate = new DateTime(now.year, value + 1, yearMonthVal);
                  }

                  _txtRecurringAt.text = format.format(tempDate);
                  _txtRecurringEnd.text =
                      format.format(tempDate.add(Duration(days: 1)));
                  setState(() {
                    yearVal = value;
                    itemsMonthsYear = tmpDrowpDown;
                  });
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: modeVal == "4" || (modeVal == "5" && modeCustomVal == "4")
              ? true
              : false,
          child: Expanded(
            flex: 1,
            child: Text(""),
          ),
        ),
        Visibility(
          visible: modeVal == "4" || (modeVal == "5" && modeCustomVal == "4")
              ? true
              : false,
          child: Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: DropdownButton(
                items: itemsMonthsYear,
                value: yearMonthVal,
                onChanged: (value) {
                  var tempDate;
                  if (yearVal + 1 < now.month ||
                      (yearVal + 1 == now.month && value < now.day)) {
                    tempDate = new DateTime(now.year + 1, yearVal + 1, value);
                  } else {
                    tempDate = new DateTime(now.year, yearVal + 1, value);
                  }

                  _txtRecurringAt.text = format.format(tempDate);
                  _txtRecurringEnd.text =
                      format.format(tempDate.add(Duration(days: 1)));
                  setState(() {
                    yearMonthVal = value;
                  });
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: modeVal == "4" ||
                  modeVal == "3" ||
                  (modeVal == "5" && modeCustomVal == "4") ||
                  (modeVal == "5" && modeCustomVal == "3")
              ? true
              : false,
          child: Expanded(flex: 2, child: Text(" day of Month")),
        ),
        Visibility(
          visible: modeVal != "4" ? true : false,
          child: Expanded(
              flex: modeVal == "2" || (modeVal == "5" && modeCustomVal == "2")
                  ? 3
                  : 1,
              child: Text("")),
        ),
      ],
    );
    final recurringCustomEvery = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
          visible: modeVal == "5" ? true : false,
          child: Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Text(
                "Every",
                style: normalStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Visibility(
          visible: modeVal == "5" ? true : false,
          child: Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: TextField(
                controller: _txtCustomCount,
                style: normalStyle,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                    border: OutlineInputBorder(gapPadding: 1.0)),
              ),
            ),
          ),
        ),
        Visibility(
            visible: modeVal == "5" ? true : false,
            child: Expanded(
              child: Text(""),
              flex: 1,
            )),
        Visibility(
          visible: modeVal == "5" ? true : false,
          child: Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: DropdownButton(
                items: itemsCustomMode,
                value: modeCustomVal,
                onChanged: (value) {
                  setState(() {
                    modeCustomVal = value;
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(""),
          flex: 1,
        )
      ],
    );
    final recurringDateAt = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: DateTimeField(
              format: format,
              controller: _txtRecurringAt,
              decoration: InputDecoration(
                labelText: 'Created First Email on',
                contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
              ),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Text(
              "End",
              style: normalStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: DropdownButton(
              items: itemsEnd,
              value: endVal,
              onChanged: (value) {
                setState(() {
                  endVal = value;
                });
              },
            ),
          ),
        ),
        Expanded(flex: 1, child: Text(""))
      ],
    );
    final recurringInterval = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
          visible: endVal == "1" ? true : false,
          child: Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: TextField(
                textInputAction: TextInputAction.go,
                controller: _txtEmailsCount,
                style: normalStyle,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  labelText: 'emails',
                  contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: endVal == "2" ? true : false,
          child: Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: DateTimeField(
                format: format,
                controller: _txtRecurringEnd,
                decoration: InputDecoration(
                  labelText: 'Last Email at',
                  contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(""),
          flex: 1,
        ),
        Visibility(
          visible: endVal == "3" ? true : false,
          child: Expanded(
            flex: 2,
            child: Text(""),
          ),
        ),
        Expanded(
          flex: 2,
          child: DateTimeField(
            controller: _txtSendingTime,
            format: formatTime,
            decoration: InputDecoration(
              labelText: 'Sending Time',
              contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
            ),
            onShowPicker: (context, currentValue) async {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.convert(time);
            },
          ),
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recurringInfo == null
            ? "Send Email"
            : "Edit Recurring Email"),
      ),
      body: ModalProgressHUD(
          inAsyncCall: _progressBarActive,
          child: GestureDetector(
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
                          visible: widget.userInfo.selfDestruct == "YES"
                              ? true
                              : false,
                          child: selfDestructRow,
                        ),
                        Visibility(
                          visible: bSelfDestruct,
                          child: notesRow,
                        ),
                        recurringRow,
                        Visibility(
                          visible: bSchedule,
                          child:  Card(
                            margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                            child:Padding(
                              padding: EdgeInsets.all(6.0),
                              child:scheduleRow
                            )
                          )
                        ),
                        Visibility(
                          visible: bRecurring,
                          child: Card(
                            margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Text(
                                      "Recurring Settings",
                                      style: normalStyle.copyWith(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
                                    )),
                                recurringMode,
                                recurringCustomEvery,
                                recurringEvery,
                                SizedBox(
                                  height: 10.0,
                                ),
                                recurringDateAt,
                                recurringInterval,
                                SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 10.0),
                          child: Image(
                            image: tmpThumb != null
                                ? NetworkImage(tmpThumb)
                                : AssetImage("assets/default.jpg"),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ],
                    )),
                  ]),
                ),
              ),
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()))),
    );
  }
}

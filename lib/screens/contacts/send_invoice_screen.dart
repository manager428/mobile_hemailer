import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/utils/products_search_dlg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:intl/intl.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';

class SendInvoiceScreen extends StatefulWidget {
  final dynamic contactInfo;
  final List<dynamic> allContacts;
  final UserModel userInfo;
  final dynamic recurringInfo;
  SendInvoiceScreen(
      {Key key,
      @required this.contactInfo,
      this.userInfo,
      this.allContacts,
      this.recurringInfo})
      : super(key: key);
  @override
  _SendInvoiceScreenState createState() => _SendInvoiceScreenState();
}

class _SendInvoiceScreenState extends State<SendInvoiceScreen> {
  TextEditingController _txtToEmail = new TextEditingController();
  TextEditingController _txtProduct = new TextEditingController();
  TextEditingController _txtFromEmail = new TextEditingController();
  TextEditingController _txtPayLink = new TextEditingController();
  TextEditingController _txtNotes = new TextEditingController();
  TextEditingController _txtInvNum = new TextEditingController();
  TextEditingController _txtInvDate = new TextEditingController();
  bool _bPayLinkOn = false;
  bool _bPayButtonOn = true;
  bool _progressBarActive = false;

  List<DropdownMenuItem> itemsTemplate = [];

  String tmpID;

  List<dynamic> templates;
  List<dynamic> products;

  List<dynamic> selectedProducts = new List<dynamic>();

  //////// for recurring settings
  bool bRecurring = false;
  bool bCustomContent = true;
  var format = new DateFormat("yyyy-MM-dd");
  final formatTime = DateFormat("HH:mm");
  var now = new DateTime.now();
  TextEditingController _txtRecurringAt = new TextEditingController();
  TextEditingController _txtRecurringEnd = new TextEditingController();
  TextEditingController _txtSendingTime = new TextEditingController();
  TextEditingController _txtEmailsCount = new TextEditingController();
  TextEditingController _txtCustomCount = new TextEditingController();

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
    _txtInvNum.text = widget.contactInfo["inv_no"].toString();
    _txtInvDate.text = format.format(now);
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
    ApiService.getInvoiceTmp(body).then((response) {
      setState(() {
        _progressBarActive = false;
        templates = response["invoices"];
        products = response["products"];

        for (var folder in templates) {
          itemsTemplate.add(new DropdownMenuItem(
            child: new Text(folder["name"]),
            value: folder["name"] + ":" + folder["id"],
          ));
        }
        if (widget.recurringInfo == null) {
          initRecurring();
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
    bCustomContent =
        widget.recurringInfo["custom_content_on"] == "YES" ? true : false;
    _txtNotes.text = widget.recurringInfo["custom_content"];

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
    var temp = widget.recurringInfo["product_ids"];
    var tmpProducts = temp.split(",");

    for (var tmp in tmpProducts) {
      for (var prod in products) {
        if (prod["id"] == tmp) {
          selectedProducts.add(prod);
        }
      }
    }
    recurringId = widget.recurringInfo["id"];
  }

  String getTmpCustomContent(String tmpID) {
    String tmpStrID = tmpID.toString().split(":")[1];
    for (var tmp in templates) {
      if (tmp["id"] == tmpStrID) {
        return tmp["custom_content"];
      }
    }
    return null;
  }

  void sendInvoiceTmp(BuildContext context) {
    if (_txtFromEmail.text == "") {
      showErrorToast("Please fill from email");
    } else if (selectedProducts.length == 0) {
      showErrorToast("Please select products");
    } else if (tmpID == null) {
      showErrorToast("Please select template");
    } else {
      List<String> arrSelProducts = new List<String>();
      for (var to in selectedProducts) {
        arrSelProducts.add(to["id"]);
      }
      String selProducts = arrSelProducts.join(", ");
      String selTmpID = tmpID.toString().split(":")[1];
      String selFromEmail = _txtFromEmail.text;
      String payLink = _txtPayLink.text;

      final body = {
        "user_id": widget.userInfo.id,
        "tmp_id": selTmpID,
        "receiver_id": widget.contactInfo["id"],
        "sender": selFromEmail,
        "products": selProducts,
        "pay_link": _bPayLinkOn ? payLink : "",
        "pay_link_on": _bPayLinkOn ? "YES" : "NO",
        "pay_button_on": _bPayButtonOn ? "YES" : "NO",
        "custom_content_on": bCustomContent ? "YES" : "NO",
        "custom_content": bCustomContent ? _txtNotes.text : "",
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
        "recurring_id": recurringId,
        "inv_num": _txtInvNum.text,
        "inv_date": _txtInvDate.text,
      };

      ApiService.sendInvoiceTmp(body).then((response) {
        if (response != null && response["status"]) {
          if (response["code"] != null) {
            showSuccessToast("Saved Recurring Invoice successfully");
          } else {
            showSuccessToast("Sent invoice successfully");
          }
        } else {
          showErrorToast("Something error");
        }
      });
    }
  }

  void addToProducts(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ProductSearchDlg(
              products: products,
              selectedProducts: selectedProducts,
              onSelectedProductsListChanged: (products) {
                selectedProducts = products;
                if (selectedProducts.length > 0) {
                  _txtProduct.text = selectedProducts.length > 1
                      ? selectedProducts[0]["name"] +
                          " + " +
                          (selectedProducts.length - 1).toString() +
                          " products"
                      : selectedProducts[0]["name"];
                  if (selectedProducts.length == 1) {
                    _txtPayLink.text = selectedProducts[0]["pay_link"];
                  }
                } else {
                  _txtProduct.text = "";
                }
                setState(() {});
              });
        });
  }

  List<Widget> _refreshProductInfo() {
    List<Widget> pInfos = new List<Widget>();
    for (var item in selectedProducts) {
      pInfos.add(Padding(
        padding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 2.0),
        child: SelectableText(
          item["name"] + " :  \$" + item["price"],
          style: normalStyle.copyWith(fontSize: 18.0),
        ),
      ));
    }
    return pInfos;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedProducts.length > 0) {
      _txtProduct.text = selectedProducts.length > 1
          ? selectedProducts[0]["name"] +
              " + " +
              (selectedProducts.length - 1).toString() +
              " products"
          : selectedProducts[0]["name"];
    } else {
      _txtProduct.text = "";
    }
    _txtFromEmail.text = widget.userInfo.userEmail;
    _txtToEmail.text = widget.contactInfo["name"];
    final titleButtonRow = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: widget.recurringInfo == null
                ? Text(
                    "New Invoice",
                    style: normalStyle.copyWith(
                        fontSize: 25.0, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "Edit Recurring Invoice",
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
                    sendInvoiceTmp(context);
                  },
                ))),
      ],
    );
    final toEmailRow = Padding(
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
    );
    final fromEmailRow = Padding(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 12.0),
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
    final templateRow = Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 0),
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
                  bCustomContent = true;
                  _txtNotes.text = getTmpCustomContent(value);
                });
              },
            )),
      ],
    );
    final productRow = Row(
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
                labelText: 'Products',
                contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
              ),
              controller: _txtProduct,
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
              child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 35.0,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    addToProducts(context);
                  }),
            )),
      ],
    );

    final payLinkRow =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
        flex: 6,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
          child: Text(
            "PayLink On/Off",
            style: normalStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
            child: Switch(
              value: _bPayLinkOn,
              onChanged: (value) {
                setState(() {
                  _bPayLinkOn = value;
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            )),
      ),
      Expanded(
          flex: 11,
          child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 0.0),
              child: Visibility(
                visible: _bPayLinkOn,
                child: TextField(
                  style: normalStyle,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    labelText: 'Pay link',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                  ),
                  controller: _txtPayLink,
                ),
              ))),
    ]);
    final payButtonRow =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 0.0),
        child: Text(
          "PayNow Button On/Off",
          style: normalStyle,
          textAlign: TextAlign.right,
        ),
      ),
      Padding(
          padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
          child: Switch(
            value: _bPayButtonOn,
            onChanged: (value) {
              setState(() {
                _bPayButtonOn = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )),
    ]);
    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 10.0),
      child: TextField(
        maxLines: 4,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Custom Content',
          contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        ),
        controller: _txtNotes,
      ),
    );
    final billToRow = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 5.0),
          child: Text(
            "Bill To",
            style: normalStyle.copyWith(
                fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 2.0),
          child: SelectableText(
            "Name: " + widget.contactInfo["name"],
            style: normalStyle.copyWith(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 2.0),
          child: SelectableText(
            "Address: " + widget.contactInfo["address"],
            style: normalStyle.copyWith(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 2.0),
          child: SelectableText(
            "Email: " + widget.contactInfo["email"],
            style: normalStyle.copyWith(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 2.0),
          child: SelectableText(
            "Phone: " + widget.contactInfo["phone"],
            style: normalStyle.copyWith(fontSize: 18.0),
          ),
        ),
      ],
    );
    final productTitleRow = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 5.0),
          child: Text(
            "Product",
            style: normalStyle.copyWith(
                fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
    final invoiceNumDate = Padding(
      padding: EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: TextField(
                controller: _txtInvNum,
                style: normalStyle,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  labelText: 'Invoice Number',
                  contentPadding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 6.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(""),
            flex: 1,
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: DateTimeField(
                format: format,
                controller: _txtInvDate,
                decoration: InputDecoration(
                  labelText: 'Due Date',
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
        ],
      ),
    );

    //////////// for Recurring ////
    final recurringRow =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
          flex: 3,
          child: Row(
            children: [
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
                            });
                          }
                        : null,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  )),
            ],
          )),
      Expanded(
          flex: 4,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: Text(
                  "Custom Content",
                  style: normalStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Switch(
                    value: bCustomContent,
                    onChanged: (value) {
                      setState(() {
                        bCustomContent = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  )),
            ],
          ))
    ]);

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
        title: const Text("Send Invoice"),
      ),
      backgroundColor: Colors.white,
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
                      templateRow,
                      productRow,
                      payLinkRow,
                      payButtonRow,
                      recurringRow,
                      Visibility(
                        visible: bCustomContent,
                        child: notesRow,
                      ),
                      invoiceNumDate,
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
                      billToRow,
                      productTitleRow,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _refreshProductInfo(),
                      )
                    ],
                  )),
                ]),
              ),
            ),
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          )),
    );
  }
}

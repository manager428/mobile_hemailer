import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:intl/intl.dart';

class SearchOptionDlg extends StatefulWidget {
  final List<dynamic> selectedOption;
  final ValueChanged<List<dynamic>> onSelectedOptionChanged;
  SearchOptionDlg(
      {Key key, @required this.selectedOption, this.onSelectedOptionChanged})
      : super(key: key);

  @override
  _SearchOptionDlgState createState() => _SearchOptionDlgState();
}

class _SearchOptionDlgState extends State<SearchOptionDlg> {
  List<dynamic> _tempSelectedOption = new List<dynamic>();
  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();

  TextEditingController _txtStartDate = new TextEditingController();
  TextEditingController _txtEndDate = new TextEditingController();
  var startDate, endDate;

  bool _bNewSub = false;
  bool _bRecurring = false;
  bool _bCancelled = false;
  bool _bFlag = false;
  bool _bUnSub = false;
  bool _bOnline = false;
  bool _bCustomize = false;
  @override
  void initState() {
    _tempSelectedOption = widget.selectedOption;
    super.initState();
    setState(() {
      _txtStartDate.text = _tempSelectedOption[0];
      _txtEndDate.text = _tempSelectedOption[1];
      _bNewSub = _tempSelectedOption[2];
      _bRecurring = _tempSelectedOption[3];
      _bCancelled = _tempSelectedOption[4];
      _bFlag = _tempSelectedOption[5];
      _bUnSub = _tempSelectedOption[6];
      _bOnline = _tempSelectedOption[7];
      _bCustomize = _tempSelectedOption[8];
    });
  }

  void onSearchOptionChangedDone(BuildContext context) {
    _tempSelectedOption[0] = _txtStartDate.text;
    _tempSelectedOption[1] = _txtEndDate.text;
    _tempSelectedOption[2] = _bNewSub;
    _tempSelectedOption[3] = _bRecurring;
    _tempSelectedOption[4] = _bCancelled;
    _tempSelectedOption[5] = _bFlag;
    _tempSelectedOption[6] = _bUnSub;
    _tempSelectedOption[7] = _bOnline;
    _tempSelectedOption[8] = _bCustomize;
    widget.onSelectedOptionChanged(_tempSelectedOption);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rowDateRange = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
              child: DateTimeField(
                format: format,
                controller: _txtStartDate,
                onChanged: (value) {
                  if (startDate != _txtStartDate.text) {
                    startDate = _txtStartDate.text;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Start date',
                  contentPadding: EdgeInsets.fromLTRB(4.0, 6.0, 4.0, 6.0),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
            )),
        Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
              child: DateTimeField(
                format: format,
                controller: _txtEndDate,
                onChanged: (value) {
                  if (endDate != _txtEndDate.text) {
                    endDate = _txtEndDate.text;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'End date',
                  contentPadding: EdgeInsets.fromLTRB(4.0, 6.0, 4.0, 6.0),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
            )),
      ],
    );

    return Dialog(
        child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Search Option',
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  onPressed: () {
                    onSearchOptionChangedDone(context);
                  },
                  color: Colors.blueAccent,
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          rowDateRange,
          Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        "New Subscriber",
                        style: normalStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Switch(
                          value: _bNewSub,
                          onChanged: (value) {
                            setState(() {
                              _bNewSub = value;
                              _bRecurring = false;
                              _bCancelled = false;
                              _bFlag = false;
                              _bUnSub = false;
                              _bOnline = false;
                              _bCustomize = false;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        )),
                  )
                ],
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Recurring Subscriber",
                        style: normalStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Switch(
                          value: _bRecurring,
                          onChanged: (value) {
                            setState(() {
                              _bRecurring = value;
                              _bNewSub = false;
                              _bCancelled = false;
                              _bFlag = false;
                              _bUnSub = false;
                              _bOnline = false;
                              _bCustomize = false;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        )),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Cancelled",
                        style: normalStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Switch(
                          value: _bCancelled,
                          onChanged: (value) {
                            setState(() {
                              _bCancelled = value;
                              _bRecurring = false;
                              _bNewSub = false;
                              _bFlag = false;
                              _bUnSub = false;
                              _bOnline = false;
                              _bCustomize = false;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        )),
                  )
                ],
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Flag",
                        style: normalStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Switch(
                          value: _bFlag,
                          onChanged: (value) {
                            setState(() {
                              _bCancelled = false;
                              _bRecurring = false;
                              _bNewSub = false;
                              _bFlag = value;
                              _bUnSub = false;
                              _bOnline = false;
                              _bCustomize = false;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        )),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Unsubscribe",
                        style: normalStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Switch(
                          value: _bUnSub,
                          onChanged: (value) {
                            setState(() {
                              _bCancelled = false;
                              _bRecurring = false;
                              _bNewSub = false;
                              _bFlag = false;
                              _bUnSub = value;
                              _bOnline = false;
                              _bCustomize = false;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        )),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Online Chat",
                      style: normalStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Switch(
                        value: _bOnline,
                        onChanged: (value) {
                          setState(() {
                            _bCancelled = false;
                            _bRecurring = false;
                            _bNewSub = false;
                            _bFlag = false;
                            _bUnSub = false;
                            _bOnline = value;
                            _bCustomize = false;
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Custom",
                      style: normalStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Switch(
                        value: _bCustomize,
                        onChanged: (value) {
                          setState(() {
                            _bCancelled = false;
                            _bRecurring = false;
                            _bNewSub = false;
                            _bFlag = false;
                            _bUnSub = false;
                            _bOnline = false;
                            _bCustomize = value;
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

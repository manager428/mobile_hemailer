import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class NoteAddScreen extends StatefulWidget {
  final dynamic noteInfo;
  final dynamic contactInfo;
  final UserModel userInfo;
  NoteAddScreen({Key key, @required this.noteInfo, this.contactInfo, this.userInfo}) : super(key: key);
  @override
  _NoteAddScreenState createState() => _NoteAddScreenState();
  
}

class _NoteAddScreenState extends State<NoteAddScreen>{
  TextEditingController _txtNotes = new TextEditingController();
  TextEditingController _txtStartAt = new TextEditingController();
  TextEditingController _txtReminderDate = new TextEditingController();
  TextEditingController _txtReminderTime = new TextEditingController();
  bool _progressBarActive = false;
  bool _bImportant = false;
  bool _bReminder = false;

  double totalPrice;
  var format = new DateFormat("yyyy-MM-dd");
  final formatTime = DateFormat("HH:mm");
  var now = new DateTime.now();
  @override
  void initState(){
    super.initState();
    // edit page
    initNote();
    if(widget.noteInfo != null){
      _txtNotes.text = widget.noteInfo["title"];
      _txtStartAt.text = widget.noteInfo["start"];
      _bReminder = widget.noteInfo["schedule_on"] == "YES" ? true : false;
      _bImportant = widget.noteInfo["note_important"] == "YES" ? true : false;
      if(_bReminder){
        _txtReminderDate.text = widget.noteInfo["schedule_day"];
        _txtReminderTime.text = widget.noteInfo["schedule_time"];
      }
    }
  }
  
  void saveNote(BuildContext context){
    if(_txtNotes.text.trim() == ""){
      showErrorToast("Please fill notes");
    }else{
      var noteID = widget.noteInfo == null ? "-1": widget.noteInfo["id"];
      
      final body = {
        "event_id": noteID,
        "email_id": widget.contactInfo["id"],
        "note_important": _bImportant ? "YES" : "NO",
        "schedule_on": _bReminder ? "YES" : "NO",
        "title": _txtNotes.text.trim(),
        "schedule_time": _txtReminderTime.text.trim(),
        "schedule_day": _txtReminderDate.text.trim(),
        "start": _txtStartAt.text.trim(),
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.saveNote(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null && response["status"]) {
          showSuccessToast("Saved Note");
          if(widget.noteInfo == null){
            initNote();
          }else{
            Navigator.of(context).pop();
          }
        }else{
          showErrorToast("Something error");
        }
      });
    }
  }
  void initNote(){
    _txtNotes.text = "";
    _txtStartAt.text = format.format(now);
    _txtReminderDate.text = format.format(now);
    _txtReminderTime.text = formatTime.format(now);
  }
  @override
  Widget build(BuildContext context) {
    
    
    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 12.0),
      child: TextField(
        maxLines: 4,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(labelText: 'Notes',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtNotes,
      ),
    );
    final createdAtRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: DateTimeField(
        format: format,
        controller: _txtStartAt,
        decoration: InputDecoration(labelText: 'Event date',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        },
      ),
    );
    final switchRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            Switch(
              value: _bImportant,
              onChanged: (value) {
                setState(() {
                  _bImportant = value;
                });
              },
              activeTrackColor: Colors.lightBlueAccent, 
              activeColor: Colors.blue,
            ),
            Text("Important", style:normalStyle, textAlign: TextAlign.right,),
          ],
        ),
        Row(
          children: <Widget>[
            Switch(
              value: _bReminder,
              onChanged: (value) {
                setState(() {
                  _bReminder = value;
                });
              },
              activeTrackColor: Colors.lightBlueAccent, 
              activeColor: Colors.blue,
            ),
            Text("Email Reminder", style:normalStyle, textAlign: TextAlign.right,),
          ],
        ),
      ]
    );
    final reminderRow = Visibility(
      visible: _bReminder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.fromLTRB(30.0, 6.0, 10.0, 0.0),
                child: DateTimeField(
                format: format,
                controller: _txtReminderDate,
                decoration: InputDecoration(labelText: 'reminder date',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
                },
              ),
            )
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.fromLTRB(2.0, 6.0, 30.0, 0.0),
              child: DateTimeField(
                format: formatTime,
                controller: _txtReminderTime,
                decoration: InputDecoration(labelText: 'reminder date',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.convert(time);
                },
              ),
            )
          ),
        ],
      )
    );
    
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
                saveNote(context);
              },
              child: Text(
                "Save",
                style: normalStyle,
              ),
            ),
          )
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              splashColor: Colors.blueAccent,
              onPressed: () {
                if(widget.noteInfo == null){
                  initNote();
                }else{
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Cancel",
                style: normalStyle,
              ),
            ),
          )
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: widget.noteInfo != null? const Text("Edit Note"): const Text("Add Note"),),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child:Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 80.0,),
                Center(
                  child: Column(
                    children: <Widget>[
                      createdAtRow,
                      notesRow,
                      switchRow,
                      reminderRow,
                      btnRow,
                      
                      // reminderRow                   
                    ],
                  )
                ),
                
              ]
            ),
          ),
        ),
      ),
    );
  }
}
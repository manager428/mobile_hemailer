import 'package:flutter/material.dart';

import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class ExtraInfoAddScreen extends StatefulWidget {
  final dynamic extraInfo;
  final dynamic contactInfo;
  ExtraInfoAddScreen({Key key, @required this.extraInfo, this.contactInfo}) : super(key: key);
  @override
  _ExtraInfoAddScreenState createState() => _ExtraInfoAddScreenState();
  
}

class _ExtraInfoAddScreenState extends State<ExtraInfoAddScreen>{
  TextEditingController _txtTitle = new TextEditingController();
  TextEditingController _txtInfo = new TextEditingController();
  bool _bAllContact = false;
  bool _progressBarActive = false;
  @override
  void initState(){
    super.initState();
    // edit page
    if(widget.extraInfo != null){
      _txtTitle.text = widget.extraInfo["title"];
      _txtInfo.text = widget.extraInfo["info"];
    }
  }
  
  void saveExtraInfo(BuildContext context){
    if(_txtTitle.text.trim() == "" && _txtInfo.text.trim() == ""){
      showErrorToast("Please fill price");
    }else{
      var extraID = widget.extraInfo == null ? "-1": widget.extraInfo["id"];
      final body = {
        "extra_id": extraID,
        "email_id": widget.contactInfo["id"],
        "title": _txtTitle.text.trim(),
        "info": _txtInfo.text.trim(),
        "sel_all_contact": _bAllContact ? "YES": "NO",
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.saveExtraInfo(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null && response["status"]) {
          showSuccessToast("Saved");
          if(widget.extraInfo == null){
            cancelExtraInfo();
          }else{
            Navigator.of(context).pop();
          }
        }else{
          showErrorToast("Something error");
        }
      });
    }
  }
  void cancelExtraInfo(){
    _txtTitle.text = "";
    _txtInfo.text = "";
  }
  @override
  Widget build(BuildContext context) {
    
    final titleRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(labelText: 'Title',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtTitle,
      ),
    );
    final infoRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(labelText: 'Info',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtInfo,
      ),
    );
    
    final allContactRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(60.0, 12.0, 0, 0),
          child: Switch(
            value: _bAllContact,
            onChanged: (value) {
              setState(() {
                _bAllContact = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent, 
            activeColor: Colors.green,
          )
        ),
         Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text("all contact list", style:normalStyle, textAlign: TextAlign.right,),
        ),
        
      ]
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
                saveExtraInfo(context);
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
                if(widget.extraInfo == null){
                  cancelExtraInfo();
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
      appBar: AppBar(title: widget.extraInfo != null? const Text("Edit Extra Info"): const Text("Add Extra Info"),),
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
                      titleRow,
                      infoRow,
                      allContactRow,
                      btnRow                    
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
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/utils/contacts_search_dlg.dart';


class SendContractScreen extends StatefulWidget {
  final dynamic contactInfo;
  final List<dynamic> allContacts;
  final UserModel userInfo;
  SendContractScreen({Key key, @required this.contactInfo, this.userInfo, this.allContacts}) : super(key: key);
  @override
  _SendContractScreenState createState() => _SendContractScreenState();
}

class _SendContractScreenState extends State<SendContractScreen>{
  TextEditingController _txtToEmail = new TextEditingController();
  TextEditingController _txtFromEmail = new TextEditingController();
  bool _progressBarActive = false;

  List<DropdownMenuItem> itemsFolder = [];
  List<DropdownMenuItem> itemsTemplate = [];
  
  String folderID = "Saved Template:0";
  String tmpID;
  String tmpThumb;
  String expireMinutes = "0";
  List<dynamic> folders;
  List<dynamic> templates;
  
  List<dynamic> selectedContacts = new List<dynamic>();
  @override
  void initState(){
    super.initState();
    selectedContacts.add(widget.contactInfo);
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getContractTmp(body).then((response) {
      setState(() {
        _progressBarActive = false;
        folders = response["folder_data"];
        templates = response["tmp_data"];
        itemsFolder.add(new DropdownMenuItem(
          child: new Text(
            "Saved Template"
          ),
          value: "Saved Template:0",
        ));
        for(var folder in folders){
          itemsFolder.add(new DropdownMenuItem(
            child: new Text(
              folder["name"],
              overflow: TextOverflow.ellipsis,
            ),
            value: folder["name"]+":"+folder["id"],
          ));
        }
        getTemplateItems("Saved Template:0");
      });
    });
  }
  void getTemplateItems(String folderStrID){
    String foldID = folderStrID.toString().split(":")[1];
    itemsTemplate.clear();
    for(var folder in templates){
      if(folder["folder_id"] == foldID){
        for(var tmp in folder["tmp_data"]){
          itemsTemplate.add(new DropdownMenuItem(
            child: new Text(
              tmp["name"],
              overflow: TextOverflow.ellipsis,
            ),
            value: tmp["name"]+":"+tmp["id"],
          ));
        }
      }
    }
  }
  String getTmpThumb(String tmpID){
    String tmpStrID = tmpID.toString().split(":")[1];
    String folderStrID = folderID.toString().split(":")[1];
    for(var folder in templates){
      if(folder["folder_id"] == folderStrID){
        for(var tmp in folder["tmp_data"]){
          if(tmp["id"]==tmpStrID){
            return tmp["tmp_thumb"];
          }
        }
      }
    }
    return null;
  }
  
  void sendContractTmp(BuildContext context){
    if(_txtFromEmail.text==""){
      showErrorToast("Please fill from email");
    }else if(selectedContacts.length == 0){
      showErrorToast("Please select to email");
    }else if(tmpID == null){
      showErrorToast("Please select template");
    }else{
      List<String> arrSelToEmailID = new List<String>();
      for (var to in selectedContacts){
        arrSelToEmailID.add(to["id"]);
      }
      String selToEmailID = arrSelToEmailID.join(", ");
      String selTmpID = tmpID.toString().split(":")[1];
      String selFromEmail = _txtFromEmail.text;
      
      final body = {
        "user_id": widget.userInfo.id,
        "tmp_id": selTmpID,
        "receiver_id": selToEmailID,
        "sender": selFromEmail,
      };
      ApiService.sendContractTmp(body).then((response) {
        if (response != null && response["status"]) {
          showSuccessToast("Sent contract successfully");
        }else{
          showErrorToast("Something error");
        }
      });
    }
  }
  void addToContacts(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return ContactSearchDlg(
          contacts: widget.allContacts,
          selectedContacts: selectedContacts,
          onSelectedContactsListChanged: (contacts) {
            selectedContacts = contacts;
            if(selectedContacts.length>0){
              _txtToEmail.text = selectedContacts.length > 1 ? selectedContacts[0]["name"] + " + " + (selectedContacts.length -1).toString() +" contacts": selectedContacts[0]["name"];
            }else{
              _txtToEmail.text = "";
            }
            
          }
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    if(selectedContacts.length>0){
      _txtToEmail.text = selectedContacts.length > 1 ? selectedContacts[0]["name"] + " + " + (selectedContacts.length -1).toString() +" contacts": selectedContacts[0]["name"];
    }else{
      _txtToEmail.text = "";
    }
    _txtFromEmail.text = widget.userInfo.userEmail;
    final titleButtonRow = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("New Contract", style:normalStyle.copyWith(fontSize: 25.0, fontWeight: FontWeight.bold ),),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: FlatButton.icon(
              color: Colors.blueAccent,
              icon: Icon(Icons.send, color: Colors.white,), //`Icon` to display
              label: Text('Send', style: normalStyle.copyWith(color: Colors.white,),), //`Text` to display
              onPressed: () {
                sendContractTmp(context);
              },
            )
          )
        ),
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
              decoration: new InputDecoration(labelText: 'To',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
              controller: _txtToEmail,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
            child: IconButton(icon: Icon(Icons.person_add, size: 35.0, color: Colors.blueAccent,),  onPressed: (){
              addToContacts(context);
            }),
            
          )
        ),
      ],
    );
    final fromEmailRow = Padding(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 6.0, 0.0),
      child: TextField(
        enabled: widget.userInfo.emailChange == "YES" ? true: false,
        style: normalStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(labelText: 'From',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtFromEmail,
      ),
    );
    final folderRow = Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 12.0, 0.0, 0),
            child: Text("Folder", style:normalStyle,),
          ),
        ),
        Expanded(
          flex: 7,
          child: SearchableDropdown(
            items: itemsFolder,
            value: folderID,
            hint: new Text(
              'Select Folder'
            ),
            searchHint: new Text(
              'Select Folder',
              style: new TextStyle(
                  fontSize: 20
              ),
            ),
            onChanged: (value) {
              setState(() {
                folderID = value;
                tmpID = null;
                tmpThumb = null;
                getTemplateItems(folderID);
              });
            },
          )
        ),
      ],
    );
    final templateRow = Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 12.0, 0.0, 0),
            child: Text("Template", style:normalStyle,),
          ),
        ),
        Expanded(
          flex: 7,
          child: SearchableDropdown(
            items: itemsTemplate,
            value: tmpID,
            isExpanded:false,
            hint: new Text(
              'Select Template'
            ),
            searchHint: new Text(
              'Select Template',
              style: new TextStyle(
                  fontSize: 20
              ),
            ),
            onChanged: (value) {
              setState(() {
                tmpID = value;
                tmpThumb = getTmpThumb(tmpID);
              });
            },
          )
        ),
      ],
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text("Send Contract"),),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child:Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      titleButtonRow,
                      toEmailRow,
                      fromEmailRow,
                      folderRow,
                      templateRow,
                      Card(
                        margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                        child: Image(
                          image: tmpThumb != null? NetworkImage(tmpThumb):AssetImage("assets/default.jpg"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
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


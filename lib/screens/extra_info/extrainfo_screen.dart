import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/extra_info/add_extrainfo_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ExtraInfoScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  ExtraInfoScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _ExtraInfoScreenState createState() => _ExtraInfoScreenState();
}

class _ExtraInfoScreenState extends State<ExtraInfoScreen> {
  List<dynamic> allExtraInfo;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshExtraInfos();
  }

  void refreshExtraInfos() {
    final body = {
      "email_id": widget.contactInfo["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getExtraInfos(body).then((response) {
      setState(() {
        allExtraInfo = response;
        _progressBarActive = false;
      });
    });
  }

  void addExtraInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraInfoAddScreen(
          extraInfo: null,
          contactInfo: widget.contactInfo,
        ),
      ),
    ).then((val) {
      refreshExtraInfos();
    });
  }

  void editExtraInfo(dynamic expense, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraInfoAddScreen(
          extraInfo: expense,
          contactInfo: widget.contactInfo,
        ),
      ),
    ).then((val) {
      refreshExtraInfos();
    });
  }

  Future<void> deleteExtraInfo(dynamic extraInfo, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "extra_id": extraInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteExtraInfo(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
            allExtraInfo.remove(extraInfo);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra Infos"),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addExtraInfo(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      // itemExtent: 70.0,
                      itemCount: allExtraInfo != null ? allExtraInfo.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          //                           <-- Card widget
                          child: ListTile(
                            title: SelectableText(allExtraInfo[index]["title"]),
                            subtitle:
                                SelectableText(allExtraInfo[index]["info"]),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    editExtraInfo(allExtraInfo[index], context);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                    size: 20.0,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deleteExtraInfo(
                                        allExtraInfo[index], context);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.blueAccent,
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

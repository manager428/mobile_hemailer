import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/notes/add_notes_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class NotesScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  NotesScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> allNotes;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  void refreshNotes() {
    final body = {
      "email_id": widget.contactInfo["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getNotes(body).then((response) {
      setState(() {
        _progressBarActive = false;
        allNotes = response;
      });
    });
  }

  void addNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddScreen(
          noteInfo: null,
          contactInfo: widget.contactInfo,
          userInfo: widget.userInfo,
        ),
      ),
    ).then((val) {
      refreshNotes();
    });
  }

  void editNote(dynamic expense, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddScreen(
          noteInfo: expense,
          contactInfo: widget.contactInfo,
          userInfo: widget.userInfo,
        ),
      ),
    ).then((val) {
      refreshNotes();
    });
  }

  Future<void> deleteNote(dynamic expense, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "event_id": expense["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteNote(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
            allNotes.remove(expense);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNote(context);
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
                      itemCount: allNotes != null ? allNotes.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          //                           <-- Card widget
                          child: ListTile(
                            title: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      allNotes[index]["start"],
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Visibility(
                                        visible: allNotes[index]
                                                    ["note_important"] ==
                                                "YES"
                                            ? true
                                            : false,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              18.0, 0.0, 12.0, 0.0),
                                          child: Icon(
                                            Icons.flag,
                                            color: Colors.red,
                                          ),
                                        )),
                                    Visibility(
                                        visible: allNotes[index]
                                                    ["schedule_on"] ==
                                                "YES"
                                            ? true
                                            : false,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              18.0, 0.0, 12.0, 0.0),
                                          child: Icon(
                                            Icons.alarm_on,
                                            color: Colors.red,
                                          ),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                            subtitle: SelectableText(allNotes[index]["title"]),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    editNote(allNotes[index], context);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                    size: 20.0,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deleteNote(allNotes[index], context);
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

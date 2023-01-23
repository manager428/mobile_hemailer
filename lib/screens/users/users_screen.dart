import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/users/add_user_screen.dart';
import 'package:hemailer/screens/users/user_detail_screen.dart';
import 'package:hemailer/screens/users/users_admin_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UsersScreen extends StatefulWidget {
  final UserModel userInfo;
  UsersScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> allUsers;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshUsers();
  }

  void refreshUsers() {
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getUsers(body).then((response) {
      setState(() {
        allUsers = response;
        _progressBarActive = false;
      });
    });
  }

  Future<void> deleteUser(dynamic userInfo, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "id": userInfo["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deleteUser(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
            allUsers.remove(userInfo);
          });
        }
      });
    }
  }

  void addUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserAddScreen(contactInfo: null, userInfo: widget.userInfo),
      ),
    ).then((val) {
      refreshUsers();
    });
  }

  void adminUser(BuildContext context, dynamic adminInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsersAdminScreen(
            adminUserModel: adminInfo, userInfo: widget.userInfo),
      ),
    ).then((val) {
      refreshUsers();
    });
  }

  Widget getProfit(dynamic userInfo) {
    if (userInfo["profit"]["sum_price"] != null &&
        userInfo["profit"]["sum_expense"] != null) {
      return Text(
          (double.parse(userInfo["profit"]["sum_price"]) -
                      double.parse(userInfo["profit"]["sum_expense"]))
                  .toString() +
              "\$",
          style: normalStyle.copyWith(color: Colors.red));
    } else {}
    return Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        userInfo: widget.userInfo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addUser(context);
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
                      itemCount: allUsers != null ? allUsers.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Text(allUsers[index]["username"]),
                                ),
                                getProfit(allUsers[index]),
                              ],
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Text(allUsers[index]["email"]),
                                ),
                                Visibility(
                                  visible: allUsers[index]["level"] == "Admin"
                                      ? true
                                      : false,
                                  child: InkWell(
                                    onTap: () {
                                      adminUser(context, allUsers[index]);
                                    },
                                    child: Icon(
                                      Icons.group,
                                      color: Colors.blueAccent,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            leading: Container(
                              width: 54.0,
                              height: 54.0,
                              decoration: new BoxDecoration(
                                color: const Color(0xff7c94b6),
                                image: new DecorationImage(
                                  image: new NetworkImage(allUsers[index]
                                              ["photo_url"] ==
                                          ""
                                      ? baseURL + 'uploads/avatar/profile.jpg'
                                      : baseURL + allUsers[index]["photo_url"]),
                                ),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(27.0)),
                                border: new Border.all(
                                  color: allUsers[index]["status"] == "Active"
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                deleteUser(allUsers[index], context);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.blueAccent,
                                size: 20.0,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(
                                    contactInfo: allUsers[index],
                                    userInfo: widget.userInfo,
                                  ),
                                ),
                              ).then((val) {
                                refreshUsers();
                              });
                            },
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

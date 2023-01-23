import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/users/add_user_screen.dart';
import 'package:hemailer/screens/users/user_detail_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UsersAdminScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic adminUserModel;
  UsersAdminScreen({Key key, @required this.userInfo, this.adminUserModel})
      : super(key: key);
  @override
  _UsersAdminScreenState createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  List<dynamic> allUsersAdmin;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshUsersAdmin();
  }

  void refreshUsersAdmin() {
    final body = {
      "user_id": widget.adminUserModel["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getUsersAdmin(body).then((response) {
      setState(() {
        allUsersAdmin = response;
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
            allUsersAdmin.remove(userInfo);
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
      refreshUsersAdmin();
    });
  }

  void adminUser(BuildContext context) {}
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
        title: Text("Users of " + widget.adminUserModel["username"].toString()),
      ),
      backgroundColor: Colors.white,
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
                      itemCount:
                          allUsersAdmin != null ? allUsersAdmin.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Text(allUsersAdmin[index]["username"]),
                                ),
                                getProfit(allUsersAdmin[index]),
                              ],
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Text(allUsersAdmin[index]["email"]),
                                ),
                                Visibility(
                                  visible:
                                      allUsersAdmin[index]["level"] == "Admin"
                                          ? true
                                          : false,
                                  child: InkWell(
                                    onTap: () {},
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
                                  image: new NetworkImage(allUsersAdmin[index]
                                              ["photo_url"] ==
                                          ""
                                      ? baseURL + 'uploads/avatar/profile.jpg'
                                      : baseURL +
                                          allUsersAdmin[index]["photo_url"]),
                                ),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(27.0)),
                                border: new Border.all(
                                  color:
                                      allUsersAdmin[index]["status"] == "Active"
                                          ? Colors.green
                                          : Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                deleteUser(allUsersAdmin[index], context);
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
                                    contactInfo: allUsersAdmin[index],
                                    userInfo: widget.userInfo,
                                  ),
                                ),
                              ).then((val) {
                                refreshUsersAdmin();
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

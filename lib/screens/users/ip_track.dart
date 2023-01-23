import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:hemailer/widgets/drawer_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hemailer/utils/geolocation_custom.dart';

class IptrackScreen extends StatefulWidget {
  final UserModel userInfo;
  IptrackScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _IptrackScreenState createState() => _IptrackScreenState();
}

class _IptrackScreenState extends State<IptrackScreen> {
  List<dynamic> allInfos;
  bool _progressBarActive = false;
  List<bool> _active = [];
  GeolocationData geolocationData;
  @override
  void initState() {
    super.initState();

    refreshIps();
  }

  void refreshIps() async {
    final body = {
      "level": widget.userInfo.userLevel,
    };
    setState(() {
      _progressBarActive = true;
    });
    geolocationData = await GeolocationAPI.getData();
    ApiService.getIps(body).then((response) {
      setState(() {
        allInfos = response;
        print(response);
        _progressBarActive = false;
        for (var i = 0; i < allInfos.length; i++) {
          _active.add(stringToBoolean(allInfos[i]['status']));
        }
      });
    });
  }

  void activeStatus(id, status) {
    final body = {
      "id": id,
      "status": status,
    };

    setState(() {
      _progressBarActive = true;
    });
    ApiService.activeStatus(body).then((response) {
      setState(() {
        _progressBarActive = false;
        if (response['status'] == 'false') {
          showErrorToast("Something went wrong.");
        }
      });
    });
  }

  stringToBoolean(string) {
    bool active = string == '1' ? true : false;
    return active;
  }

  booleanToString(bool active) {
    String status = active == true ? "1" : "0";
    return status;
  }
  // Future<void> deleteUser(dynamic userInfo, BuildContext context) async {
  //   final ConfirmAction action = await confirmDialog(context);

  //   if (action == ConfirmAction.YES) {
  //     final body = {
  //       "id": userInfo["id"],
  //     };
  //     setState(() {
  //       _progressBarActive = true;
  //     });
  //     ApiService.deleteUser(body).then((response) {
  //       if (response != null && response["status"]) {
  //         setState(() {
  //           _progressBarActive = false;
  //           allUsers.remove(userInfo);
  //         });
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IP Tracking and Banner"),
      ),
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        userInfo: widget.userInfo,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allInfos != null ? allInfos.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: CircleAvatar(
                                backgroundImage: allInfos[index]['device']
                                            .toString()
                                            .substring(0, 1) ==
                                        'i'
                                    ? AssetImage('assets/apple.png')
                                    : AssetImage('assets/android.png'),
                                child: Text(
                                  "${allInfos[index]['device']}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              'Public IP: ${allInfos[index]['ip']}',
                              style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                '${allInfos[index]['country']}, ${allInfos[index]['city']}, (${allInfos[index]['region']} region), ${allInfos[index]['timezone']} timezone'),
                            trailing: Padding(
                              padding: EdgeInsets.only(left: 0.0),
                              child: Switch(
                                value: _active[index],
                                onChanged: (value) {
                                  String ip = allInfos[index]['ip'].toString();
                                  String status = booleanToString(value);
                                  String id = allInfos[index]['id'].toString();
                                  if (geolocationData.ip == ip) {
                                    showErrorToast(
                                        "It's your IP, so can't block it.");
                                  } else {
                                    setState(() {
                                      _active[index] = value;
                                    });

                                    activeStatus(id, status);
                                  }
                                },
                                inactiveThumbColor: _active[index]
                                    ? Colors.blue
                                    : Colors.white70,
                                inactiveTrackColor: _active[index]
                                    ? Colors.lightBlueAccent
                                    : Colors.grey.shade400,
                                activeTrackColor: Colors.lightBlueAccent,
                                activeColor: Colors.blue,
                              ),
                            ),
                            isThreeLine: true,
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

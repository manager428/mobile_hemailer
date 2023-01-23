import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/dashboard_screen.dart';
import 'package:hemailer/screens/reset_password_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:hemailer/utils/geolocation_custom.dart';
import 'package:device_info/device_info.dart';
import 'package:customprompt/customprompt.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _txtUserName = new TextEditingController();
  TextEditingController _txtPassword = new TextEditingController();
  bool _progressBarActive = false;
  bool enable = false;
  var session = FlutterSession();
  String text = '';
  GeolocationData geolocationData;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  @override
  void initState() {
    super.initState();
    // getDeviceinfo();
    _remember().then((userPass) {
      setState(() {
        _txtUserName.text = userPass[0];
        _txtPassword.text = userPass[1];
        if (userPass[2] != null) {
          enable = userPass[2];
        }
      });
    });
  }

  void getDeviceinfo() async {
    setState(() {
      _progressBarActive = true;
    });
    geolocationData = await GeolocationAPI.getData();
    var devInfo = '';
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.name;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
    }
    final body = {
      "country": geolocationData.country,
      "city": geolocationData.city,
      "region": geolocationData.regionName,
      "timezone": geolocationData.timezone,
      "ip": geolocationData.ip,
      "device": devInfo,
    };
    print(body);
    ApiService.ipTrack(body).then((response) async {
      setState(() {
        _progressBarActive = false;
      });
      if (!response['status']) {
        CustomPrompt(
          animDuration: 500,
          title: 'Error',
          type: Type.error,
          curve: Curves.easeInOut,
          transparent: true,
          context: context,
          btnOneText: Text(
            'Confirm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: 'Something went wrong or you are blocked by Super Admin',
          btnOneOnClick: () {
            exit(0);
          },
        ).alert();
      }
    });
  }

  _remember() async {
    var username = await session.get("username");
    var password = await session.get("password");
    var remember = await session.get("remember");
    var userPass = [username, password, remember];
    return userPass;
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
      controller: _txtUserName,
      obscureText: false,
      style: normalStyle,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "User Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      controller: _txtPassword,
      obscureText: true,
      style: normalStyle,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final rememberLogin = Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            checkColor: Colors.white,
            activeColor: Color(0xff4285f4),
            value: enable,
            onChanged: (bool value) {
              setState(
                () {
                  enable = value;
                },
              );
            },
          ),
          Container(
            child: Text(
              'Remember me',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff4285f4),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (_txtPassword.text.isEmpty || _txtUserName.text.isEmpty) {
            showErrorToast("Please fill username and password");
            print("object");
          } else {
            final body = {
              "username": _txtUserName.text.trim(),
              "password": _txtPassword.text.trim(),
            };
            setState(() {
              _progressBarActive = true;
            });
            ApiService.login(body).then((response) async {
              setState(() {
                _progressBarActive = false;
              });
              if (response != null && response["status"]) {
                var userInfo = response["user_info"];
                if (this.enable == true) {
                  await session.set("username", userInfo["username"]);
                  await session.set("password", _txtPassword.text);
                  await session.set("remember", true);
                } else {
                  await session.set("username", "");
                  await session.set("password", "");
                  await session.set("remember", false);
                }
                print(userInfo);
                UserModel userSelInfo = new UserModel(
                    userInfo["id"],
                    userInfo["username"],
                    userInfo["email"],
                    userInfo["level"],
                    userInfo["phone"],
                    userInfo["user_id"],
                    userInfo["photo_url"],
                    userInfo["chat_on"],
                    userInfo["onlinechat_on"],
                    userInfo["optin_form"],
                    userInfo["sales_funnel"],
                    userInfo["contracts_sign"],
                    userInfo["invoice_on"],
                    userInfo["analytics_on"],
                    userInfo["email_change"],
                    userInfo["self_destruct"]);
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    settings: const RouteSettings(name: '/home'),
                    builder: (context) =>
                        new HomeScreen(userInfo: userSelInfo)));
              } else {
                showErrorToast("Please fill correct username and password");
              }
            });
          }
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: normalStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final resetPasswordButon = Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff28a745),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(),
            ),
          );
        },
        child: Text("Forget Password",
            textAlign: TextAlign.center,
            style: normalStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      // appBar: AppBar(title: const Text("Login Page"),),

      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 45.0),
                    usernameField,
                    SizedBox(height: 25.0),
                    passwordField,
                    SizedBox(height: 10.0),
                    rememberLogin,
                    SizedBox(height: 20),
                    loginButon,
                    SizedBox(
                      height: 12.0,
                    ),
                    resetPasswordButon,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

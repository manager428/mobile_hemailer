
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    
    return new ResetPasswordScreenState();
  }
}

class ResetPasswordScreenState extends State<ResetPasswordScreen>{
  
  TextEditingController _txtEmail = new TextEditingController();
  bool _progressBarActive = false;
  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: _txtEmail,
      obscureText: false,
      keyboardType: TextInputType.emailAddress,
      style: normalStyle,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    
    final sendButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff4285f4),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
         
          if(_txtEmail.text.isEmpty){
            showErrorToast("Please fill email");
          }else{
            final body = {
              "email": _txtEmail.text.trim(),
            };
            setState(() {
              _progressBarActive = true;
            });
            ApiService.resetPassword(body).then((response) {
              setState(() {
                _progressBarActive = false;
              });
              if (response != null && response["status"]) {
                Navigator.pop(context);
              }else{
                showErrorToast("Please fill correct email");
              }
            });
          }
          
        },
        child: Text("Send",
            textAlign: TextAlign.center,
            style: normalStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final backButon = Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff28a745),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Return to Sign in",
            textAlign: TextAlign.center,
            style: normalStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      // appBar: AppBar(title: const Text("Login Page"),),
      
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child:Container(
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
                    SizedBox(
                      child:Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Enter your email address and we will send you a link to reset your password.", style: normalStyle.copyWith(fontSize: 18.0),),
                      )
                      

                    ),
                    emailField,
                    SizedBox(height: 25.0),
                    sendButon,
                    SizedBox(
                      height: 12.0,
                    ),
                    backButon
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

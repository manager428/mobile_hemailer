import 'package:flutter/material.dart';
import 'package:hemailer/screens/login_screen.dart';

final routes = {
  '/login' : (BuildContext context) => new LoginScreen(title: "Login Page",),
  '/' : (BuildContext context) => new LoginScreen(),
};
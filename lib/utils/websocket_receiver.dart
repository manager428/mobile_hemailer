import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:websocket_manager/websocket_manager.dart';

class OnlineChatSocket extends ChangeNotifier{
  WebsocketManager socket;
  dynamic recentMsg;
  OnlineChatSocket(UserModel userInfo){
    socket = WebsocketManager(onlineSocketURI);
    
    var messageJSON = {
      "msg_type": "chat-agent-logined",
      "sender_id": userInfo.id,
      "parentID": userInfo.id,
    };
    // send agent logined status
    socket.connect().then((val){
      Timer(Duration(seconds: 3), () {
        socket.send(jsonEncode(messageJSON));  
      });
    });
    
    socket.onMessage((dynamic message) {
      recentMsg = json.decode(message);
      notifyListeners();
    }); 
  }
  
  void sendMsg(dynamic msg){
    socket.send(jsonEncode(msg));
  }
}
class ChatSocket extends ChangeNotifier{
  WebsocketManager socket;
  dynamic recentMsg;
  ChatSocket(UserModel userInfo){
    socket = WebsocketManager(chatSocketURI);
    
    var messageJSON = {
      "msg_type": "chat-logined",
      "sender_id": userInfo.id,
      "parentID": userInfo.parentID,
    };
    // send agent logined status
    socket.connect().then((val){
      Timer(Duration(seconds: 3), () {
        socket.send(jsonEncode(messageJSON));  
      });
    });
    
    socket.onMessage((dynamic message) {
      recentMsg = json.decode(message);
      notifyListeners();
    }); 
  }
  
  void sendMsg(dynamic msg){
    socket.send(jsonEncode(msg));
  }
}
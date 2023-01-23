import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/payment/add_payment_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PaymentScreen extends StatefulWidget {
  final UserModel userInfo;
  final dynamic contactInfo;
  PaymentScreen({Key key, @required this.userInfo, this.contactInfo})
      : super(key: key);
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> allPayment;
  double totalPrice;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshPayments();
  }

  void refreshPayments() {
    final body = {
      "email_id": widget.contactInfo["id"],
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getPayments(body).then((response) {
      setState(() {
        _progressBarActive = false;
        allPayment = response["data"];
        totalPrice = double.parse(
            response["sum_price"] != null ? response["sum_price"] : "0");
      });
    });
  }

  void addPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentAddScreen(
          paymentInfo: null,
          contactInfo: widget.contactInfo,
          totalPrice: totalPrice,
          userInfo: widget.userInfo,
        ),
      ),
    ).then((val) {
      refreshPayments();
    });
  }

  void editPayment(dynamic expense, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentAddScreen(
          paymentInfo: expense,
          contactInfo: widget.contactInfo,
          totalPrice: totalPrice,
          userInfo: widget.userInfo,
        ),
      ),
    ).then((val) {
      refreshPayments();
    });
  }

  Future<void> deletePayment(dynamic expense, BuildContext context) async {
    String title = 'Delete this record?';
    String content = 'This will delete this record.';
    final ConfirmAction action = await confirmDialog(context, title, content);

    if (action == ConfirmAction.YES) {
      final body = {
        "expense_id": expense["id"],
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.deletePayment(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null && response["status"]) {
          setState(() {
            allPayment.remove(expense);
            totalPrice -= double.parse(expense["price"]) -
                double.parse(expense["shipping"]) -
                double.parse(expense["refund"]);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rowProfit = Card(
      margin: EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              "Total",
              style: normalStyle.copyWith(
                  color: Color(0xff00c851), fontSize: 30.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
                totalPrice != null ? totalPrice.toString() + ("\$") : "",
                style: normalStyle.copyWith(fontSize: 30.0)),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addPayment(context);
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
              rowProfit,
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      // itemExtent: 70.0,
                      itemCount: allPayment != null ? allPayment.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          //                           <-- Card widget
                          child: ListTile(
                            title: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text("Paid "),
                                    Text(
                                      allPayment[index]["price"] + "\$",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Text(" on " + allPayment[index]["paid_at"]),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      allPayment[index]["shipping"] != "0"
                                          ? Text("Shipping ")
                                          : Text(" "),
                                      allPayment[index]["shipping"] != "0"
                                          ? Text(
                                              allPayment[index]["shipping"] +
                                                  "\$",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          : Text(" "),
                                      allPayment[index]["refund"] != "0"
                                          ? Text("Refund ")
                                          : Text(" "),
                                      allPayment[index]["refund"] != "0"
                                          ? Text(
                                              allPayment[index]["refund"] +
                                                  "\$",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          : Text(" "),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            subtitle: Text(allPayment[index]["notes"]),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    editPayment(allPayment[index], context);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                    size: 20.0,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deletePayment(allPayment[index], context);
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

import 'package:flutter/material.dart';

import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/screens/expense/add_expense_screen.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pie_chart/pie_chart.dart';

class ExpenseScreen extends StatefulWidget {
  final UserModel userInfo;
  ExpenseScreen({Key key, @required this.userInfo}) : super(key: key);
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> allExpenses;
  double totalExpense;
  double totalPrice;
  bool _progressBarActive = false;
  @override
  void initState() {
    super.initState();
    refreshExpenses();
  }

  void refreshExpenses() {
    final body = {
      "user_id": widget.userInfo.id,
    };
    setState(() {
      _progressBarActive = true;
    });
    ApiService.getExpenses(body).then((response) {
      setState(() {
        _progressBarActive = false;
        allExpenses = response["data"];
        totalExpense = double.parse(response["payment"]["sum_expense"]);
        totalPrice = double.parse(response["payment"]["sum_price"]);
      });
    });
  }

  void addExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseAddScreen(
          expenseInfo: null,
          userInfo: widget.userInfo,
          totalExpense: totalExpense,
        ),
      ),
    ).then((val) {
      refreshExpenses();
    });
  }

  void editExpense(dynamic expense, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseAddScreen(
          expenseInfo: expense,
          userInfo: widget.userInfo,
          totalExpense: totalExpense,
        ),
      ),
    ).then((val) {
      refreshExpenses();
    });
  }

  Future<void> deleteExpense(dynamic expense, BuildContext context) async {
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
      ApiService.deleteExpense(body).then((response) {
        if (response != null && response["status"]) {
          setState(() {
            _progressBarActive = false;
            allExpenses.remove(expense);
            totalExpense -= double.parse(expense["price"]);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colorPriceList = [
      Colors.blue,
      Colors.red,
    ];
    Map<String, double> dataPriceMap = new Map();
    dataPriceMap.putIfAbsent(
        "Total: " + (totalPrice != null ? totalPrice.toString() : "") + "\$",
        () => totalPrice != null ? totalPrice : 0);
    dataPriceMap.putIfAbsent(
        "Expense: " +
            (totalExpense != null ? totalExpense.toString() : "0") +
            "\$",
        () => totalExpense != null ? totalExpense : 0);

    final priceChart = PieChart(
      dataMap: dataPriceMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 36.0,
      chartRadius: MediaQuery.of(context).size.width / 4.0,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      colorList: colorPriceList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 10,
    );
    final rowProfit = Card(
      margin: EdgeInsets.all(6.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Text(
                  "PROFIT",
                  style: cardHeaderStyle.copyWith(color: Color(0xff00c851)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Text(
                    totalPrice != null
                        ? (totalPrice - totalExpense).toString() + ("\$")
                        : "",
                    style: normalStyle),
              ),
            ],
          ),
          priceChart
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addExpense(context);
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
                      itemCount: allExpenses != null ? allExpenses.length : 0,
                      itemBuilder: (context, index) {
                        return Card(
                          //                           <-- Card widget
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Text("Expense "),
                                Text(
                                  allExpenses[index]["price"] + "\$",
                                  style: TextStyle(color: Colors.red),
                                ),
                                Text(" on " + allExpenses[index]["paid_at"]),
                              ],
                            ),
                            subtitle: Text(allExpenses[index]["notes"]),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    editExpense(allExpenses[index], context);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                    size: 20.0,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deleteExpense(allExpenses[index], context);
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

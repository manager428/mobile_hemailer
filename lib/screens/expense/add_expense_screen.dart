import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ExpenseAddScreen extends StatefulWidget {
  final dynamic expenseInfo;
  final double totalExpense;
  final UserModel userInfo;
  ExpenseAddScreen({Key key, @required this.expenseInfo, this.userInfo, this.totalExpense}) : super(key: key);
  @override
  _ExpenseAddScreenState createState() => _ExpenseAddScreenState();
  
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen>{
  TextEditingController _txtPrice = new TextEditingController();
  TextEditingController _txtTotal = new TextEditingController();
  TextEditingController _txtNotes = new TextEditingController();
  TextEditingController _txtPaidAt = new TextEditingController();
  bool _progressBarActive = false;
  double totalPrice;
  var format = new DateFormat("yyyy-MM-dd");
  var now = new DateTime.now();
  @override
  void initState(){
    super.initState();
    setState(() {
      totalPrice = widget.totalExpense;
    });
     _txtTotal.text = totalPrice.toString();
    // edit page
    if(widget.expenseInfo != null){
      initExpense();
    }else{
      _txtPaidAt.text = format.format(now);
    }
  }
  void initExpense(){
    _txtPrice.text = widget.expenseInfo["price"];
    _txtNotes.text = widget.expenseInfo["notes"];
    _txtPaidAt.text = widget.expenseInfo["paid_at"];
    
  }
  void calculateTotal(){
    double expensePrice = widget.expenseInfo !=null ? double.parse(widget.expenseInfo["price"]) : 0.0;
    _txtTotal.text = (totalPrice + double.parse(_txtPrice.text == "" ? "0" : _txtPrice.text) - expensePrice).toString();
  }
  void saveExpense(BuildContext context){
    if(_txtPrice.text==""){
      showErrorToast("Please fill price");
    }else if(_txtPaidAt.text==""){
      showErrorToast("Please select paid at");
    }else{
      var expenseID = widget.expenseInfo == null ? "-1": widget.expenseInfo["id"];
      final body = {
        "expense_id": expenseID,
        "user_id": widget.userInfo.id,
        "price": _txtPrice.text.trim(),
        "notes": _txtNotes.text.trim(),
        "paid_at": _txtPaidAt.text.trim(),
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.saveExpense(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null && response["status"]) {
          showSuccessToast("Saved expense");
          if(widget.expenseInfo == null){
            totalPrice += double.parse(_txtPrice.text.trim());
            cancelExpense();
          }else{
            Navigator.of(context).pop();
          }
        }else{
          showErrorToast("Something error");
        }
      });
    }
  }
  void cancelExpense(){
    _txtPrice.text = "";
    _txtTotal.text = totalPrice.toString();
    _txtNotes.text = "";
    _txtPaidAt.text = format.format(now);
  }
  @override
  Widget build(BuildContext context) {
    
    final priceRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: new InputDecoration(labelText: 'Price',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtPrice,
        onChanged: (value){
          calculateTotal();
        },
      ),
    );
    
    final totalRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        enabled: false,
        style: normalStyle,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: new InputDecoration(labelText: 'Total',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtTotal,
      ),
    );
    final notesRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        maxLines: 4,
        style: normalStyle,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(labelText: 'Notes',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtNotes,
      ),
    );
    final paidAtRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: DateTimeField(
        format: format,
        controller: _txtPaidAt,
        decoration: InputDecoration(labelText: 'Paid at',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        },
      ),
    );
    
    final btnRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              splashColor: Colors.blueAccent,
              onPressed: () {
                saveExpense(context);
              },
              child: Text(
                "Save",
                style: normalStyle,
              ),
            ),
          )
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              splashColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: normalStyle,
              ),
            ),
          )
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: widget.expenseInfo != null? const Text("Edit Expense"): const Text("Add Expense"),),
      body: ModalProgressHUD(
        inAsyncCall: _progressBarActive,
        child:Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 80.0,),
                Center(
                  child: Column(
                    children: <Widget>[
                      priceRow,
                      paidAtRow,
                      totalRow,
                      notesRow,
                      btnRow                    
                    ],
                  )
                ),
                
              ]
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hemailer/data/user_model.dart';
import 'package:hemailer/utils/rest_api.dart';
import 'package:hemailer/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PaymentAddScreen extends StatefulWidget {
  final dynamic paymentInfo;
  final double totalPrice;
  final dynamic contactInfo;
  final UserModel userInfo;
  PaymentAddScreen({Key key, @required this.paymentInfo, this.contactInfo, this.totalPrice, this.userInfo}) : super(key: key);
  @override
  _PaymentAddScreenState createState() => _PaymentAddScreenState();
  
}

class _PaymentAddScreenState extends State<PaymentAddScreen>{
  TextEditingController _txtPrice = new TextEditingController();
  TextEditingController _txtShipping = new TextEditingController();
  TextEditingController _txtRefund = new TextEditingController();
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
      totalPrice = widget.totalPrice;
    });
     _txtTotal.text = totalPrice.toString();
    // edit page
    if(widget.paymentInfo != null){
      initExpense();
    }else{
      _txtPaidAt.text = format.format(now);
    }
  }
  void initExpense(){
    _txtPrice.text = widget.paymentInfo["price"];
    _txtNotes.text = widget.paymentInfo["notes"];
    _txtPaidAt.text = widget.paymentInfo["paid_at"];
    _txtShipping.text = widget.paymentInfo["shipping"];
    _txtRefund.text = widget.paymentInfo["refund"];
  }
  void calculateTotal(){
    double orgPrice = widget.paymentInfo !=null ? double.parse(widget.paymentInfo["price"]) : 0.0;
    double dPrice = double.parse(_txtPrice.text == "" ? "0": _txtPrice.text);
    double dShipping = double.parse(_txtShipping.text == "" ? "0": _txtShipping.text);
    double dRefund = double.parse(_txtRefund.text == "" ? "0": _txtRefund.text);
    _txtTotal.text = (totalPrice + dPrice - dShipping - dRefund - orgPrice).toString();
  }
  void savePayment(BuildContext context){
    if(_txtPrice.text.trim() == "" && _txtShipping.text.trim() == "" && _txtRefund.text.trim() == ""){
      showErrorToast("Please fill price");
    }else if(_txtPaidAt.text==""){
      showErrorToast("Please select paid at");
    }else{
      var expenseID = widget.paymentInfo == null ? "-1": widget.paymentInfo["id"];
      final body = {
        "expense_id": expenseID,
        "email_id": widget.contactInfo["id"],
        "user_id": widget.userInfo.id,
        "price": _txtPrice.text.trim(),
        "shipping": _txtShipping.text.trim(),
        "refund": _txtRefund.text.trim(),
        "notes": _txtNotes.text.trim(),
        "paid_at": _txtPaidAt.text.trim(),
      };
      setState(() {
        _progressBarActive = true;
      });
      ApiService.savePayment(body).then((response) {
        setState(() {
          _progressBarActive = false;
        });
        if (response != null && response["status"]) {
          showSuccessToast("Saved Payment");
          if(widget.paymentInfo == null){
            double dPrice = double.parse(_txtPrice.text == "" ? "0": _txtPrice.text);
            double dShipping = double.parse(_txtShipping.text == "" ? "0": _txtShipping.text);
            double dRefund = double.parse(_txtRefund.text == "" ? "0": _txtRefund.text);
    
            totalPrice += dPrice - dShipping - dRefund;
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
    _txtShipping.text = "";
    _txtRefund.text = "";
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
    final shippingRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: new InputDecoration(labelText: 'Shipping Cost',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtShipping,
        onChanged: (value){
          calculateTotal();
        },
      ),
    );
    final refundRow = Padding(
      padding: EdgeInsets.fromLTRB(30.0, 6.0, 30.0, 0.0),
      child: TextField(
        style: normalStyle,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: new InputDecoration(labelText: 'Refund',contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
        controller: _txtRefund,
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
                savePayment(context);
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
                if(widget.paymentInfo == null){
                  cancelExpense();
                }else{
                  Navigator.of(context).pop();
                }
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
      appBar: AppBar(title: widget.paymentInfo != null? const Text("Edit Payment"): const Text("Add Payment"),),
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
                      shippingRow,
                      refundRow,
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
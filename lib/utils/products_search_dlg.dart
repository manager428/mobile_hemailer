import 'package:flutter/material.dart';

class ProductSearchDlg extends StatefulWidget {
  
  final List<dynamic> products;
  final List<dynamic> selectedProducts;
  final ValueChanged<List<dynamic>> onSelectedProductsListChanged;
  ProductSearchDlg({Key key, @required this.products, this.selectedProducts, this.onSelectedProductsListChanged}) : super(key: key);

  @override
  _ProductSearchDlgState createState() => _ProductSearchDlgState();
}
class _ProductSearchDlgState extends State<ProductSearchDlg> {
  List<dynamic> _tempSelectedProducts = new List<dynamic>();
  List<dynamic> filteredProducts = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();

  void filterSearchResults(String query) {
    if(query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      widget.products.forEach((item) {
        if(item["name"].toString().toLowerCase().contains(query.toLowerCase()) || item["price"].toString().toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredProducts.clear();
        filteredProducts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredProducts.clear();
        filteredProducts.addAll(widget.products);
      });
    }
  }

  @override
  void initState() {
    _tempSelectedProducts = widget.selectedProducts;
    filteredProducts.addAll(widget.products);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Select Products',
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.blueAccent,
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
            child: TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),),
              controller: txtSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (BuildContext context, int index) {
                final product = filteredProducts[index];
                return Container(
                  child: Card(child:  CheckboxListTile(
                      title: Text(product["name"]),
                      subtitle: Text(product["price"]),
                      value: _tempSelectedProducts.contains(product),
                      onChanged: (bool value) {
                        if (value) {
                          if (!_tempSelectedProducts.contains(product)) {
                            setState(() {
                              _tempSelectedProducts.add(product);
                            });
                          }
                        } else {
                          if (_tempSelectedProducts.contains(product)) {
                            setState(() {
                              _tempSelectedProducts.removeWhere(
                                  (dynamic city) => city == product);
                            });
                          }
                        }
                        widget
                            .onSelectedProductsListChanged(_tempSelectedProducts);
                      }
                    ),
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
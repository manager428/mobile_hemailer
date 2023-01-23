import 'package:flutter/material.dart';

class ContactSearchDlg extends StatefulWidget {
  final List<dynamic> contacts;
  final List<dynamic> selectedContacts;
  final ValueChanged<List<dynamic>> onSelectedContactsListChanged;
  ContactSearchDlg(
      {Key key,
      @required this.contacts,
      this.selectedContacts,
      this.onSelectedContactsListChanged})
      : super(key: key);

  @override
  _ContactSearchDlgState createState() => _ContactSearchDlgState();
}

class _ContactSearchDlgState extends State<ContactSearchDlg> {
  List<dynamic> _tempSelectedContacts = new List<dynamic>();
  List<dynamic> filteredContacts = new List<dynamic>();
  TextEditingController txtSearch = TextEditingController();

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      widget.contacts.forEach((item) {
        if (item["name"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["email"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["phone"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["address"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item["notes"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredContacts.clear();
        filteredContacts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredContacts.clear();
        filteredContacts.addAll(widget.contacts);
      });
    }
  }

  @override
  void initState() {
    _tempSelectedContacts = widget.selectedContacts;
    filteredContacts.addAll(widget.contacts);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Select Contacts',
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
              decoration: new InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
              ),
              controller: txtSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  final contact = filteredContacts[index];
                  return Container(
                      child: Card(
                    child: CheckboxListTile(
                        title: Text(contact["name"]),
                        subtitle: Text(contact["email"]),
                        value: _tempSelectedContacts.contains(contact),
                        onChanged: (bool value) {
                          if (value) {
                            if (!_tempSelectedContacts.contains(contact)) {
                              setState(() {
                                _tempSelectedContacts.add(contact);
                              });
                            }
                          } else {
                            if (_tempSelectedContacts.contains(contact)) {
                              setState(() {
                                _tempSelectedContacts.removeWhere(
                                    (dynamic city) => city == contact);
                              });
                            }
                          }
                          widget.onSelectedContactsListChanged(
                              _tempSelectedContacts);
                        }),
                  ));
                }),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'eve_system.dart';
import 'system_search.dart';

class SelectedSystems {
  final EveSystem from;
  final EveSystem to;

  SelectedSystems(this.from, this.to);
}

class SelectSystemsDialog extends StatelessWidget {
  final SystemSearch _systemSearch;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<SystemSelectionFieldState> _fromFieldKey =
      GlobalKey<SystemSelectionFieldState>();
  final GlobalKey<SystemSelectionFieldState> _toFieldKey =
      GlobalKey<SystemSelectionFieldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey;

  SelectSystemsDialog(
      {Key key,
      SystemSearch systemSearch,
      GlobalKey<ScaffoldState> scaffoldKey})
      : assert(systemSearch != null),
        assert(scaffoldKey != null),
        _systemSearch = systemSearch,
        _scaffoldKey = scaffoldKey,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select systems"),
      content: Form(
          key: _formKey,
          child: ConstrainedBox(
            child: Column(
              children: [
                SystemSelectionField(
                  key: _fromFieldKey,
                  hint: "From system",
                  systemSearch: _systemSearch,
                ),
                SystemSelectionField(
                  key: _toFieldKey,
                  hint: "To system",
                  systemSearch: _systemSearch,
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            constraints: BoxConstraints(minHeight: 160),
          )),
      actions: [
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              final snackBar = SnackBar(
                content: Text(
                    "Trade route from ${_fromFieldKey.currentState.selected} to ${_toFieldKey.currentState.selected}"),
                duration: Duration(milliseconds: 2000),
              );
              _scaffoldKey.currentState.showSnackBar(snackBar);

              Navigator.of(context).pop(SelectedSystems(
                  _systemSearch.system(_fromFieldKey.currentState.selected),
                  _systemSearch.system(_toFieldKey.currentState.selected)));
            }
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class SystemSelectionField extends StatefulWidget {
  final String hint;
  final SystemSearch _systemSearch;

  SystemSelectionField({Key key, this.hint, SystemSearch systemSearch})
      : assert(systemSearch != null),
        _systemSearch = systemSearch,
        super(key: key);

  @override
  SystemSelectionFieldState createState() => SystemSelectionFieldState();
}

class SystemSelectionFieldState extends State<SystemSelectionField> {
  final TextEditingController _typeAheadController = TextEditingController();

  String selected;

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<EveSystem>(
      textFieldConfiguration: TextFieldConfiguration(
        decoration:
            InputDecoration(hintText: widget.hint, labelText: widget.hint),
        controller: _typeAheadController,
      ),
      validator: (value) {
        if (value != "") {
          return (widget._systemSearch.system(value) != null
              ? null
              : "System doesn't exist");
        } else {
          return "Please enter a system name";
        }
      },
      onSaved: (newValue) {
        setState(() {
          selected = newValue;
        });
      },
      onSuggestionSelected: (suggestion) {
        _typeAheadController.text = suggestion.name;
      },
      itemBuilder: (context, itemData) {
        return ListTile(
          title: Row(
            children: [
              Text(
                ((itemData.secStatus * 10.0).roundToDouble() / 10.0).toString(),
                style: TextStyle(color: itemData.secColor),
              ),
              SizedBox(
                width: 20,
              ),
              Text(itemData.name)
            ],
          ),
        );
      },
      autoFlipDirection: true,
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) {
          return null;
        }
        return await widget._systemSearch.searchSystems(pattern, 10);
      },
      hideOnLoading: true,
    );
  }
}

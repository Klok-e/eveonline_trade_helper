import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/eve_system.dart';
import '../logic/services/system_search.dart';

class SelectedSystems {
  final EveSystem from;
  final EveSystem to;

  SelectedSystems(this.from, this.to);
}

class SelectSystemsDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<SystemSelectionFieldState> _fromFieldKey =
      GlobalKey<SystemSelectionFieldState>();
  final GlobalKey<SystemSelectionFieldState> _toFieldKey =
      GlobalKey<SystemSelectionFieldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey;

  SelectSystemsDialog({
    Key key,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  })  : _scaffoldKey = scaffoldKey,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SystemSearchService>();

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
                  systemSearch: search,
                ),
                SystemSelectionField(
                  key: _toFieldKey,
                  hint: "To system",
                  systemSearch: search,
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

              final fromStr = _fromFieldKey.currentState.selected;
              final toStr = _toFieldKey.currentState.selected;
              final snackBar = SnackBar(
                content: Text("Trade route from ${fromStr} to ${toStr}"),
                duration: Duration(milliseconds: 2000),
              );
              _scaffoldKey.currentState.showSnackBar(snackBar);

              final fromSys = search.system(fromStr);
              final toSys = search.system(toStr);
              assert(fromSys != null);
              assert(toSys != null);
              Navigator.of(context).pop(SelectedSystems(fromSys, toSys));
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
  final SystemSearchService _systemSearch;

  SystemSelectionField(
      {Key key,
      @required this.hint,
      @required SystemSearchService systemSearch})
      : _systemSearch = systemSearch,
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
      textFieldConfiguration: TextFieldConfiguration<String>(
        decoration:
            InputDecoration(hintText: widget.hint, labelText: widget.hint),
        controller: _typeAheadController,
      ),
      validator: (value) {
        assert(value != null);
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/eve_system.dart';
import '../services/system_search.dart';

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

  SelectSystemsDialog({Key key}) : super(key: key);

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
                ),
                SystemSelectionField(
                  key: _toFieldKey,
                  hint: "To system",
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

              final search = context.read<SystemSearchService>();
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

  SystemSelectionField({
    Key key,
    @required this.hint,
  }) : super(key: key);

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
          final search = context.read<SystemSearchService>();
          return (search.system(value) != null ? null : "System doesn't exist");
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
        final search = context.read<SystemSearchService>();
        return await search.searchSystems(pattern, 10);
      },
      hideOnLoading: true,
    );
  }
}

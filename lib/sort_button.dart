import 'package:flutter/material.dart';

import 'sort_type.dart';

class SortButton extends StatefulWidget {
  final sortButtonCallback callback;

  const SortButton({Key key, this.callback}) : super(key: key);

  @override
  SortButtonState createState() => SortButtonState();
}

typedef sortButtonCallback = void Function(SortType sortType);

class SortButtonState extends State<SortButton> {
  SortType _sortType;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortType>(
      onSelected: (value) {
        final snackBar = SnackBar(
          content: Text("Sorting by ${value.name}"),
          duration: Duration(milliseconds: 2000),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          _sortType = value;
        });
        widget.callback(_sortType);
      },
      icon: Icon(Icons.sort),
      itemBuilder: (BuildContext context) {
        return SortType.values
            .map((sort) => PopupMenuItem<SortType>(
                  value: sort,
                  child: Text(sort.name),
                ))
            .toList();
      },
    );
  }
}

import 'package:eveonline_trade_helper/logic/sort_way.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sort_type.dart';

class SortButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SortWayBloc sort = context.read<SortWayBloc>();

    return PopupMenuButton<SortType>(
      onSelected: (value) {
        // final snackBar = SnackBar(
        //   content: Text("Sorting by ${value.name}"),
        //   duration: Duration(milliseconds: 2000),
        // );
        // Scaffold.of(context).showSnackBar(snackBar);

        sort.add(value);
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

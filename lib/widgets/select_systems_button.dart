import 'package:eveonline_trade_helper/logic/compare_systems_bloc.dart';
import 'package:eveonline_trade_helper/logic/services/system_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'select_systems_dialog.dart';

class SelectSystemsButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SelectSystemsButton({Key key, @required this.scaffoldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchService = context.watch<SystemSearchService>();
    return IconButton(
      icon: Icon(Icons.map),
      onPressed: () async {
        final sys = await showDialog<SelectedSystems>(
          context: context,
          builder: (context) {
            final dialog = SelectSystemsDialog(
              scaffoldKey: scaffoldKey,
            );
            return RepositoryProvider.value(
              value: searchService,
              child: dialog,
            );
          },
          barrierDismissible: false,
        );
        final cmpBloc = context.read<CompareSystemsBloc>();
        cmpBloc.add(CmpSystems(sys.from, sys.to));
      },
    );
  }
}

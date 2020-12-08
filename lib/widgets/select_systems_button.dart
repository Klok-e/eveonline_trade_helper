import 'package:eveonline_trade_helper/blocs/compare_systems/compare_systems_bloc.dart';
import 'package:eveonline_trade_helper/services/system_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'select_systems_dialog.dart';

class SelectSystemsButton extends StatelessWidget {
  const SelectSystemsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchService = context.watch<SystemSearchService>();
    return IconButton(
      icon: Icon(Icons.map),
      onPressed: () async {
        final log = context.read<Logger>();
        final sys = await showDialog<SelectedSystems>(
          context: context,
          builder: (context) {
            final dialog = SelectSystemsDialog();
            return RepositoryProvider.value(
              value: searchService,
              child: dialog,
            );
          },
          barrierDismissible: false,
        );
        if (sys == null) {
          log.v("select system dialog dismissed");
          return;
        }
        final snackBar = SnackBar(
          content: Text("Trade route from ${sys.from.name} to ${sys.to.name}"),
          duration: Duration(milliseconds: 2000),
        );
        Scaffold.of(context).showSnackBar(snackBar);

        final cmpBloc = context.read<CompareSystemsBloc>();
        cmpBloc.add(CmpSystems(sys.from, sys.to));
      },
    );
  }
}

import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dart_eveonline_esi/api.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'eve_system.dart';
import 'goods_list.dart';
import 'select_systems_dialog.dart';
import 'system_search.dart';

void main() {
  runApp(TradeApp(
    systemSearch: SystemSearch(UniverseApi(), SearchApi()),
  ));
}

class TradeApp extends StatelessWidget {
  final SystemSearch _systemSearch;

  const TradeApp({Key key, SystemSearch systemSearch})
      : assert(systemSearch != null),
        _systemSearch = systemSearch,
        super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
        title: 'EVE Trade Helper',
        systemSearch: _systemSearch,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final SystemSearch systemSearch;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({Key key, this.title, this.systemSearch})
      : assert(systemSearch != null),
        super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SortType _sortType;

  int _fromSystem;
  int _toSystem;

  SortButton _sortButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _sortButton = SortButton(),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context1) {
                  return SelectSystemsDialog(
                    systemSearch: widget.systemSearch,
                    scaffoldKey: widget.scaffoldKey,
                  );
                },
                barrierDismissible: false,
                useRootNavigator: true,
              );
            },
          )
        ],
      ),
      body: GoodsList(),
    );
  }
}

class SortButton extends StatefulWidget {
  @override
  SortButtonState createState() => SortButtonState();
}

class SortButtonState extends State<SortButton> {
  SortType sortType;

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
          sortType = value;
        });
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

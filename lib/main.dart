import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dart_eveonline_esi/api.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'eve_system.dart';
import 'goods_list.dart';

void main() {
  runApp(TradeApp());
}

class TradeApp extends StatelessWidget {
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
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

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
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _sortButton = SortButton(),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Select systems"),
                    content: Form(
                      child: Column(
                        children: [
                          SystemSelectionField(
                            hint: "From system",
                          ),
                          SystemSelectionField(
                            hint: "To system",
                          ),
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ),
                      autovalidate: true,
                    ),
                    actions: [
                      FlatButton(
                        child: Text("Ok"),
                        onPressed: () {
                          Navigator.of(context).pop();
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
                },
              );
            },
          )
        ],
      ),
      body: GoodsList(),
    );
  }
}

class SystemSelectionField extends StatelessWidget {
  final String hint;
  final SearchApi _searchApi = SearchApi();
  final UniverseApi _universeApi = UniverseApi();

  SystemSelectionField({Key key, this.hint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<EveSystem>(
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(hintText: hint),
      ),
      validator: (value) {
        return null;
      },
      onSuggestionSelected: (suggestion) {},
      itemBuilder: (context, itemData) {
        return ListTile(
          title: SizedBox(
            child: Row(
              children: [
                Text(
                  ((itemData.secStatus * 10.0).roundToDouble() / 10.0)
                      .toString(),
                  style: TextStyle(color: itemData.secColor),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(itemData.name)
              ],
            ),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) {
          return <EveSystem>[];
        }
        var systems =
            await _searchApi.getSearch(<String>["solar_system"], pattern);
        if (systems.solarSystem == null) {
          return <EveSystem>[];
        }

        return await Future.wait(systems.solarSystem.take(5).map((sysid) async {
          var sysinfo = await _universeApi.getUniverseSystemsSystemId(sysid);
          return EveSystem(
              id: sysid, name: sysinfo.name, secStatus: sysinfo.securityStatus);
        }));
      },
      hideOnEmpty: true,
      hideOnLoading: true,
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

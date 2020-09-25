import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dart_eveonline_esi/api.dart';

import 'goods_list.dart';
import 'market_data.dart';
import 'select_systems_dialog.dart';
import 'sort_button.dart';
import 'system_search.dart';

void main() {
  final uni = UniverseApi();
  runApp(TradeApp(
    systemSearch: SystemSearch(uni, SearchApi()),
    marketData: MarketData(MarketApi(), uni),
  ));
}

class TradeApp extends StatelessWidget {
  final SystemSearch systemSearch;
  final MarketData marketData;

  const TradeApp({Key key, this.systemSearch, this.marketData})
      : assert(systemSearch != null),
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
        systemSearch: systemSearch,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final SystemSearch systemSearch;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final MarketData marketData;
  final String title;

  HomePage({Key key, this.title, this.systemSearch, this.marketData})
      : assert(systemSearch != null),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SortType _sortType = SortType.profit_desc;

  SystemMarketData _systemFrom;
  SystemMarketData _systemTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          SortButton(
            callback: (sortType) {
              setState(() {
                _sortType = sortType;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () async {
              final sys = await showDialog<SelectedSystems>(
                context: context,
                builder: (context1) {
                  return SelectSystemsDialog(
                    systemSearch: widget.systemSearch,
                    scaffoldKey: widget.scaffoldKey,
                  );
                },
                barrierDismissible: false,
              );

              final from = await widget.marketData.systemData(sys.from);
              final to = await widget.marketData.systemData(sys.to);
              setState(() {
                _systemFrom = from;
                _systemTo = to;
              });
            },
          )
        ],
      ),
      body: TradesList(
        sortType: _sortType,
        sysFrom: _systemFrom,
        sysTo: _systemTo,
      ),
    );
  }
}

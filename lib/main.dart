import 'package:eveonline_trade_helper/logic/compare_systems_bloc.dart';
import 'package:eveonline_trade_helper/logic/sort_way.dart';
import 'package:eveonline_trade_helper/widgets/select_systems_button.dart';
import 'package:flutter/material.dart';
import 'package:dart_eveonline_esi/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/sort_type.dart';
import 'widgets/goods_list.dart';
import 'logic/services/market_data.dart';
import 'widgets/select_systems_dialog.dart';
import 'widgets/sort_button.dart';
import 'logic/services/system_search.dart';

void main() {
  runApp(const TradeApp());
}

class TradeApp extends StatelessWidget {
  const TradeApp({Key key}) : super(key: key);

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
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<UniverseApi>(
              create: (context) => UniverseApi(),
            ),
            RepositoryProvider<SearchApi>(
              create: (context) => SearchApi(),
            ),
            RepositoryProvider<MarketApi>(
              create: (context) => MarketApi(),
            ),
            RepositoryProvider<SystemSearchService>(
              create: (context) => SystemSearchService(
                  context.read<UniverseApi>(), context.read<SearchApi>()),
            ),
            RepositoryProvider<MarketDataService>(
              create: (context) => MarketDataService(
                  context.read<MarketApi>(), context.read<UniverseApi>()),
            )
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SortWayBloc>(
                create: (context) => SortWayBloc(SortType.margin_desc),
              ),
              BlocProvider<CompareSystemsBloc>(
                create: (context) =>
                    CompareSystemsBloc(context.read<MarketDataService>()),
              )
            ],
            child: HomePage(
              'EVE Trade Helper',
            ),
          ),
        ));
  }
}

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final String title;

  HomePage(
    this.title, {
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            SortButton(),
            SelectSystemsButton(
              scaffoldKey: widget.scaffoldKey,
            )
          ],
        ),
        body: BlocListener<SortWayBloc, SortType>(listener: (context, state) {
          final snackBar = SnackBar(
            content: Text("Sorting by ${state.name}"),
            duration: Duration(milliseconds: 2000),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }, child: BlocBuilder<CompareSystemsBloc, CompareSystemsState>(
          builder: (context, state) {
            Widget child = state.when(() {
              return Text("Nothing here yet");
            }, error: (msg) {
              return Text("An error happened: ${msg}");
            }, loading: () {
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
            }, comparison: (cmps) {
              return TradesList(comparisons: cmps);
            });
            return Center(child: child);
          },
        )));
  }
}

class EmptyTradeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Select systems to see items here"));
  }
}

import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/blocs/compare_systems_bloc.dart';
import 'package:eveonline_trade_helper/blocs/sort_way.dart';
import 'package:eveonline_trade_helper/widgets/select_systems_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'services/market_data.dart';
import 'services/system_search.dart';
import 'models/sort_type.dart';
import 'widgets/goods_list.dart';
import 'widgets/sort_button.dart';

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
            RepositoryProvider<Logger>(
              create: (context) => Logger(level: Level.verbose),
            ),
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
              create: (context) => MarketDataService(context.read<MarketApi>(),
                  context.read<UniverseApi>(), context.read<Logger>()),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SortWayBloc>(
                create: (context) => SortWayBloc(SortType.margin_desc),
              ),
              BlocProvider<CompareSystemsBloc>(
                create: (context) => CompareSystemsBloc(
                    context.read<MarketDataService>(), context.read<Logger>()),
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
        appBar: AppBar(
          title: Text(widget.title),
          actions: [SortButton(), SelectSystemsButton()],
        ),
        body: BlocListener<SortWayBloc, SortType>(listener: (context, state) {
          final snackBar = SnackBar(
            content: Text("Sorting by ${state.name}"),
            duration: Duration(milliseconds: 2000),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }, child: BlocBuilder<CompareSystemsBloc, CompareSystemsState>(
          builder: (context, state) {
            Widget child = state.when(empty: () {
              return Center(child: Text("Nothing here yet"));
            }, error: (msg) {
              return Center(child: Text("An error happened: ${msg}"));
            }, loading: () {
              return Center(
                  child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ));
            }, comparison: (cmps) {
              // return TradesList(comparisons: cmps);
              return BlocBuilder<SortWayBloc, SortType>(
                  builder: (context, state) {
                return TradesList(comparisons: state.sort(cmps));
              });
            });
            return child;
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

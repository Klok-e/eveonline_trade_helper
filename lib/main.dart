import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/blocs/compare_systems/compare_systems_bloc.dart';
import 'package:eveonline_trade_helper/blocs/sort_way.dart';
import 'package:eveonline_trade_helper/services/eve_icon_service.dart';
import 'package:eveonline_trade_helper/services/item_data_service.dart';
import 'package:eveonline_trade_helper/widgets/select_systems_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';

import 'blocs/compare_systems/compare_systems_state.dart';
import 'models/sort_type.dart';
import 'services/market_data.dart';
import 'services/system_search.dart';
import 'widgets/goods_list.dart';
import 'widgets/sort_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(const TradeApp());
}

class TradeApp extends StatelessWidget {
  const TradeApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.from(
          colorScheme: ColorScheme(
            primary: Color(0xff262a2f),
            primaryVariant: Color(0xff202022),
            secondary: Color(0xff336eac),
            secondaryVariant: Color(0xff1d4062),
            error: Color(0xffe70e2e),
            background: Color(0xff2c2f31),
            surface: Color(0xff202022),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onError: Colors.white,
            onBackground: Colors.white,
            onSurface: Colors.white,
            brightness: Brightness.dark,
          ),
          textTheme: TextTheme(
              headline1: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              headline2: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              headline3: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              headline4: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              headline5: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              headline6: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              subtitle1: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              subtitle2: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              bodyText1: TextStyle(
                color: Color(0xffbdbdbd),
              ),
              bodyText2: TextStyle(
                color: Color(0xffbdbdbd),
              )),
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
            RepositoryProvider<EveIconService>(
              create: (context) => EveIconService("https://images.evetech.net"),
            ),
            RepositoryProvider<ItemDataService>(
              create: (context) => ItemDataService(
                  context.read<UniverseApi>(), context.read<EveIconService>()),
            )
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
              return BlocBuilder<SortWayBloc, SortType>(
                  builder: (context, state) {
                // TODO: move sort to a bloc or a service
                final itemData = context.watch<ItemDataService>();
                return TradesList(
                  comparisons: state.sort(cmps),
                  itemDataService: itemData,
                );
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

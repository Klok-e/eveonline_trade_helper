import 'package:eveonline_trade_helper/models/sort_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SortWayBloc extends Bloc<SortType, SortType> {
  SortWayBloc(SortType initialState) : super(initialState);

  @override
  Stream<SortType> mapEventToState(SortType event) async* {
    // because i don't know what events are
    yield event;
  }
}

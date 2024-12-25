import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc/bloc.dart';

class taskBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change.toString());
  }
}

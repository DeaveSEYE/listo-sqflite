import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/cubit/categorieCubit.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/features/login/ui/login.dart';
import 'package:listo/features/register/ui/register.dart';
import 'package:listo/partials/main_scaffold.dart';

class Routes {
  static const String startPage = '/start';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String homePage = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (_) => const Login());
      case registerPage:
        return MaterialPageRoute(builder: (_) => const Register());
      case homePage:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CategorieCubit()),
              BlocProvider(create: (_) => TaskCubit()),
            ],
            child: const MainScaffold(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CategorieCubit()),
              BlocProvider(create: (_) => TaskCubit()),
            ],
            child: const MainScaffold(),
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/blocs/search/search_bloc.dart';
import 'package:flutter_project/src/bus_map_screen.dart';
import 'package:flutter_project/src/core/service_locator.dart';

import 'package:flutter_project/src/views/test_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await setupServiceLocator();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CityBloc>(
          create: (context) => getIt<CityBloc>(), // LazySingleton 인스턴스 제공
        ),
        BlocProvider<SearchBloc>(
          create: (context) => getIt<SearchBloc>(), // Factory 인스턴스 제공
        ),
        BlocProvider<NearbyStopsMapBloc>(
          create: (context) => getIt<NearbyStopsMapBloc>(),
        ),
        BlocProvider<FavoriteBloc>(
          create: (context) => getIt<FavoriteBloc>(),
        )
      ],
      child: MaterialApp(
        title: 'Realtime Bus Location App',
        theme: ThemeData(primarySwatch: Colors.blue),
        // 앱의 초기 화면을 TestStf로 설정
        home: const TestStf(), // TestStf는 이제 CityBloc에 접근 가능
      ),
    );
  }
}

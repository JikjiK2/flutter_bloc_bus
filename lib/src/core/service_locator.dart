// import 'package:flutter_project/src/blocs/bus_location/bus_location_bloc.dart';
// import 'package:flutter_project/src/data/bus_repository.dart';
// import 'package:flutter_project/src/data/bus_sources.dart';
// import 'package:get_it/get_it.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 접근 위해 import
//
//
// final getIt = GetIt.instance;
//
// void setupServiceLocator() {
//   print("--- GetIt Setup Started ---");
//   // BusApiClient 등록
//   try{
//     getIt.registerLazySingleton<BusLocationApi>(
//           () => BusLocationApi(
//         // .env 파일에서 'BUS_API_SERVICE_KEY' 값을 가져와 전달합니다.
//         // 키가 없으면 오류가 발생하므로 !를 사용하거나 ?? 기본값 처리를 합니다.
//         busApiServiceKey: dotenv.env['BUS_API_SERVICE_KEY']!, // 예시: .env에 키가 있어야 함
//
//         // cityCode와 routeId도 .env에서 가져오거나 기본값을 설정할 수 있습니다.
//         cityCode: dotenv.env['DEFAULT_CITY_CODE'] ?? '25',
//         routeId: dotenv.env['DEFAULT_ROUTE_ID'] ?? 'DJB30300052',
//       ),
//     );
//     print("BusApiClient registered.");
//     if(!getIt.isRegistered<BusRepository>()){
//       getIt.registerLazySingleton<BusRepository>(
//             () => BusRepository(busApiClient: getIt()),
//       );
//       print("BusRepository registered.");
//     }
//
//     if(!getIt.isRegistered<BusLocationBloc>()) {
//       getIt.registerFactory<BusLocationBloc>(
//             () {
//               // 이 부분이 실행될 때 예외 발생
//               print("Attempting to get BusRepository for BusLocationBloc factory..."); // 로그 추가
//               // 명시적으로 <BusRepository> 타입을 지정합니다.
//               final repository = getIt<BusRepository>(); // <--- **여기를 수정합니다!**
//               print("Successfully got BusRepository."); // 로그 추가
//               return BusLocationBloc(busRepository: repository);
//             },
//
//       );
//       print("BusLocationBloc registered.");
//     }
//     print("--- GetIt Setup Finished Successfully ---"); // 성공 로그
//   } catch (e) {
//     print("!!!! Error registering GetIt: $e");
//   }
//
//
//
// }

import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_bloc.dart';
import 'package:flutter_project/src/blocs/search/search_bloc.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_bloc.dart';
import 'package:flutter_project/src/data/favorite_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_project/src/data/api_client.dart'; // ApiClient 인터페이스 import
import 'package:flutter_project/src/data/dio_api_client.dart'; // DioApiClient 구현체 import

import 'package:flutter_project/src/data/sources/bus_arrival_api.dart';
import 'package:flutter_project/src/data/sources/bus_stop_api.dart';
import 'package:flutter_project/src/data/sources/bus_route_api.dart';
import 'package:flutter_project/src/data/sources/bus_location_api.dart';

import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. ApiClient 등록 (DioApiClient 사용)
  getIt.registerLazySingleton<ApiClient>(
    () => DioApiClient(baseUrl: "apis.data.go.kr"),
  );

  // 2. API 클라이언트 등록 (각 API에 필요한 파라미터 주입)
  getIt.registerLazySingleton<BusArrivalApi>(
    () => BusArrivalApi(
      busApiServiceKey: dotenv.env['BUS_API_SERVICE_KEY']!,
      apiClient: getIt<ApiClient>(), // apiClient 주입
    ),
  );

  getIt.registerLazySingleton<BusStopApi>(
    () => BusStopApi(
      busApiServiceKey: dotenv.env['BUS_API_SERVICE_KEY']!,
      apiClient: getIt<ApiClient>(), // apiClient 주입
    ),
  );

  getIt.registerLazySingleton<BusRouteApi>(
    () => BusRouteApi(
      busApiServiceKey: dotenv.env['BUS_API_SERVICE_KEY']!,
      apiClient: getIt<ApiClient>(), // apiClient 주입
    ),
  );

  getIt.registerLazySingleton<BusLocationApi>(
    () => BusLocationApi(
      busApiServiceKey: dotenv.env['BUS_API_SERVICE_KEY']!,
      apiClient: getIt<ApiClient>(), // apiClient 주입
    ),
  );

  // 3. BusRepository 등록 (API 클라이언트 주입)
  getIt.registerLazySingleton<BusRepository>(
    () => BusRepository(
      busArrivalApi: getIt<BusArrivalApi>(),
      busStopApi: getIt<BusStopApi>(),
      busRouteApi: getIt<BusRouteApi>(),
      busLocationApi: getIt<BusLocationApi>(),
    ),
  );

  // 4. BusLocationBloc 등록 (BusRepository 주입)
  getIt.registerFactory<BusLocationBloc>(
    () => BusLocationBloc(busRepository: getIt()),
  );

  // RouteStopsBloc 등록 (BusRepository 주입)
  getIt.registerFactory<RouteStopsBloc>(
    // registerFactory 사용 (화면마다 새로 생성)
    () => RouteStopsBloc(busRepository: getIt()),
  );

  getIt.registerFactory<StationRoutesBloc>(
        () => StationRoutesBloc(
      busRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<CityBloc>(() => CityBloc());

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(busRepository: getIt(), cityBloc: getIt()),
  );

  getIt.registerFactory<NearbyStopsMapBloc>(
    () => NearbyStopsMapBloc(busRepository: getIt()),
  );

  getIt.registerFactory<BusRouteBloc>(
    () => BusRouteBloc(busRepository: getIt()),
  );

  getIt.registerSingletonAsync<SharedPreferences>(
        () => SharedPreferences.getInstance(),
  );
  getIt.registerSingletonAsync<FavoriteRepository>(
      () async =>  FavoriteRepository(prefs: await getIt.getAsync<SharedPreferences>()),
  dependsOn: [SharedPreferences], // SharedPreferences가 먼저 초기화되어야 함을 명시
  );
  getIt.registerSingletonAsync<FavoriteBloc>(
      () async {
        final repository = await getIt.getAsync<FavoriteRepository>(); // <-- Repository가 준비될 때까지 기다림
        final bloc = FavoriteBloc(repository: repository);
        bloc.add(LoadFavorites()); // BLoC 생성 즉시 즐겨찾기 로딩 이벤트 발생
        return bloc;
      },
      dependsOn: [FavoriteRepository],
  );

}

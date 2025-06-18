import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/data/sources/bus_arrival_api.dart';
import 'package:flutter_project/src/data/sources/bus_stop_api.dart';
import 'package:flutter_project/src/data/sources/bus_route_api.dart'; // BusRouteApi import
import 'package:flutter_project/src/data/sources/bus_location_api.dart'; // BusLocationApi import


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupServiceLocator();

  final busArrivalApi = getIt<BusArrivalApi>();
  final busStopApi = getIt<BusStopApi>(); // BusStopFindApi 인스턴스 가져오기
  final busRouteApi = getIt<BusRouteApi>(); // BusRouteApi 인스턴스 가져오기
  final busLocationApi = getIt<BusLocationApi>(); // BusLocationApi 인스턴스 가져오기

  // *** API 호출 테스트 ***

  // 1. 버스 정류소 정보 API 테스트
  try {
    final stations = await busStopApi.getStationsByLocation(gpsLati: "36.3504", gpsLong: "127.3845");
    print("버스 정류소 정보 API 성공 (좌표 기반): ${stations.length}개");
    stations.forEach((station) {
      print("  - ${station.nodenm}, ${station.nodeid}, Lat: ${station.latitude}, Lng: ${station.longitude}");
    });
  } catch (e) {
    print("버스 정류소 정보 API 실패 (좌표 기반): $e");
  }

  // 2. 버스 노선 정보 API 테스트
  try {
    final routes = await busRouteApi.getRouteList(cityCode: "25", routeNo: "5");
    print("버스 노선 정보 API 성공: ${routes.length}개");
    routes.forEach((route) {
      print("  - ${route.routeno}, ${route.routeid}, ${route.routetp}, ${route.startvehicletime} ${route.endvehicletime} ${route.startnodenm} ${route.endnodenm}" );
    });
  } catch (e) {
    print("버스 노선 정보 API 실패: $e");
  }

  // 3. 버스 위치 정보 API 테스트
  try {
    final locations = await busLocationApi.getBusLocationsByRoute(cityCode: "25", routeId: "DJB30300052");
    print("버스 위치 정보 API 성공: ${locations.length}개");
    locations.forEach((location) {
      print("  - ${location.vehicleno}, Lat: ${location.gpslati}, Lng: ${location.gpslong}");
    });
  } catch (e) {
    print("버스 위치 정보 API 실패: $e");
  }

  runApp(MyApp()); // 앱 실행 (UI 렌더링은 그대로 진행)
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Bus Location App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: Center(child: Text("API 테스트 완료. 콘솔 로그를 확인하세요."))),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_bloc.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_event.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_state.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRouteMapScreen extends StatefulWidget {
  final String cityCode;
  final String routeId;
  final String nodeNo;

  const BusRouteMapScreen({
    Key? key,
    required this.cityCode,
    required this.routeId,
    required this.nodeNo,
  }) : super(key: key);

  @override
  State<BusRouteMapScreen> createState() => _BusRouteMapScreenState();
}

class _BusRouteMapScreenState extends State<BusRouteMapScreen> {
  late final BusRouteBloc _busRouteMapBloc;
  late final BitmapDescriptor customIcon;


  @override
  void initState() {
    super.initState();
    BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)),
        'assets/images/bus_icon.png'
    ).then((icon) {
      setState(() {
        customIcon = icon;
      });
    });

    _busRouteMapBloc = getIt<BusRouteBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        print("BusRouteBloc instance obtained from GetIt.");
        // BLoC에 데이터 로드 이벤트 전달
        _busRouteMapBloc.add(
          LoadBusRoute(cityCode: widget.cityCode, routeId: widget.routeId),
        );
        print("BusRouteMap event dispatched.");
      } catch (e) {
        print("Error obtaining BusRouteBloc from GetIt: $e");
        // GetIt 설정 오류 시 사용자에게 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('앱 초기 설정 오류: 노선 경로 조회할 수 없습니다.')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _busRouteMapBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nodeNo} 버스'), // 노선 이름으로 제목 표시
      ),
      body: BlocBuilder<BusRouteBloc, BusRouteMapState>(
        bloc: _busRouteMapBloc,
        builder: (context, state) {
          if (state is BusRouteMapLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (state is BusRouteMapLoaded) {
            if (state.stops.isEmpty) {
              return const Center(child: Text('경유 정류소 정보가 없습니다.'));
            }
            if(state.stops.isNotEmpty) {
              final LatLng initialLocation = state.stops.first.toLatLng();

              final Set<Marker> markers = state.stops.map((stop) => Marker(
                markerId: MarkerId('stop_${stop.nodeid}'),
                position: stop.toLatLng(),
                infoWindow: InfoWindow(title: stop.nodenm),
                alpha: 0.1
              )).toSet();

              markers.addAll(state.locationInfoList.map((bus) {
                return Marker(
                  markerId: MarkerId('bus_${bus.vehicleno}'),
                  position: bus.toLatLng(),
                  infoWindow: InfoWindow(title: '버스 ${bus.vehicleno}'),
                  icon: customIcon
                );
              }
              // createBusStopMarkerWithLabel

              ).toSet());


              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  // 로드된 위치로 초기 카메라 설정
                  target: initialLocation,
                  zoom: 15.0, // 적절한 줌 레벨
                ),
                polylines: {state.routePolyline!},
                // BLoC 상태에서 가져온 Polyline 추가
                markers:markers,
                myLocationEnabled: true,
                // 현재 위치 파란색 점 표시 (권한 필요)
                myLocationButtonEnabled: false, // 기본 제공 현재 위치 버튼 비활성화
              );
            }
          } else if (state is BusRouteMapError) {
            return Center(child: Text('오류: ${state.message}'));
          }
          return const Center(child: Text('지도를 로딩하는 중...'));
        },
      ),
    );
  }




}

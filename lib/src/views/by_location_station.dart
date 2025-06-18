import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_event.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_state.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:flutter_project/src/data/sources/bus_stop_api.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// 페이지 진입 시 전달할 인자 타입을 정의 (위치 또는 정류소)
enum NearbyStopsMapSource { currentLocation, specificStop }

class NearbyStopsMapPageArguments {
  final NearbyStopsMapSource source;
  final double? latitude; // source가 currentLocation일 때 사용
  final double? longitude; // source가 currentLocation일 때 사용
  final String? cityCode; // source가 specificStop일 때 사용
  final String? nodeNo; // source가 specificStop일 때 사용
  final String? title; // AppBar 제목 등에 사용할 이름 (선택 사항)

  NearbyStopsMapPageArguments.fromLocation({
    required this.latitude,
    required this.longitude,
    this.title = '현재 위치 주변 정류소',
  }) : source = NearbyStopsMapSource.currentLocation, cityCode = null, nodeNo = null;

  NearbyStopsMapPageArguments.fromStop({
    required this.cityCode,
    required this.nodeNo,
    required this.title,
  }) : source = NearbyStopsMapSource.specificStop, latitude = null, longitude = null;
}

class NearbyStopsMapPage extends StatefulWidget {
  final NearbyStopsMapPageArguments arguments;
  const NearbyStopsMapPage({super.key, required this.arguments});

  @override
  State<NearbyStopsMapPage> createState() => _NearbyStopsMapPageState();
}

class _NearbyStopsMapPageState extends State<NearbyStopsMapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  late final NearbyStopsMapBloc _nearbyStopsMapBloc;
  static const CameraPosition _kInitialCameraPosition = CameraPosition(
    target: LatLng(36.3504119, 127.3845475), // 예: 대전 시청 근처
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _nearbyStopsMapBloc = getIt<NearbyStopsMapBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.arguments.source == NearbyStopsMapSource.currentLocation) {
        _loadNearbyStopsByCurrentLocation(); // 현재 위치 로드 및 이벤트 전달
      } else if (widget.arguments.source == NearbyStopsMapSource.specificStop) {
        if (widget.arguments.cityCode != null && widget.arguments.nodeNo != null) {
          _nearbyStopsMapBloc.add(LoadNearbyStopsByStop(
            cityCode: widget.arguments.cityCode!,
            nodeNm: widget.arguments.nodeNo!,
          ));
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('정류소 정보가 부족하여 지도를 표시할 수 없습니다.')),
            );
          }
          _nearbyStopsMapBloc.emit(NearbyStopsMapError(message: '정류소 정보가 부족합니다.'));
        }
      }
    });
  }

  @override
  void dispose() {
    _nearbyStopsMapBloc.close();
    super.dispose();
  }

  // 현재 위치 정보를 비동기적으로 가져오는 함수
  Future<void> _loadNearbyStopsByCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.')),
        );
      }
      _nearbyStopsMapBloc.emit(NearbyStopsMapError(message: '위치 서비스 비활성화'));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한이 거부되었습니다. 앱 설정에서 권한을 허용해주세요.')),
          );
        }
        _nearbyStopsMapBloc.emit(NearbyStopsMapError(message: '위치 권한 거부'));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 수동으로 권한을 허용해야 합니다.')),
        );
      }
      _nearbyStopsMapBloc.emit(NearbyStopsMapError(message: '위치 권한 영구 거부'));
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100));
      // 위치 정보를 가져온 후 BLoC 이벤트 전달
      _nearbyStopsMapBloc.add(LoadNearbyStopsByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 정보를 가져오지 못했습니다: ${e.toString()}')),
        );
      }
      _nearbyStopsMapBloc.emit(NearbyStopsMapError(message: '위치 정보 가져오기 실패: ${e.toString()}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.arguments.title ?? '지도'}'),
      ),
      body: BlocBuilder<NearbyStopsMapBloc, NearbyStopsMapState>(
        bloc: _nearbyStopsMapBloc,
        builder: (context, state) {
          if (state is NearbyStopsMapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NearbyStopsMapLoaded) {
            // 데이터 로드 완료 시 GoogleMap 표시
            return GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition( // 로드된 위치로 초기 카메라 설정
                target: state.centerLocation,
                zoom: 15.0, // 적절한 줌 레벨
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // 지도가 생성된 후, 카메라를 로드된 위치로 이동 (initialCameraPosition과 중복될 수 있으나 안전 장치)
                controller.animateCamera(CameraUpdate.newLatLngZoom(state.centerLocation, 15.0));
              },
              markers: state.markers, // BLoC 상태의 마커 사용
              circles: state.circles, // BLoC 상태의 원 사용
              myLocationEnabled: true, // 현재 위치 파란색 점 표시 (권한 필요)
              myLocationButtonEnabled: false, // 기본 제공 현재 위치 버튼 비활성화
            );
          } else if (state is NearbyStopsMapError) {
            return Center(child: Text('오류: ${state.message}'));
          }
          // 초기 상태
          return const Center(child: Text('지도를 로딩하는 중...'));
        },
      ),
      // 현재 위치로 이동하는 FloatingActionButton (특정 정류소 기준일 때만 표시)
      floatingActionButton: widget.arguments.source == NearbyStopsMapSource.specificStop
          ? FloatingActionButton(
        onPressed: _loadNearbyStopsByCurrentLocation, // FAB 클릭 시 현재 위치 가져오는 함수 호출
        tooltip: '현재 위치로 이동',
        child: const Icon(Icons.my_location),
      )
          : null, // 현재 위치 기준일 때는 FAB 숨김
    );
  }
}

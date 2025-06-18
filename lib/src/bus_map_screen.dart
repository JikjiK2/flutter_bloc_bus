// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_project/src/blocs/bus_location/bus_location_bloc.dart';
// import 'package:flutter_project/src/blocs/bus_location/bus_location_event.dart';
// import 'package:flutter_project/src/blocs/bus_location/bus_location_item.dart';
// import 'package:flutter_project/src/data/bus_location_response.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class BusMapScreen extends StatefulWidget {
//   final String routeId;
//
//   const BusMapScreen({Key? key, required this.routeId}) : super(key: key);
//
//   @override
//   _BusMapScreenState createState() => _BusMapScreenState();
// }
//
// class _BusMapScreenState extends State<BusMapScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // BLoC에 초기 데이터 로드 이벤트 전달
//     BlocProvider.of<BusLocationBloc>(
//       context,
//     ).add(LoadBusLocations(routeId: widget.routeId));
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//
//   CameraPosition _initialCameraPosition = const CameraPosition(
//     target: LatLng(36.35, 127.42),
//     zoom: 17.0,
//   );
//
//   Set<Marker> _buildMarkers(List<BusLocationItem> busLocations) {
//     Set<Marker> markers = {};
//     if (busLocations.isEmpty) {
//       return markers; // 버스 없으면 빈 Set 반환
//     }
//
//     // 모든 버스 위치에 대해 마커 생성
//     for (var location in busLocations) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(location.vehicleno),
//           position: LatLng(location.gpslati, location.gpslong),
//           infoWindow: InfoWindow(
//             title: location.vehicleno,
//             snippet: 'Route: ${location.routenm}',
//           ),
//           visible: true,
//           // TODO: Custom Marker Icon과 Rotation 적용
//         ),
//       );
//     }
//     return markers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Bus Map - ${widget.routeId}')),
//       body: BlocListener<BusLocationBloc, BusLocationState>(
//         listener: (context, state) {
//             if (state.busLocations.isNotEmpty && _controller.isCompleted) {
//               final LatLng firstBusPosition = LatLng(
//                 state.busLocations.first.gpslati,
//                 state.busLocations.first.gpslong,
//               );
//               _controller.future.then((controller) {
//                 controller.animateCamera(
//                   CameraUpdate.newLatLng(firstBusPosition),
//                 );
//               });
//             }
//           } else if (state is BusLocationError) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
//           }
//         },
//         child: BlocBuilder<BusLocationBloc, BusLocationState>(
//           builder: (context, state) {
//             // 로딩 중, 에러 상태에 따른 UI 분기
//             if (state is BusLocationLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is BusLocationError) {
//               return Center(child: Text('Error: ${state.message}'));
//             } else {
//               // BusLocationLoaded 상태일 때, 상태에서 직접 버스 위치 목록을 가져옴
//               final List<BusLocationItem> busLocations =
//                   (state is BusLocationLoaded) ? state.busLocations : [];
//
//               // BLoC 상태의 busLocations 목록을 기반으로 마커 Set 생성
//               final Set<Marker> currentMarkers = _buildMarkers(
//                 busLocations,
//               ); // <--- 여기가 변경되었습니다!
//
//               // 첫 번째 버스 위치 정보 (UI 표시용)
//               final BusLocationItem? firstLocation =
//                   busLocations.isNotEmpty ? busLocations.first : null;
//
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: GoogleMap(
//                         mapType: MapType.normal,
//                         // 초기 카메라 위치는 그대로 사용
//                         initialCameraPosition: _initialCameraPosition,
//                         onMapCreated: (GoogleMapController controller) {
//                           _controller.complete(controller);
//                           // onMapCreated 시점에 BLoC 상태에 이미 데이터가 있다면 해당 위치로 카메라 이동
//                           if (state is BusLocationLoaded &&
//                               state.busLocations.isNotEmpty) {
//                             final initialPos = LatLng(
//                               state.busLocations.first.gpslati,
//                               state.busLocations.first.gpslong,
//                             );
//                             controller.animateCamera(
//                               CameraUpdate.newLatLng(initialPos),
//                             );
//                           }
//                         },
//                         markers:
//                             currentMarkers, // <--- BLoC 상태 기반으로 생성된 마커 Set 사용
//                       ),
//                     ),
//                     if (firstLocation != null) ...[
//                       Text('Latitude: ${firstLocation.gpslati}'),
//                       Text('Longitude: ${firstLocation.gpslong}'),
//                       Text('Vehicle No: ${firstLocation.vehicleno}'),
//                       Text('Route Name: ${firstLocation.routenm}'),
//                     ] else ...[
//                       const Text('Waiting for bus location data...'),
//                     ]
//                   ],
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

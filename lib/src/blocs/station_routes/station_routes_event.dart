import 'package:equatable/equatable.dart';

abstract class StationRoutesEvent extends Equatable {
  const StationRoutesEvent();
  @override
  List<Object> get props => [];
}

class LoadStationRoutes extends StationRoutesEvent {
  final String cityCode;
  final String nodeId; // 정류소 ID

  const LoadStationRoutes({required this.cityCode, required this.nodeId});

  @override
  List<Object> get props => [cityCode, nodeId];
}

class RefreshArrivalInfo extends StationRoutesEvent {
  const RefreshArrivalInfo();
}
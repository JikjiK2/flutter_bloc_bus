import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/data/models/bus_arrival_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';

abstract class StationRoutesState extends Equatable {
  final List<BusStopInfo> stops;
  final Map<String, BusArrivalInfo> arrivalInfoMap;


  const StationRoutesState({
    this.stops = const [],
    this.arrivalInfoMap = const {},
});
  @override
  List<Object> get props => [stops, arrivalInfoMap];
}

class StationRoutesInitial extends StationRoutesState { const StationRoutesInitial({super.stops, super.arrivalInfoMap}); }
class StationRoutesLoading extends StationRoutesState { const StationRoutesLoading({super.stops, super.arrivalInfoMap}); }
class StationRoutesLoaded extends StationRoutesState {
   // API 응답이 정류소 정보 형태로 온다고 가정
  const StationRoutesLoaded({required super.stops, required super.arrivalInfoMap});

  @override
  List<Object> get props => [stops, arrivalInfoMap]; // Equatable을 위해 stops 리스트 포함
}

class StationRoutesError extends StationRoutesState {
  final String message;
  const StationRoutesError({required this.message, required super.stops, required super.arrivalInfoMap});
  @override
  List<Object> get props => [message, stops, arrivalInfoMap];
}

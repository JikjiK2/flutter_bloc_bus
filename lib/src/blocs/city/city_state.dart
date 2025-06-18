import 'package:equatable/equatable.dart';

abstract class CityState extends Equatable {
  // 선택된 도시 코드 목록을 모든 상태가 가지도록 합니다.
  final List<String> selectedCityCodes;
  const CityState({this.selectedCityCodes = const []});

  String? get primaryCityCode => selectedCityCodes.isNotEmpty ? selectedCityCodes.first : null;

  @override
  List<Object> get props => [selectedCityCodes];
}

// 초기 상태 (아직 아무 도시도 선택되지 않았거나 로딩 전)
class CityInitial extends CityState {
  const CityInitial({super.selectedCityCodes});
}

// 도시가 선택된 상태
class CitySelected extends CityState {
  const CitySelected({required super.selectedCityCodes});

  // 선택된 첫 번째 도시 코드를 편리하게 가져오는 getter (단일 선택 시 유용)
  String? get primaryCityCode => selectedCityCodes.isNotEmpty ? selectedCityCodes.first : null;
}

// (선택 사항) 로딩 상태
// class CityLoading extends CityState { const CityLoading({super.selectedCityCodes}); }

// (선택 사항) 오류 상태
// class CityError extends CityState { final String message; const CityError({required this.message, super.selectedCityCodes}); @override List<Object> get props => [message, selectedCityCodes]; }

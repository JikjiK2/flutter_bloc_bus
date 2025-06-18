import 'package:equatable/equatable.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();
  @override
  List<Object> get props => [];
}

// 사용자가 하나 이상의 도시를 선택했을 때 발생하는 이벤트
class SelectCity extends CityEvent {
  final List<String> cityCodes;

  const SelectCity({required this.cityCodes});

  @override
  List<Object> get props => [cityCodes];
}

class LoadSavedCity extends CityEvent {
  const LoadSavedCity();
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_event.dart';
import 'package:flutter_project/src/blocs/city/city_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityBloc extends Bloc<CityEvent, CityState> {

  static const String _selectedCityCodesKey = 'selected_city_codes';

  CityBloc() : super(const CityInitial()) {
    on<SelectCity>(_onSelectCity);
    on<LoadSavedCity>(_onLoadSavedCity);

    add(const LoadSavedCity());
  }

  Future<void> _onSelectCity(SelectCity event, Emitter<CityState> emit) async {
    emit(CitySelected(selectedCityCodes: event.cityCodes));
    print(
      "CityBloc: State updated to CitySelected with codes: ${event.cityCodes}",
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedCityCodesKey, event.cityCodes);
      print("CityBloc: City codes saved to SharedPreferences: $event.cityCodes");
    } catch (e) {
      print("CityBloc: Error saving city codes to SharedPreferences: $e");
    }
  }
  Future<void> _onLoadSavedCity(
      LoadSavedCity event, Emitter<CityState> emit) async {
    print("CityBloc: Attempting to load saved city codes...");
    try {
      final prefs = await SharedPreferences.getInstance();
      // 저장된 List<String> 불러오기
      final List<String>? savedCityCodes = prefs.getStringList(_selectedCityCodesKey);

      if (savedCityCodes != null && savedCityCodes.isNotEmpty) {
        // 불러온 데이터가 있으면 해당 데이터로 상태 설정
        emit(CitySelected(selectedCityCodes: savedCityCodes));
        print("CityBloc: Loaded ${savedCityCodes.length} saved city codes: $savedCityCodes");
      } else {
        // 저장된 데이터가 없으면 초기 상태 유지 (또는 기본 도시 설정)
        emit(const CityInitial()); // 또는 CitySelected(selectedCityCodes: ['기본도시코드'])
        print("CityBloc: No saved city codes found. Emitting CityInitial.");
      }
    } catch (e) {
      print("CityBloc: Error loading saved city codes: $e");
      // 불러오기 오류 발생 시 에러 상태 emit 또는 기본 상태 유지
      emit(CityInitial());
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/utils/constants.dart' as AppConstantsFile;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/views/by_location_station.dart';
import 'package:flutter_project/src/views/favorites_screen.dart';
import 'package:flutter_project/src/views/region_selection_screen.dart';
import 'package:flutter_project/src/views/route_and_station_search.dart';
import 'package:get_it/get_it.dart';


Future<void> _navigateToNearbyStopsMapByLocation(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          BlocProvider<NearbyStopsMapBloc>( // BLoCProvider로 감싸서 제공
            create: (context) => getIt<NearbyStopsMapBloc>(),
            child: NearbyStopsMapPage(
              arguments: NearbyStopsMapPageArguments
                  .fromLocation( // 위치 인자 전달 (lat/lng는 페이지 내부에서 가져옴)
                latitude: null, // 초기에는 null 전달
                longitude: null, // 초기에는 null 전달
                title: '현재 위치 주변 정류소',
              ),
            ),
          ),
    ),
  );
}

Future<void> _navigateToFavorites(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          BlocProvider<NearbyStopsMapBloc>( // BLoCProvider로 감싸서 제공
            create: (context) => getIt<NearbyStopsMapBloc>(),
            child: FavoriteScreen(),
          ),
    ),
  );
}


void _navigateToRegionSelection(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RegionSelectionPage(),
    ),
  );
}

class TestStf extends StatefulWidget {
  const TestStf({super.key});

  @override
  State<TestStf> createState() => _TestStfState();
}

class _TestStfState extends State<TestStf> {
  @override
  Widget build(BuildContext context) {
    final cityState = context.watch<CityBloc>().state;

    // CityState에서 선택된 도시 코드 목록을 가져옵니다.
    final List<String> selectedCityCodes = cityState.selectedCityCodes;

    final List<String> selectedCityNames = selectedCityCodes.map((cityCode){
      return AppConstantsFile.AppConstants.supportedCitiesStringKey[cityCode] ?? "알 수 없는 지역 ($cityCode)";
    }).toList();

    final String selectedCitiesDisplayText = selectedCityNames.join(', ');

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            '현재 선택된 지역:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // ********** 선택된 모든 지역 이름 표시 **********
          Text(
            selectedCitiesDisplayText.isEmpty ? "지역을 선택해주세요" : selectedCitiesDisplayText,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            '선택된 도시 코드:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // ********** 선택된 도시 코드 목록 표시 **********
          Text(
            selectedCityCodes.isEmpty ? "선택된 코드가 없습니다" : selectedCityCodes.join(', '),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // ********** 버튼 클릭 시 현재 선택된 cityCode를 사용하여 로직 실행 **********
              // context.read<CityBloc>()를 사용하여 현재 상태 값을 읽어옵니다.
              final currentCityState = context.read<CityBloc>().state;
              final List<String> currentSelectedCodes = currentCityState.selectedCityCodes;

              if (currentSelectedCodes.isNotEmpty) {
                print('버튼 클릭: 현재 선택된 지역 코드 목록: $currentSelectedCodes 입니다.');
                // 선택된 cityCode 목록을 사용하여 해당 지역의 데이터 로딩 이벤트 전달 등 로직 수행
                // 예: context.read<BusLocationBloc>().add(LoadBusLocations(cityCodes: currentSelectedCodes, routeId: 'someRouteId')); // 여러 cityCode를 받는 이벤트 필요
              } else {
                print('버튼 클릭: 선택된 지역이 없습니다.');
              }
            },
            child: const Text('선택된 지역 코드 확인 및 사용'),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToRegionSelection(context);
            },
            child: const Text('지역 설정'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
            },
            child: const Text('검색'),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToNearbyStopsMapByLocation(context);

            },
            child: const Text('현재 위치 기반 500m 반경 정류장 찾기'),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToFavorites(context);
            },
            child: const Text('즐겨찾기 목록'),
          ),
        ],
      ),),
    );
  }
}

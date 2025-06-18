import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_event.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/utils/constants.dart'; // AppConstants 파일 import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupServiceLocator();
  runApp(MyApp()); // 앱 실행 (UI 렌더링은 그대로 진행)
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Bus Location App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegionSelectionPage(),
    );
  }
}


class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({Key? key}) : super(key: key);

  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  // 지역별로 그룹화되고 정렬된 전체 도시 데이터
  late final Map<String, List<MapEntry<String, String>>> _allGroupedCities;

  // 검색 결과에 따라 필터링된 도시 데이터 (UI 표시용)
  late Map<String, List<MapEntry<String, String>>> _filteredGroupedCities;

  // 각 지역 그룹의 ExpansionPanel이 열려있는지 상태 관리 (필터링된 데이터 기준)
  late List<bool> _isExpanded;

  // 검색어 상태 변수
  String _searchQuery = '';

  // 선택된 도시 코드를 저장하는 Set
  final Set<String> _selectedCityCodes = {};

  @override
  void initState() {
    super.initState();
    // AppConstants 파일에서 전체 그룹화 및 정렬된 데이터 가져오기
    _allGroupedCities = AppConstants.getGroupedAndSortedCities();
    // 초기에는 전체 데이터를 필터링된 데이터로 사용
    _filteredGroupedCities = Map.from(_allGroupedCities);
    // 초기에는 모든 그룹을 닫힌 상태로 설정 (필터링된 데이터 개수 기준)
    _isExpanded = List<bool>.filled(_filteredGroupedCities.length, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("RegionSelectionPage: addPostFrameCallback executed. Initializing local selection from BLoC.");
      try {
        final currentSelectedCodes = context.read<CityBloc>().state.selectedCityCodes;
        setState(() {
          _selectedCityCodes.addAll(currentSelectedCodes); // BLoC 상태의 선택된 코드를 임시 Set에 추가
          print("RegionSelectionPage: Local selection initialized with ${_selectedCityCodes.length} codes from BLoC.");
        });
      } catch (e) {
        print("Error initializing local selection from BLoC: $e");
        // BLoC 인스턴스를 찾지 못하거나 상태 읽기 오류 시 (매우 드물어야 함)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('선택 상태 초기화 오류: ${e.toString()}')),
          );
        }
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  // 검색 쿼리에 따라 도시 목록을 필터링하는 함수
  // _BusMapScreenState 클래스 내부 _filterCities 함수

  void _filterCities(String query) {
    _searchQuery = query.toLowerCase();
    final List<String> regionsToExpand = [];
    if (query.isEmpty) {
      _filteredGroupedCities = Map.from(_allGroupedCities);
    } else {
      final Map<String, List<MapEntry<String, String>>> tempFiltered = {};
      // 검색어 포함 그룹은 자동 열림

      _allGroupedCities.forEach((regionName, cityList) {
        final bool regionMatches = regionName.toLowerCase().contains(_searchQuery);
        final List<MapEntry<String, String>> filteredCities = cityList.where((cityEntry) {
          return cityEntry.value.toLowerCase().contains(_searchQuery);
        }).toList();

        if (regionMatches || filteredCities.isNotEmpty) {
          tempFiltered[regionName] = regionMatches ? cityList : filteredCities;
          regionsToExpand.add(regionName);
        }
      });
      _filteredGroupedCities = tempFiltered;
    }

    // ********** 필터링된 그룹 개수에 맞춰 _isExpanded 리스트를 다시 초기화 **********
    // 항상 필터링된 맵의 현재 개수(_filteredGroupedCities.length)에 맞춰 초기화합니다.
    _isExpanded = List<bool>.filled(_filteredGroupedCities.length, false);

    // 검색어 포함 그룹은 expanded 상태를 true로 설정 (재초기화 후 다시 설정)
    _filteredGroupedCities.keys.toList().asMap().forEach((index, regionName) {
      if (regionsToExpand.contains(regionName)) {
        _isExpanded[index] = true;
      }
    });

    setState(() {});
  }


  // 도시 항목 (그리드 뷰 아이템) 클릭 시 선택/해제 토글
  void _toggleCitySelection(String cityCode) {
    setState(() {
      if (_selectedCityCodes.contains(cityCode)) {
        _selectedCityCodes.remove(cityCode);
      } else {
        // 단일 선택만 허용하려면
        // _selectedCityCodes.clear();
        _selectedCityCodes.add(cityCode);
      }
    });
  }

  // 선택 완료 버튼 클릭 시 동작 (예시)
  void _confirmSelection() {
    print("선택 완료 버튼 클릭. 임시 선택된 도시 코드 목록: $_selectedCityCodes");

    // BLoC 인스턴스 가져오기 (context.read 사용)
    final cityBloc = context.read<CityBloc>();

    // SelectCity 이벤트 전달 (임시 선택된 도시 코드 목록을 BLoC에 전달)
    cityBloc.add(SelectCity(cityCodes: _selectedCityCodes.toList()));
    print("SelectCity event dispatched to CityBloc.");

    // 선택된 도시 코드 목록을 결과로 이전 화면에 전달하고 현재 화면 닫기
    Navigator.pop(context, _selectedCityCodes.toList());
    print("Navigating back with selected codes.");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 설정'),
        actions: [ // 선택 완료 버튼
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          )
        ],
      ),
      body: Column( // 검색창과 ExpansionPanelList를 Column으로 묶음
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField( // 검색창
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: '시, 군을 입력하세요.',
                prefixIcon: Icon(Icons.search, color: Colors.grey,),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: _filterCities, // 텍스트 변경 시 필터링 함수 호출
            ),
          ),
          Expanded( // ExpansionPanelList가 남은 공간을 채우도록 Expanded 사용
            child: SingleChildScrollView( // ExpansionPanelList 내부 스크롤 처리
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpanded[index] = isExpanded;
                  });
                },
                children: _filteredGroupedCities.entries.toList().asMap().entries.map((entry) {
                  final int index = entry.key;
                  final MapEntry<String, List<MapEntry<String, String>>> regionEntry = entry.value;

                  final String regionName = regionEntry.key;
                  final List<MapEntry<String, String>> cityList = regionEntry.value;

                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text('$regionName (${cityList.length})'),
                      );
                    },
                    // ********** 본문 영역을 그리드 뷰로 변경 **********
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: GridView.builder(
                        shrinkWrap: true, // Column 안에 GridView 사용 시 필요
                        physics: const NeverScrollableScrollPhysics(), // GridView 자체 스크롤 방지 (SingleChildScrollView가 처리)
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 2열 그리드
                          crossAxisCount: 4, // 한 줄에 2개 항목
                          childAspectRatio: 3, // 항목의 가로/세로 비율 조정
                          crossAxisSpacing: 8, // 가로 간격
                          mainAxisSpacing: 8, // 세로 간격
                        ),
                        itemCount: cityList.length,
                        itemBuilder: (BuildContext context, int cityIndex) {
                          final MapEntry<String, String> cityEntry = cityList[cityIndex];
                          final String cityCode = cityEntry.key;
                          final String cityName = cityEntry.value;

                          // 해당 도시가 선택되었는지 확인
                          final bool isSelected = _selectedCityCodes.contains(cityCode);

                          // ********** 그리드 뷰 항목 위젯 (선택 가능) **********
                          return InkWell( // 탭 효과를 위한 InkWell
                            onTap: () => _toggleCitySelection(cityCode), // 탭 시 선택 토글
                            child: Container( // 항목 배경 및 디자인
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200, // 선택 시 배경색 변경
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey, // 선택 시 테두리색 변경
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row( // 체크박스 아이콘과 텍스트
                                mainAxisSize: MainAxisSize.min, // Row 크기 최소화
                                children: [
                                  Icon( // 선택 상태에 따라 아이콘 변경
                                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded( // 도시 이름이 길어지면 잘리지 않도록
                                    child: Text(
                                      cityName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.blue.shade900 : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis, // 넘치는 텍스트 ... 처리
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    isExpanded: _isExpanded[index],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

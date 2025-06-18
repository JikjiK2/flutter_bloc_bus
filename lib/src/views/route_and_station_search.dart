import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_bloc.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/views/station_arrival_bus.dart';
import 'package:flutter_project/src/views/station_routes_screen.dart';
import 'package:get_it/get_it.dart'; // GetIt 사용

// BLoC 및 모델 import 경로를 프로젝트 구조에 맞게 수정하세요.
import 'package:flutter_project/src/blocs/search/search_bloc.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/blocs/search/search_state.dart';
import 'package:flutter_project/src/data/models/bus_route_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';

import 'package:flutter_project/src/utils/constants.dart' as AppConstantsFile;

// GetIt 인스턴스 (main.dart 또는 service_locator.dart에서 정의된 전역 변수)
final getIt = GetIt.instance;

void _navigateToStationRoutes(
  BuildContext context,
  String cityCode,
  String nodeId,
  String nodeName,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) =>
          // ********** StationRoutesPage를 BlocProvider로 감싸기 **********
          BlocProvider<StationRoutesBloc>(
            // <--- BlocProvider 사용 확인
            // create 콜백에서 GetIt을 사용하여 BLoC 인스턴스 생성
            create:
                (context) => getIt<StationRoutesBloc>(), // <--- GetIt으로 인스턴스 생성
            // BLoCProvider의 child로 실제 화면 위젯 지정
            child: StationRoutesPage(
              cityCode: cityCode,
              nodeId: nodeId,
              nodeName: nodeName,
            ),
          ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  late final SearchBloc _searchBloc;

  SearchType _currentSearchType = SearchType.bus;

  final Map<String, bool> _regionExpandedState = {};

  @override
  void initState() {
    super.initState();
    print("SearchPage initState");

    try {
      _searchBloc = getIt<SearchBloc>();
      print("SearchBloc instance obtained from GetIt.");
    } catch (e) {
      print("Error obtaining SearchBloc from GetIt: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('앱 초기 설정 오류: 검색 기능을 사용할 수 없습니다.')),
        );
      }
    }

    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
    _tabController.addListener(_onTabChanged);

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("SearchPage: addPostFrameCallback executed.");
      try {
        // context.read<Bloc>()는 addPostFrameCallback 내부에서 안전합니다.
        final currentState = context.read<SearchBloc>().state;
        print(
          "SearchPage: Current Bloc state received. currentQuery: '${currentState.currentQuery}'",
        );
        // BLoC 상태의 currentQuery 값을 검색창 텍스트 필드에 설정
        _searchController.text = currentState.currentQuery;
        print(
          "SearchPage: Populated search bar with currentQuery from BLoC state.",
        );

        print("SearchPage: Requesting focus on search bar.");
        _searchFocusNode.requestFocus(); // 검색창에 포커스 요청
      } catch (e) {
        print(
          "SearchPage: Error accessing Bloc state or setting focus in addPostFrameCallback: $e",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('검색 상태 초기화 오류: ${e.toString()}')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    print("SearchPage dispose");
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 탭 변경 시 호출되는 리스너
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    setState(() {
      _currentSearchType =
          _tabController.index == 0 ? SearchType.bus : SearchType.station;
      print("SearchPage: Tab changed to $_currentSearchType");
      final cityState = context.read<CityBloc>().state;
      _searchBloc.add(
        SearchQueryChanged(
          query: _searchController.text,
          searchType: _currentSearchType,
          selectedCityCodes: cityState.selectedCityCodes,
        ),
      );
    });
  }

  void _onSearchTextChanged(String query) {
    final cityState = context.read<CityBloc>().state;
    _searchBloc.add(
      SearchQueryChanged(
        query: query,
        searchType: _currentSearchType,
        selectedCityCodes: cityState.selectedCityCodes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building SearchPage");
    return BlocBuilder<SearchBloc, SearchState>(
        bloc: _searchBloc, // 사용할 BLoC 인스턴스 지정
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              // AppBar 가운데 검색 필드
              title: Container(
                width: double.infinity, // 가로 전체 사용
                height: 40, // 높이 설정
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController, // 컨트롤러 연결
                    focusNode: _searchFocusNode, // 포커스 노드 연결
                    onChanged: _onSearchTextChanged, // 텍스트 변경 리스너 연결
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      // 기본 테두리 제거
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      // 내부 패딩
                      suffixIcon:
                      state.currentQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear), // 삭제(Clear) 아이콘
                        onPressed: () {
                          _searchController.clear();
                          _searchBloc.add(ClearSearchQuery());
                        }, // 버튼 클릭 시 _clearText 함수 호출
                        tooltip: '텍스트 전체 삭제', // 길게 눌렀을 때 표시되는 툴팁
                      )
                          : null,
                    ),
                  ),
                ),
              ),
              // AppBar 오른쪽 아이콘 버튼 (추후 필요시 추가)
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert), // 예시 아이콘
                  onPressed: () {
                    // TODO: 추후 기능 구현
                  },
                ),
              ],
              // AppBar 하단에 탭바 배치
              bottom: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: '버스'), Tab(text: '정류장')],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                // 선택된 탭 밑줄 색상
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            body: TabBarView(
              controller: _tabController, // 컨트롤러 연결
              children: [
                // 버스 검색 결과 탭
                _buildSearchResults(SearchType.bus),
                // 정류장 검색 결과 탭
                _buildSearchResults(SearchType.station),
              ],
            ),
          );
        }
    );
  }

  // 검색 결과 표시 위젯 빌드 함수
  Widget _buildSearchResults(SearchType searchType) {
    // BlocBuilder를 사용하여 SearchBloc 상태에 따라 UI 업데이트
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc, // 사용할 BLoC 인스턴스 지정
      builder: (context, state) {
        print(
          "BlocBuilder for $searchType received state: ${state.runtimeType}",
        );
        print(
          "SearchPage: Current query: '${state.currentQuery}', Recent searches count: ${state.recentSearches.length}",
        );
        if (state.currentSearchType != searchType) {
          return Container();
        }
        print(
          "==========================${state.recentSearches.isNotEmpty}=============${state.recentSearches.length}=============",
        );
        if (state.currentQuery.isEmpty && state.recentSearches.isNotEmpty) {
          print(
            "SearchPage: Building recent searches list. Count: ${state.recentSearches.length}",
          );
          // 현재 탭에 해당하는 최근 검색 항목만 필터링 (선택 사항)
          final filteredRecentSearches =
              state.recentSearches
                  .where((item) => item.searchType == searchType)
                  .toList();

          if (filteredRecentSearches.isEmpty) {
            return const Center(child: Text("최근 검색 항목이 없습니다."));
          }

          return ListView.builder(
            itemCount: filteredRecentSearches.length,
            itemBuilder: (context, index) {
              final recentItem = filteredRecentSearches[index];
              String? regionName =
                  AppConstantsFile
                      .AppConstants
                      .supportedCitiesStringKey[recentItem.cityCode];
              if (regionName != null) {
                regionName = AppConstantsFile.AppConstants.removeRegionMap(
                  regionName,
                );
              }

              if (recentItem.searchType == SearchType.bus) {
                String routeType = recentItem.routetp ?? '유형 없음';
                if (routeType.endsWith('버스')) {
                  routeType = routeType.replaceAll('버스', '');
                }
                Color typeBackColor = Colors.black;
                if (routeType.contains('농어촌') || routeType.contains('마을')) {
                  typeBackColor = Colors.green;
                }
                return ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: typeBackColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '$routeType',
                          style: TextStyle(color: Colors.white, fontSize: 10.0),
                        ),
                      ),
                      Text(' ${recentItem.itemName ?? '노선 번호 없음'} '),
                      Text(
                        '[$regionName]',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ],
                  ),
                  subtitle: Text('${recentItem.itemSubtitle ?? '정보 없음'}'),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      print('최근 검색 항목 삭제: ${recentItem.itemName}');
                      _searchBloc.add(RemoveRecentSearchItem(item: recentItem));
                    },
                  ),
                  // 검색어 표시 (선택 사항)
                  onTap: () {
                    print('최근 검색 항목 클릭: ${recentItem.itemName}');
                    // 해당 항목의 상세 화면으로 다시 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StationArrivalBus(
                                cityCode: recentItem.cityCode,
                                routeId: recentItem.itemId ?? '',
                                routeno: recentItem.itemName ?? '',
                              ),
                        ),
                      );

                  },
                );
              }
              if (recentItem.searchType == SearchType.station) {
                return ListTile(
                  leading: const Icon(Icons.bus_alert),
                  title: Text(recentItem.itemName ?? '정류소 이름 없음'),
                  subtitle: Text(
                    '${recentItem.nodeno ?? '없음'} | ${recentItem.itemId ?? '없음'}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      print('최근 검색 항목 삭제: ${recentItem.itemName}');
                      _searchBloc.add(RemoveRecentSearchItem(item: recentItem));
                    },
                  ),
                  onTap: () {
                    print('최근 검색 항목 클릭: ${recentItem.itemName}');

                      _navigateToStationRoutes(
                        context,
                        recentItem.cityCode,
                        recentItem.itemId ?? '',
                        recentItem.itemName ?? '정류소 정보 없음',
                      );

                  },
                );
              }
              return const Center(child: Text("최근 검색 항목이 없습니다."));
            },
          );
        }

        if (state.currentQuery.isNotEmpty) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            final Map<String, List<dynamic>> groupedResults =
                searchType == SearchType.bus
                    ? state.busResults
                    : state.stationResults;

            if (groupedResults.isEmpty && state.currentQuery.isNotEmpty) {
              return Center(
                child: Text("'$state.currentQuery'에 대한 검색 결과가 없습니다."),
              );
            } else if (groupedResults.isEmpty &&
                state.currentQuery.isEmpty &&
                state.selectedCityCodes.isNotEmpty) {
              return const Center(child: Text("검색어를 입력하세요."));
            } else if (groupedResults.isEmpty &&
                state.currentQuery.isEmpty &&
                state.selectedCityCodes.isEmpty) {
              return const Center(child: Text("지역을 먼저 선택해주세요."));
            }

            final sortedCityCodes = groupedResults.keys.toList()..sort();

            return SingleChildScrollView(
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    final cityCode = sortedCityCodes[index];
                    _regionExpandedState[cityCode] = isExpanded;
                  });
                },
                children:
                    sortedCityCodes.asMap().entries.map((entry) {
                      final String cityCode = entry.value;

                      final String regionName =
                          AppConstantsFile
                              .AppConstants
                              .supportedCitiesStringKey[cityCode] ??
                          "알 수 없는 지역 ($cityCode)";

                      final List<dynamic> resultsForCity =
                          groupedResults[cityCode] ?? [];

                      final bool isExpanded =
                          _regionExpandedState[cityCode] ?? true;

                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              '$regionName (${resultsForCity.length})',
                            ),
                          );
                        },
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:
                              resultsForCity.map((item) {
                                if (item is BusRouteInfo) {
                                  String routeType = item.routetp ?? '유형 없음';
                                  if (routeType.endsWith('버스')) {
                                    routeType = routeType.replaceAll('버스', '');
                                  }
                                  Color typeBackColor = Colors.black;
                                  if (routeType.contains('농어촌') ||
                                      routeType.contains('마을')) {
                                    typeBackColor = Colors.green;
                                  }
                                  return ListTile(
                                    leading: const Icon(Icons.directions_bus),
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(1.0),
                                          decoration: BoxDecoration(
                                            color: typeBackColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Text(
                                            '$routeType',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ),
                                        Text(' ${item.routeno ?? '노선 번호 없음'}'),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '${item.startnodenm ?? '정보 없음'} <-> ${item.endnodenm ?? '정보 없음'}',
                                    ),
                                    onTap: () {
                                      print('버스 클릭: ${item.routetp}');
                                      final recentItem = RecentSearchItem(
                                        routetp: item.routetp ?? '',
                                        searchType: SearchType.bus,
                                        cityCode: cityCode,
                                        itemId: item.routeid ?? '',
                                        itemName: item.routeno ?? '노선 정보 없음',
                                        itemSubtitle:
                                            '${item.startnodenm ?? '정보 없음'} <-> ${item.endnodenm ?? '정보 없음'}',
                                      );
                                      print(
                                        "SearchPage: Adding AddRecentSearchItem event for item: ${recentItem.itemName}",
                                      );
                                      _searchBloc.add(
                                        AddRecentSearchItem(item: recentItem),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => StationArrivalBus(
                                                cityCode: cityCode,
                                                routeId: item.routeid ?? '',
                                                routeno: item.routeno ?? '',
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (item is BusStopInfo) {
                                  return ListTile(
                                    leading: const Icon(Icons.bus_alert),
                                    title: Text(item.nodenm ?? '정류소 이름 없음'),
                                    subtitle: Text(
                                      '${item.nodeno ?? '없음'} | ${item.nodeid ?? '없음'}',
                                    ),
                                    onTap: () {
                                      print('정류장 클릭: ${item.nodenm}');
                                      final recentItem = RecentSearchItem(
                                        routetp: '',
                                        nodeno: item.nodeno ?? '',
                                        searchType: SearchType.station,
                                        cityCode: cityCode,
                                        itemId: item.nodeid ?? '',
                                        itemName: item.nodenm ?? '노선 정보 없음',
                                        itemSubtitle: '',
                                      );
                                      print(
                                        "SearchPage: Adding AddRecentSearchItem event for item: ${recentItem.itemName}",
                                      );
                                      _searchBloc.add(
                                        AddRecentSearchItem(item: recentItem),
                                      );
                                      _navigateToStationRoutes(
                                        context,
                                        cityCode,
                                        item.nodeid ?? '',
                                        item.nodenm ?? '정류소 정보 없음',
                                      );
                                    },
                                  );
                                }
                                return Container();
                              }).toList(),
                        ),
                        isExpanded: isExpanded,
                      );
                    }).toList(),
              ),
            );
          } else if (state is SearchError) {
            return Center(child: Text('오류: ${state.message}'));
          }
        }

        if (_searchController.text.isEmpty && state.recentSearches.isEmpty) {
          // 검색창 텍스트 기준
          print(
            "SearchPage: TextField is empty and no recent searches. Building initial message.",
          ); // 로그 추가
          return const Center(child: Text("버스 또는 정류장을 검색하세요."));
        }
        return const Center(child: Text("버스 또는 정류장을 검색하세요."));
      },
    );
  }
}

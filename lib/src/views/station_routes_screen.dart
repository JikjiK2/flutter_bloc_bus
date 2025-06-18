import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_state.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_bloc.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_event.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_state.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/data/models/bus_arrival_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/views/by_location_station.dart';


class StationRoutesPage extends StatefulWidget {
  final String cityCode;
  final String nodeId; // 정류소 ID
  final String nodeName; // 화면 제목 등에 사용할 정류소 이름 (선택 사항)

  const StationRoutesPage({
    Key? key,
    required this.cityCode,
    required this.nodeId,
    required this.nodeName,
  }) : super(key: key);

  @override
  _StationRoutesPageState createState() => _StationRoutesPageState();
}

class _StationRoutesPageState extends State<StationRoutesPage> with WidgetsBindingObserver {
  late final StationRoutesBloc _stationRoutesBloc;

  final ScrollController _scrollController = ScrollController();

  void _navigateToNearbyStopsMapByStop(BuildContext context, String cityCode, String nodeNo, String stopName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BlocProvider<NearbyStopsMapBloc>( // BLoCProvider로 감싸서 제공
                create: (context) => getIt<NearbyStopsMapBloc>(),
                child: NearbyStopsMapPage(
                  arguments: NearbyStopsMapPageArguments.fromStop( // 정류소 인자 전달
                    cityCode: cityCode,
                    nodeNo: nodeNo,
                    title: stopName,
                  ),
                ),
              ),
        )
    ).then((_) {
      _stationRoutesBloc.resumePolling();
    });
  }

  @override
  void initState() {
    super.initState();
    print("StationRoutesPage initState START");
    WidgetsBinding.instance.addObserver(this);
    try {
      _stationRoutesBloc = getIt<StationRoutesBloc>();
      print("StationRoutesBloc instance obtained and event dispatched.");
      _stationRoutesBloc.add(
        LoadStationRoutes(cityCode: widget.cityCode, nodeId: widget.nodeId),
      );
    } catch (e) {
      print("Error obtaining BLoC in addPostFrameCallback: $e");
      // addPostFrameCallback 내부에서는 context 사용이 안전합니다.
      if (mounted) {
        print("Showing SnackBar from addPostFrameCallback catch block.");
        ScaffoldMessenger.of(context).showSnackBar(
          // <--- 이 라인 직전에 오류 발생 가능성
          SnackBar(content: Text('앱 초기 설정 오류: 노선 정보 조회를 할 수 없습니다.')),
        );
      }
    }
  }
  void _scrollToTop(){
    _scrollController.animateTo(
      0.0, // 최상단 위치 (0.0)로 이동
      duration: const Duration(milliseconds: 500), // 0.5초 동안 애니메이션
      curve: Curves.easeInOut, // 부드러운 애니메이션 효과
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    _scrollController.dispose();
    _stationRoutesBloc.close(); // GetIt.registerFactory 사용 시 주석 해제
    print("StationRoutesPage dispose");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("StationRoutesPage: App lifecycle state changed: $state");
    if (state == AppLifecycleState.paused) {
      // 화면이 비활성화될 때 (다른 화면이 위에 덮이거나 앱이 백그라운드로 갈 때)
      print("StationRoutesPage: App paused. Pausing Polling.");
      _stationRoutesBloc.pausePolling(); // BLoC의 Polling 일시 중지 메서드 호출
    } else if (state == AppLifecycleState.resumed) {
      // 화면이 다시 활성화될 때 (다른 화면이 사라지거나 앱이 포그라운드로 올 때)
      print("StationRoutesPage: App resumed. Resuming Polling.");
      _stationRoutesBloc.resumePolling(); // BLoC의 Polling 다시 시작 메서드 호출
    }
    // AppLifecycleState.inactive, AppLifecycleState.detached 등 다른 상태도 필요시 처리
  }

  @override
  Widget build(BuildContext context) {
    print("Building StationRoutesPage");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.nodeName} ${widget.nodeId} 경유 노선',
        ), // 정류소 이름으로 제목 표시
      ),
      body: CustomScrollView(
        // ScrollController를 CustomScrollView에 연결합니다.
        controller: _scrollController,
        slivers: <Widget>[
          // 상단 정류소 정보 및 지도 버튼 부분을 SliverToBoxAdapter로 감쌉니다.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '정류소: ${widget.nodeName}', // 정류소 이름 표시 (기존 로직 유지)
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '정류소 ID: ${widget.nodeId}', // 정류소 ID 표시 (기존 로직 유지)
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // 지도 버튼 (기존 로직 유지)
                    ElevatedButton.icon(
                      onPressed: () {
                        print("StationRoutesPage: Map button pressed for station ${widget.nodeName}."); // 기존 로직 유지
                        _stationRoutesBloc.pausePolling(); // 기존 로직 유지
                        _navigateToNearbyStopsMapByStop(context, widget.cityCode, widget.nodeName, widget.nodeId); // 기존 로직 유지
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('지도 보기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 구분선도 SliverToBoxAdapter로 감쌉니다.
          SliverToBoxAdapter(
            child: const Divider(height: 1),
          ),
          // "경유 노선 목록" 제목 부분도 SliverToBoxAdapter로 감쌉니다.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '경유 노선 목록',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),


          // BlocBuilder 내부에서 Sliver 위젯을 반환하도록 수정합니다.
          // BLoC 로직 자체는 수정하지 않고, 상태에 따라 반환하는 UI 위젯 형태만 Sliver로 변경합니다.
          BlocBuilder<StationRoutesBloc, StationRoutesState>(
            bloc: _stationRoutesBloc, // 사용할 BLoC 인스턴스 지정 (기존 로직 유지)
            builder: (context, state) {
              print("BlocBuilder received state: ${state.runtimeType}"); // 기존 로직 유지
              print("123456 ${state is StationRoutesLoading}--"); // 기존 로직 유지

              // 로딩 중이지만 이미 데이터가 일부 로드된 경우 (polling 중 업데이트 등)
              if (state is StationRoutesLoading && state.stops.isNotEmpty) {
                // SliverList를 사용하여 현재까지 로드된 데이터를 보여줍니다.
                // 로딩 인디케이터는 리스트 하단 등에 추가할 수 있습니다.
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final routeInfo = state.stops[index]; // 기존 로직 유지
                      final arrivalInfo = state.arrivalInfoMap[routeInfo.routeid]; // routeid로 도착 정보 찾기 (기존 로직 유지)
                      // _buildRouteList 대신 _buildRouteItem 호출
                      return _buildRouteItem(context, routeInfo, arrivalInfo);
                    },
                    childCount: state.stops.length, // 기존 로직 유지
                  ),
                );
              }
              // 로딩 중이고 데이터가 없는 경우 (최초 로딩)
              if (state is StationRoutesLoading) {
                // SliverFillRemaining을 사용하여 남은 공간을 채우고 중앙에 로딩 인디케이터 표시
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is StationRoutesLoaded) {
                final List<BusStopInfo> routesPassingStation = state.stops; // 기존 로직 유지
                final Map<String, BusArrivalInfo> arrivalInfoMap = state.arrivalInfoMap; // 기존 로직 유지

                if (routesPassingStation.isEmpty) {
                  // 데이터가 없을 때도 SliverFillRemaining 사용
                  return const SliverFillRemaining(
                    child: Center(child: Text('경유 노선 정보가 없습니다.')),
                  );
                }
                // 데이터 로드 완료 시 SliverList로 목록 표시
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final routeInfo = routesPassingStation[index]; // 기존 로직 유지
                      final arrivalInfo = arrivalInfoMap[routeInfo.routeid]; // routeid로 도착 정보 찾기 (기존 로직 유지)
                      // _buildRouteList 대신 _buildRouteItem 호출
                      return _buildRouteItem(context, routeInfo, arrivalInfo);
                    },
                    childCount: routesPassingStation.length, // 리스트 아이템 개수 지정 (기존 로직 유지)
                  ),
                );
              } else if (state is StationRoutesError) {
                // 에러 발생 시 SliverFillRemaining 사용
                return SliverFillRemaining(
                  child: Center(child: Text('오류: ${state.message}')), // 기존 로직 유지
                );
              }
              // 초기 상태 처리
              return const SliverFillRemaining(
                child: Center(child: Text('노선 정보를 불러오는 중...')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.3),
            child: FloatingActionButton(
              heroTag: "fab1",
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _scrollToTop();
              },
            ),
          ),
          Align(
            alignment: Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.15),
            child: FloatingActionButton(
              heroTag: "fab2",
              child: Icon(Icons.map),
              onPressed: () {
                print("StationRoutesPage: Map button pressed for station ${widget.nodeName}."); // 기존 로직 유지
                _stationRoutesBloc.pausePolling(); // 기존 로직 유지
                _navigateToNearbyStopsMapByStop(context, widget.cityCode, widget.nodeName, widget.nodeId); // 기존 로직 유지
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "fab3",
              onPressed: () {
                print(
                  "StationRoutesPage: Refresh FAB pressed. Adding RefreshArrivalInfo event.",
                );
                // BLoC에 새로고침 이벤트 전달
                _stationRoutesBloc.add(const RefreshArrivalInfo());
              },
              tooltip: '도착 정보 새로고침',
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(BuildContext context, BusStopInfo routeInfo, BusArrivalInfo? arrivalInfo) {
    // 여기서 각 노선 아이템(ListTile 등)을 빌드합니다.
    // 기존 _buildRouteList 내부의 아이템 빌드 로직을 여기에 넣으세요.
    // 예시:
    return ListTile(
      // trailing: ... (기존 FavoriteBloc 관련 코드)
      trailing: BlocSelector<FavoriteBloc, FavoriteState, bool>(
        selector: (state) {
          // FavoriteBloc의 상태에서 현재 노선이 즐겨찾기인지 확인
          // RecentSearchItem의 searchType을 bus로 설정하는 것이 맞는지 확인 필요
          final item = RecentSearchItem(
            routetp: routeInfo.routetp ?? '', // routetp 필드가 있다면 사용
            nodeno: routeInfo.nodeno, // 노선 정보에서는 nodeno 대신 routeNo 등을 사용할 수 있습니다. 확인 필요.
            searchType: SearchType.station, // 노선 정보이므로 SearchType.bus가 적절합니다.
            cityCode: widget.cityCode,
            itemId: routeInfo.routeid ?? '', // 노선 ID 사용
            itemName: routeInfo.routeno ?? '노선 번호 없음', // 노선 번호 사용
            itemSubtitle: routeInfo.routetp ?? '', // 노선 타입 등을 subtitle로 사용
          );
          // print('BlocSelector selector called for ${item.itemName}'); // 디버깅용
          return state.favoriteItems.contains(item);
        },
        builder: (context, isFavorite) {
          return IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? const Color.fromARGB(255, 254, 224, 41) : null,
              size: 30.0,
            ),
            onPressed: () {
              final item = RecentSearchItem(
                routetp: routeInfo.routetp ?? '',
                nodeno: routeInfo.nodeno,
                searchType: SearchType.station,
                cityCode: widget.cityCode,
                itemId: routeInfo.routeid ?? '',
                itemName: routeInfo.routeno ?? '노선 번호 없음',
                itemSubtitle: routeInfo.routetp ?? '',
              );
              // FavoriteBloc은 context.read를 통해 접근합니다.
              context.read<FavoriteBloc>().add(ToggleFavorite(item));
            },
          );
        },
      ),
      title: Text('${routeInfo.routeno ?? '노선 번호 없음'}'), // 노선 번호
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('타입: ${routeInfo.routetp ?? '없음'}'), // 노선 타입
          // 도착 정보 표시 (arrivalInfo 사용)
          if (arrivalInfo != null)
            Text('도착 정보: ${arrivalInfo.arrtime ?? '정보 없음'}'), // 실제 도착 정보 필드 사용
          // 로딩 상태 표시 (isLoadingArrival은 더 이상 필요 없습니다. arrivalInfo 유무로 판단)
        ],
      ),
      onTap: () {
        // 노선 클릭 시 동작 (예: 해당 노선의 전체 정류소 목록 화면으로 이동)
        print('노선 클릭: ${routeInfo.routeno}');
        // TODO: 노선 클릭 시 동작 구현
      },
    );
  }

  Widget _buildRouteList(
      List<BusStopInfo> routesPassingStation,
      Map<String, BusArrivalInfo> arrivalInfoMap,
      {bool isLoadingArrival = false,}) {
    print("StationRoutesPage: _buildRouteList called. isLoadingArrival: $isLoadingArrival, arrivalInfoMap size: ${arrivalInfoMap.length}");
    print("StationRoutesPage: _buildRouteList received stops list with ${routesPassingStation.length} items.");
    return ListView.builder(
      itemCount: routesPassingStation.length,
      itemBuilder: (context, index) {
        final routeInfo =
        routesPassingStation[index]; // 이 객체는 특정 정류소를 지나는 '노선'을 BusStopInfo 형태로 표현

        // 해당 노선의 routeid를 사용하여 도착 정보 맵에서 도착 정보 찾기
        final String? routeId =
            routeInfo.routeid; // BusStopInfo 모델에 routeid 필드가 있다고 가정
        final BusArrivalInfo? arrivalInfo =
        routeId != null ? arrivalInfoMap[routeId] : null;

        // 도착 예정 시간 및 남은 정거장 수 포맷팅
        String arrivalText = '도착 정보 없음';
        if (isLoadingArrival) {
          arrivalText = '도착 정보 로딩 중...'; // 로딩 중 메시지
        } else if (arrivalInfo != null) {
          // 초 단위를 분과 초로 변환
          final int totalSeconds = arrivalInfo.arrtime ?? 0;
          final int minutes = totalSeconds ~/ 60;
          final int seconds = totalSeconds % 60;
          final int remainingStops = arrivalInfo.arrprevstationcnt ?? 0;

          // API 응답에 따라 '곧 도착' 또는 '운행 종료' 등의 상태를 추가로 처리할 수 있습니다.
          // 여기서는 간단하게 시간과 남은 정거장 수를 표시합니다.
          if (totalSeconds == 0 && remainingStops == 0) {
            arrivalText = '도착 정보 없음'; // 또는 '운행 종료' 등 API 스펙에 맞게
          } else {
            arrivalText = '${minutes}분 ${seconds}초 (${remainingStops}번째 전)';
          }
        }

        return ListTile(
          leading: BlocSelector<FavoriteBloc, FavoriteState, bool>(
            selector: (state) {
              final item = RecentSearchItem(
                routetp: routeInfo.routetp ?? '',
                nodeno: '',
                searchType: SearchType.station,
                cityCode: widget.cityCode,
                itemId: routeInfo.routeid ?? '',
                itemName: routeInfo.routeno ?? '노선 정보 없음',
                itemSubtitle: widget.nodeName,
              );
              print('BlocSelector selector called');
              return state.favoriteItems.contains(item);
            },
            builder: (context, isFavorite) {
              return IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  isFavorite
                      ? Icons.star
                      : Icons
                      .star_border,
                  color:
                  isFavorite
                      ? Color.fromARGB(255, 254, 224, 41)
                      : null,
                  size: 30.0,
                ),
                onPressed: () {
                  final item = RecentSearchItem(
                    routetp: '',
                    nodeno: routeInfo.nodeno ?? '',
                    searchType: SearchType.station,
                    cityCode: widget.cityCode,
                    itemId: routeInfo.nodeid ?? '',
                    itemName: routeInfo.nodenm ?? '노선 정보 없음',
                    itemSubtitle: '',
                  );
                  context.read<FavoriteBloc>().add(ToggleFavorite(item));
                },
              );
            },
          ),
          // BusStopInfo 필드를 사용하여 노선 정보 표시 (API 응답에 routenm, routetp, companyNm 등이 포함된다고 가정)
          title: Text('${routeInfo.routeno ?? '노선 번호 없음'}'),
          // 노선 번호 (BusStopInfo 필드)
          subtitle: Text('${routeInfo.routetp ?? '유형 없음'}'),
          // 노선 유형, 회사 이름 (BusStopInfo 필드)
          // ********** trailing 위젯에 도착 정보 표시 **********
          trailing:
          isLoadingArrival
              ? const SizedBox(
            // 로딩 중일 때 작은 로딩 индикатор
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(arrivalText),
          // 로딩 완료 시 포맷팅된 도착 정보 텍스트 표시
          onTap: () {
            // TODO: Handle tap on a route item (e.g., navigate to RouteStopsPage for this route)
            print(
              'Route tapped: ${routeInfo.routeno} (ID: ${routeInfo.routeid})',
            );
            // Navigator.push(context, MaterialPageRoute(builder: (context) => RouteStopsPage(cityCode: widget.cityCode, routeId: routeInfo.routeid ?? '', routeName: routeInfo.routenm ?? '')));
          },
        );
      },
    );
  }
}

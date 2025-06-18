import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_state.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_bloc.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_event.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_state.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/data/models/bus_route_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/views/bus_route_map.dart';
import 'package:flutter_project/src/views/by_location_station.dart';


void _navigateToBusRouteMapByStop(
  BuildContext context,
  String cityCode,
  String nodeNo,
  String routeId,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => BlocProvider<BusRouteBloc>(
            // BLoCProvider로 감싸서 제공
            create: (context) => getIt<BusRouteBloc>(),
            child: BusRouteMapScreen(
              cityCode: cityCode,
              routeId: routeId,
              nodeNo: nodeNo,
            ),
          ),
    ),
  );
}

class StationArrivalBus extends StatefulWidget {
  final String cityCode;
  final String routeId;
  final dynamic routeno;

  const StationArrivalBus({
    Key? key,
    required this.cityCode,
    required this.routeId,
    required this.routeno,
  }) : super(key: key);

  @override
  State<StationArrivalBus> createState() => _StationArrivalBusState();
}

class _StationArrivalBusState extends State<StationArrivalBus> {
  late final RouteStopsBloc _routeStopsBloc;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("RouteStopsPage initState");
    // GetIt에서 RouteStopsBloc 인스턴스 가져오기
    try {
      _routeStopsBloc = getIt<RouteStopsBloc>();
      print("RouteStopsBloc instance obtained from GetIt.");
      // BLoC에 데이터 로드 이벤트 전달
      _routeStopsBloc.add(
        LoadRouteStops(cityCode: widget.cityCode, routeId: widget.routeId),
      );
      print("LoadRouteStops event dispatched.");
    } catch (e) {
      print("Error obtaining RouteStopsBloc from GetIt: $e");
      // GetIt 설정 오류 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('앱 초기 설정 오류: 노선 정보 조회를 할 수 없습니다.')),
        );
      }
      // 오류 상태를 수동으로 emit (선택 사항)
      // _routeStopsBloc.emit(RouteStopsError(message: 'Failed to initialize BLoC'));
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
    print("RouteStopsPage dispose");
    _scrollController.dispose();
    _routeStopsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building RouteStopsPage");
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.routeno} 버스'), // 노선 이름으로 제목 표시
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.3),
            child: FloatingActionButton(
              heroTag: "fab4",
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _scrollToTop();
              },
            ),
          ),
          Align(
            alignment: Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.15),
            child: FloatingActionButton(
              heroTag: "fab5",
              child: Icon(Icons.map),
              onPressed: () {
                _navigateToBusRouteMapByStop(
                  context,
                  widget.cityCode,
                  widget.routeno,
                  widget.routeId,
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "fab6",
              child: Icon(Icons.refresh),
              onPressed: () {
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        // ScrollController를 CustomScrollView에 연결합니다.
        controller: _scrollController,
        slivers: <Widget>[
          // 상단 정보 부분을 SliverToBoxAdapter로 감싸서 Sliver로 만듭니다.
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '버스: ${widget.routeno}', // 정류소 이름 표시
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '버스 ID: ${widget.routeId}', // 정류소 ID 표시
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // 지도 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        _navigateToBusRouteMapByStop(
                          context,
                          widget.cityCode,
                          widget.routeno.toString(),
                          widget.routeId,
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('지도 보기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 구분선도 SliverToBoxAdapter로 감싸서 Sliver로 만듭니다.
          SliverToBoxAdapter(
            child: const Divider(height: 1),
          ),

          // BLoC Builder 안에서 SliverList를 반환하도록 수정합니다.
          BlocBuilder<RouteStopsBloc, RouteStopsState>(
            bloc: _routeStopsBloc, // 사용할 BLoC 인스턴스 지정
            builder: (context, state) {
              if (state is RouteStopsLoading) {
                // 로딩 중일 때는 SliverFillRemaining을 사용하여 남은 공간을 채웁니다.
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is RouteStopsLoaded) {
                // 데이터 로드 완료 시 정류소 목록을 SliverList로 표시
                final List<BusStopInfo> stops = state.stops;
                if (stops.isEmpty) {
                  // 데이터가 없을 때도 SliverFillRemaining 사용
                  return const SliverFillRemaining(
                    child: Center(child: Text('경유 정류소 정보가 없습니다.')),
                  );
                }
                // 스크롤 가능한 리스트 (SliverList)
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final stop = stops[index];
                      // 각 정류소를 ListTile로 표시
                      return ListTile(
                        trailing:
                        // IconButton(onPressed: (){}, icon: Icon(Icons.star_border)),
                        BlocSelector<FavoriteBloc, FavoriteState, bool>(
                          selector: (state) {
                            // FavoriteBloc의 상태에서 현재 정류소가 즐겨찾기인지 확인
                            final item = RecentSearchItem(
                              routetp: '', // 필요에 따라 적절한 값 설정
                              nodeno: stop.nodeno,
                              searchType: SearchType.bus, // 정류소는 SearchType.stop이 더 적절할 수 있습니다. 확인 필요.
                              cityCode: widget.cityCode,
                              itemId: stop.nodeid ?? '',
                              itemName: stop.nodenm ?? '노선 정보 없음',
                              itemSubtitle: '', // 필요에 따라 적절한 값 설정
                            );
                            // print('BlocSelector selector called for ${item.itemName}'); // 디버깅용
                            return state.favoriteItems.contains(item);
                          },
                          builder: (context, isFavorite) {
                            return IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Icon(
                                isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color:
                                isFavorite
                                    ? const Color.fromARGB(255, 254, 224, 41)
                                    : null,
                                size: 30.0,
                              ),
                              onPressed: () {
                                final item = RecentSearchItem(
                                  routetp: '', // 필요에 따라 적절한 값 설정
                                  nodeno: stop.nodeno,
                                  searchType: SearchType.bus, // 정류소는 SearchType.stop이 더 적절할 수 있습니다. 확인 필요.
                                  cityCode: widget.cityCode,
                                  itemId: stop.nodeid ?? '',
                                  itemName: stop.nodenm ?? '노선 정보 없음',
                                  itemSubtitle: '', // 필요에 따라 적절한 값 설정
                                );
                                context.read<FavoriteBloc>().add(ToggleFavorite(item));
                              },
                            );
                          },
                        ),
                        title: Text(stop.nodenm ?? '정류소 이름 없음'), // 정류소 이름
                        subtitle: Text(
                          'ID: ${stop.nodeid ?? '없음'} | nodeNo ${stop.nodeno ?? '없음'}',
                        ), // 정류소 ID (선택 사항)
                      );
                    },
                    childCount: stops.length, // 리스트 아이템 개수 지정
                  ),
                );
              } else if (state is RouteStopsError) {
                // 에러 발생 시 SliverFillRemaining 사용
                return SliverFillRemaining(
                  child: Center(child: Text('정류소 정보를 불러오는데 실패했습니다: ${state.message}')),
                );
              }
              // 초기 상태 또는 알 수 없는 상태 처리
              return const SliverFillRemaining(
                child: Center(child: Text('정류소 정보를 로드 중입니다.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

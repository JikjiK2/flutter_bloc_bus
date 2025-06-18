import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_state.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_bloc.dart';
import 'package:flutter_project/src/core/service_locator.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/utils/constants.dart' as AppConstantsFile;
import 'package:flutter_project/src/views/station_arrival_bus.dart';
import 'package:flutter_project/src/views/station_routes_screen.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance; // 또는 GetIt.I
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
// 예시: 검색 결과 또는 목록에 표시되는 단일 항목 위젯
class SearchResultItemWidget extends StatelessWidget {
  // 이 위젯이 표시하는 항목 정보 (RecentSearchItem과 동일한 구조를 가진다고 가정)
  // 실제 앱에서는 API 응답 모델을 사용할 것이므로, 해당 모델을 RecentSearchItem으로 변환하는 로직이 필요합니다.
  final RecentSearchItem item;

  const SearchResultItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // BlocSelector를 사용하여 FavoriteBloc의 favoriteItems 목록만 감시
    // bloc 속성에 get_it으로 가져온 FavoriteBloc 싱글톤 인스턴스를 직접 전달합니다.
    return BlocSelector<FavoriteBloc, FavoriteState, bool>(
      bloc: locator<FavoriteBloc>(), // 또는 GetIt.I<FavoriteBloc>()
      selector: (state) {
        // FavoriteBloc 상태의 favoriteItems 리스트에 현재 항목(item)이 포함되어 있는지 여부를 반환
        // RecentSearchItem 모델에 Equatable이 구현되어 있으므로 객체 내용 기반 비교가 가능합니다.
        return state.favoriteItems.contains(item);
      },
      builder: (context, isFavorite) {
        // isFavorite 값에 따라 UI (예: ListTile, Card 등)를 구성합니다.
        return ListTile(
          leading: Icon(item.searchType == SearchType.bus ? Icons.directions_bus : Icons.location_on),
          title: Text(item.itemName.toString()), // itemName이 dynamic이므로 toString()
          subtitle: Text('${item.cityCode} | ${item.itemSubtitle ?? ''}'),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border, // 즐겨찾기 여부에 따라 아이콘 변경
              color: isFavorite ? Colors.red : null, // 즐겨찾기 시 빨간색
            ),
            onPressed: () {
              // 버튼 클릭 시 ToggleFavorite 이벤트를 get_it으로 가져온 FavoriteBloc 인스턴스에 전달
              locator<FavoriteBloc>().add(ToggleFavorite(item)); // 또는 GetIt.I<FavoriteBloc>().add(...)
            },
          ),
          onTap: () {
            // TODO: 항목 클릭 시 상세 화면 이동 또는 검색 실행 로직
            print('Item tapped: ${item.itemName}');
          },
        );
      },
    );
  }
}

// 예시: 즐겨찾기 목록 화면 (FavoriteScreen)
// 이 화면에서는 FavoriteBloc의 favoriteItems 리스트 전체를 가져와서 표시합니다.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final Map<String, bool> _regionExpandedState = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 즐겨찾기'),
      ),
      // BlocBuilder를 사용하여 FavoriteBloc의 상태 변화를 감시
      // bloc 속성에 get_it으로 가져온 FavoriteBloc 싱글톤 인스턴스를 직접 전달합니다.
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        bloc: locator<FavoriteBloc>(), // 또는 GetIt.I<FavoriteBloc>()
        builder: (context, state) {
          // 상태에 따른 UI 표시
          if (state.status == FavoriteStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == FavoriteStatus.error) {
            return Center(child: Text('오류: ${state.errorMessage ?? "알 수 없는 오류"}'));
          } else if (state.status == FavoriteStatus.loaded) {
            // 즐겨찾기 목록이 비어있는지 확인
            if (state.favoriteItems.isEmpty) {
              return const Center(child: Text('아직 즐겨찾기한 항목이 없습니다.'));
            }

            final Map<String, List<RecentSearchItem>> groupedItems = {};
            for (var item in state.favoriteItems) {
              // 해당 cityCode의 리스트가 없으면 새로 생성합니다.
              if (!groupedItems.containsKey(item.cityCode)) {
                groupedItems[item.cityCode] = [];
              }
              // 해당 cityCode의 리스트에 현재 항목을 추가합니다.
              groupedItems[item.cityCode]!.add(item);
            }
            final List<String> sortedCityCodes = groupedItems.keys.toList()..sort();

            return ListView(
              children: sortedCityCodes.expand((cityCode) {
                String? regionName =
                AppConstantsFile
                    .AppConstants
                    .supportedCitiesStringKey[cityCode];
                if (regionName != null) {
                  regionName = AppConstantsFile.AppConstants.removeRegionMap(
                    regionName,
                  );
                }
                final List<Widget> sectionWidgets = [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      // TODO: cityCode를 실제 지역 이름으로 변환하는 로직 필요
                      // 예: getCityName(cityCode) 함수 사용
                      '$regionName', // 임시로 cityCode를 표시
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1), // 섹션 구분선
                ];

                // 해당 지역에 속한 즐겨찾기 항목들
                final List<RecentSearchItem> itemsInCity = groupedItems[cityCode]!;

                sectionWidgets.addAll(
                  itemsInCity.map((item) {
                    // 즐겨찾기 목록 화면에서는 이미 즐겨찾기된 항목만 표시하므로,
                    // isFavorite 상태를 별도로 확인할 필요 없이 항상 즐겨찾기 아이콘을 표시하고
                    // 클릭 시 삭제 이벤트를 발생시킵니다.

                    if(item.searchType == SearchType.bus) {
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(item.itemName.toString()),
                        subtitle: Text('${item.itemId ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.star, color: Color.fromARGB(255, 254, 224, 41), size: 30.0,), // 즐겨찾기된 상태 아이콘
                          onPressed: () {
                            // 삭제 버튼 클릭 시 ToggleFavorite 이벤트 발생
                            locator<FavoriteBloc>().add(ToggleFavorite(item)); // 또는 GetIt.I<FavoriteBloc>().add(...)
                          },
                        ),
                        onTap: () {
                          // TODO: 항목 클릭 시 상세 화면 이동 또는 검색 실행 로직
                          print('Favorite bus item tapped: ${item.itemName}');
                          _navigateToStationRoutes(
                            context,
                            item.cityCode,
                            item.itemId ?? '',
                            item.itemName ?? '정류소 정보 없음',
                          );
                        },
                      );
                    } else if(item.searchType == SearchType.station) {
                      // 정류장 타입 항목에 대한 ListTile
                      return ListTile(
                        leading: const Icon(Icons.directions_bus), // TODO: 정류장 아이콘으로 변경 고려 (Icons.location_on)
                        title: Text('${item.itemName} | ${item.itemSubtitle ?? ''}'), // itemSubtitle이 null일 수 있으므로 ?? '' 추가
                        subtitle: Text('${item.itemId ?? ''} | ${item.routetp ?? ''}'), // routetp가 null일 수 있으므로 ?? '' 추가
                        trailing: IconButton(
                          icon: const Icon(Icons.star, color: Color.fromARGB(255, 254, 224, 41), size: 30.0,), // 즐겨찾기된 상태 아이콘
                          onPressed: () {
                            // 삭제 버튼 클릭 시 ToggleFavorite 이벤트 발생
                            locator<FavoriteBloc>().add(ToggleFavorite(item)); // 또는 GetIt.I<FavoriteBloc>().add(...)
                          },
                        ),
                        onTap: () {
                          // TODO: 항목 클릭 시 상세 화면 이동 또는 검색 실행 로직
                          print('Favorite station item tapped: ${item.itemName}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StationArrivalBus(
                                cityCode: item.cityCode,
                                routeId: item.itemId ?? '',
                                routeno: item.itemName ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    }
                    // 알 수 없는 타입의 항목은 표시하지 않거나 기본 위젯 반환
                    return Container(); // 또는 다른 기본 위젯
                  }).toList(),
                );

                // 각 지역 섹션의 끝에 구분선 추가 (선택 사항)
                // sectionWidgets.add(const Divider(height: 16, color: Colors.grey));

                return sectionWidgets; // 해당 지역의 모든 위젯 리스트 반환
              }).toList(), // 모든 지역 섹션의 위젯들을 하나의 리스트로 합침
            );
          }
          // 초기 상태
          return const Center(child: Text('즐겨찾기 목록 로딩 중...'));
        },
      ),
    );
  }

}






























/*
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoriteBloc _favoriteBloc;

  @override
  void initState() {
    super.initState();

    try {
      _favoriteBloc = getIt<FavoriteBloc>();
      print("FavoriteBloc instance obtained from BlocProvider.");
    } catch (e) {
      print("Error obtaining FavoriteBloc from BlocProvider: $e");

    }
  }

  @override
  void dispose() {
    _favoriteBloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("즐겨찾기"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                bloc: _favoriteBloc,
                builder: (context, state) {
                  print("Favorites: BlocBuilder state: ${state.favorites}");
                  if (state is FavoriteLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FavoriteError) {
                    return Center(child: Text('오류: ${state.message ?? "알 수 없는 오류"}'));
                  } else if (state is FavoriteLoaded) {
                    // 즐겨찾기 정류장과 버스 목록을 모두 표시
                    if (state.favorites.isEmpty) {
                      return const Center(child: Text('아직 즐겨찾기한 항목이 없습니다.'));
                    }

                    return ListView(
                      children: [
                        // 즐겨찾기 정류장 목록
                        if (state.favorites.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('즐겨찾기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...state.favorites.map((stop) => ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(stop.itemName),
                            subtitle: Text('${stop.cityCode} ${stop.itemId}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                              },
                            ),
                            onTap: () {
                              // TODO: 정류장 상세 화면으로 이동하는 로직 추가
                            },
                          )).toList(),
                        ],
                      ],
                    );
                  }
                  return Center(child: const Text('즐겨찾기 목록 로딩 중...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

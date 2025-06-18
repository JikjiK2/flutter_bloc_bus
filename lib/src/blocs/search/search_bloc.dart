// lib/src/blocs/search/search_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_state.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:rxdart/rxdart.dart'; // debounceTime 사용
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/blocs/search/search_state.dart';
import 'package:flutter_project/src/data/bus_repository.dart'; // BusRepository import
import 'package:flutter_project/src/blocs/city/city_bloc.dart'; // CityBloc import
import 'package:flutter_project/src/data/models/bus_route_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BusRepository busRepository;
  final CityBloc cityBloc; // CityBloc 주입
  late StreamSubscription _cityBlocSubscription;

  SearchBloc({required this.busRepository, required this.cityBloc})
      : super(const SearchInitial()) {
    on<RemoveRecentSearchItem>(_onRemoveRecentSearchItem);
    on<AddRecentSearchItem>(_onAddRecentSearchItem);
    // on<ClearSearchQuery>(_onClearSearchQuery);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(seconds: 1)) // 300ms 디바운싱
          .distinct((prev, curr) => prev.query == curr.query && prev.searchType == curr.searchType && prev.selectedCityCodes == curr.selectedCityCodes) // 동일 검색어/타입 중복 방지
          .switchMap(mapper), // 이전 검색 취소 및 최신 검색 실행
    );

    on<InitialRecentSearchesLoaded>((event, emit) { // <--- 핸들러 등록
      print("SearchBloc: Received _InitialRecentSearchesLoaded event.");
      emit(state.copyWith(recentSearches: event.recentSearches));
      print("SearchBloc: State updated with initial recent searches.");
    });

    _cityBlocSubscription = cityBloc.stream.listen((cityState) {
      print("SearchBloc: Received CityBloc state change: ${cityState.runtimeType}");
      // CityBloc 상태가 CitySelected이고, 선택된 도시 코드가 비어있지 않으며,
      // 현재 SearchBloc 상태의 선택된 도시 코드와 다를 경우 검색 다시 실행
      if (cityState is CitySelected &&
          cityState.selectedCityCodes.isNotEmpty &&
          state.selectedCityCodes != cityState.selectedCityCodes) { // 선택된 도시 코드가 변경되었는지 확인
        print("SearchBloc: Selected city codes changed. Triggering search.");
        // 현재 검색어와 새로운 도시 코드 목록으로 SearchQueryChanged 이벤트 전달
        add(SearchQueryChanged(
          query: state.currentQuery, // 현재 검색어 사용
          searchType: state.currentSearchType,
          selectedCityCodes: cityState.selectedCityCodes,
        ));
      } else if (cityState is CitySelected && cityState.selectedCityCodes.isEmpty && state.selectedCityCodes.isNotEmpty) {
        // 선택된 도시가 모두 해제된 경우 (검색 결과 초기화)
        print("SearchBloc: All cities deselected. Clearing search results.");
        emit(SearchInitial(currentQuery: state.currentQuery, currentSearchType: state.currentSearchType, selectedCityCodes: cityState.selectedCityCodes, recentSearches: state.recentSearches));
      }
    });
    _loadInitialRecentSearches();
  }
  @override
  Future<void> close() {
    _cityBlocSubscription.cancel(); // 구독 해제
    print("SearchBloc: CityBloc subscription cancelled.");
    return super.close();
  }

  Future<void> _loadInitialRecentSearches() async {
    print("SearchBloc: Loading initial recent searches.");
    try {
      final List<RecentSearchItem> loadedSearches = await busRepository.loadRecentSearches();
      print("SearchBloc: Loaded ${loadedSearches.length} recent searches.");
      // 초기 상태를 로드된 최근 검색 목록으로 업데이트
      add(InitialRecentSearchesLoaded(recentSearches: loadedSearches)); // <--- 내부 이벤트 전달
      print("SearchBloc: Dispatched _InitialRecentSearchesLoaded event.");
    } catch (e) {
      print("SearchBloc: Error loading initial recent searches: $e");
      add(InitialRecentSearchesLoaded(recentSearches: [])); // <--- 내부 이벤트 전달
    }
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    // <--- async 유지
    final String query = event.query.toLowerCase();
    final SearchType searchType = event.searchType;

    final cityState = cityBloc.state;
    final List<String> selectedCityCodes = cityState.selectedCityCodes;

    if (query.isEmpty && selectedCityCodes.isEmpty) {
      emit(SearchInitial(currentQuery: query, currentSearchType: searchType, recentSearches: state.recentSearches));
      return;
    }
    if (query.isEmpty && selectedCityCodes.isNotEmpty) {
      emit(SearchLoaded(busResults: {},
          stationResults: {},
          currentQuery: query,
          currentSearchType: searchType,
          selectedCityCodes: selectedCityCodes
          , recentSearches: state.recentSearches));
      return;
    }
    emit(SearchLoading(currentQuery: query,
        currentSearchType: searchType,
        selectedCityCodes: selectedCityCodes,
    recentSearches: state.recentSearches)); // 로딩 상태

    try {
      // 각 지역별 검색 스트림을 합치는 로직이 필요합니다.
      // 여기서는 각 지역별 검색 스트림을 병렬로 실행하고 결과를 합치는 예시를 보여줍니다.
      List<Stream<MapEntry<String, List<BusRouteInfo>>>> busGroupedStreams = [];
      List<Stream<MapEntry<String, List<BusStopInfo>>>> stationGroupedStreams = [];

      for (final cityCode in selectedCityCodes) {
        print(
            "SearchBloc: Creating search stream for '$query' in city $cityCode for type $searchType");
        if (searchType == SearchType.bus) {
          // Repository 메서드가 Stream<List<BusRouteInfo>>를 반환
          final stream = busRepository.getSelectedAllRouteList(
              cityCode, query) // 예시 호출
              .map((results) =>
              MapEntry(cityCode, results)) // <--- MapEntry로 변환
              .doOnError((error, stacktrace) { // 개별 스트림 에러 로깅
            print("SearchBloc: Stream error for city $cityCode (Bus): $error");
          })
              .onErrorReturn(
              MapEntry(cityCode, [])); // 에러 발생 시 해당 지역은 빈 리스트로 처리

          busGroupedStreams.add(stream); // 예시 호출 (routeId 대신 query 사용?)

        } else if (searchType == SearchType.station) {
          final stream = busRepository.getAllStationsByNumber(
              cityCode, query) // 예시 호출
              .map((results) =>
              MapEntry(cityCode, results)) // <--- MapEntry로 변환
              .doOnError((error, stacktrace) { // 개별 스트림 에러 로깅
            print(
                "SearchBloc: Stream error for city $cityCode (Station): $error");
          })
              .onErrorReturn(
              MapEntry(cityCode, [])); // 에러 발생 시 해당 지역은 빈 리스트로 처리

          stationGroupedStreams.add(stream); // 예시 호출 (nodeNm 대신 query 사용?)
        }
      }
      // ********** 모든 지역별 검색 스트림을 합치고 결과를 처리 **********
      if (searchType == SearchType.bus) {
        // 모든 버스 검색 스트림을 합치고, 각 스트림에서 내보내는 List<BusRouteInfo>들을 하나의 List<BusRouteInfo>로 합칩니다.
        // combineLatestList 연산자는 모든 스트림이 최소 한 번 이상 값을 내보낼 때마다 각 스트림의 최신 값들을 리스트로 묶어 내보냅니다.
        // 여기서는 각 스트림이 단 하나의 List<BusRouteInfo>만 내보내므로, 모든 스트림이 완료되면 최종 결과 리스트가 한 번 내보내집니다.
        await Rx.combineLatestList(busGroupedStreams).listen((listOfEntries) {
          final Map<String, List<BusRouteInfo>> groupedResults = {};
          for (final entry in listOfEntries) {
            groupedResults[entry.key] =
                entry.value; // cityCode를 키로, 결과 리스트를 값으로 저장
          }
          // 합쳐진 결과로 상태 업데이트
          emit(SearchLoaded(
            busResults: groupedResults,
            stationResults: {},
            // 정류장 결과는 비어있음
            currentQuery: query,
            currentSearchType: searchType,
            selectedCityCodes: selectedCityCodes,
            recentSearches: state.recentSearches,
          ));
        }, onError: (error, stacktrace) {
          // 스트림 처리 중 에러 발생 시
          print("SearchBloc: Stream error during bus search: $error");
          emit(SearchError(message: error.toString(),
              currentQuery: query,
              currentSearchType: searchType,
              selectedCityCodes: selectedCityCodes,
              recentSearches: state.recentSearches,
          ));
        }).asFuture(); // listen의 완료를 기다리기 위해 asFuture 사용

      } else if (searchType == SearchType.station) {
        // 모든 정류장 검색 스트림을 합치고 결과를 처리 (버스 검색과 동일)
        await Rx.combineLatestList(stationGroupedStreams).listen((
            listOfEntries) {
          final Map<String, List<BusStopInfo>> groupedResults = {};
          for (final entry in listOfEntries) {
            groupedResults[entry.key] = entry.value;
          }
          emit(SearchLoaded(
            busResults: {},
            // 버스 결과는 비어있음
            stationResults: groupedResults,
            currentQuery: query,
            currentSearchType: searchType,
            selectedCityCodes: selectedCityCodes,
            recentSearches: state.recentSearches,
          ));
        }, onError: (error, stacktrace) {
          print("SearchBloc: Stream error during station search: $error");
          emit(SearchError(message: error.toString(),
              currentQuery: query,
              currentSearchType: searchType,
              selectedCityCodes: selectedCityCodes));
        }).asFuture();
      } else if (searchType == SearchType.station) {
        // 모든 정류장 검색 스트림을 합치고 결과를 처리 (버스 검색과 동일)
        await Rx.combineLatestList(stationGroupedStreams).listen((
            listOfEntries) {
          final Map<String, List<BusStopInfo>> groupedResults = {};
          for (final entry in listOfEntries) {
            groupedResults[entry.key] = entry.value;
          }

          print(
              "SearchBloc: Combined station results into map. Cities with results: ${groupedResults
                  .keys.length}");

          emit(SearchLoaded(
            busResults: {},
            // 버스 결과는 비어있음
            stationResults: groupedResults,
            // 그룹화된 결과 맵
            currentQuery: query,
            currentSearchType: searchType,
            selectedCityCodes: selectedCityCodes,
          ));
          print(
              "SearchBloc: Emitted SearchLoaded state with grouped station results.");
        }, onError: (error, stacktrace) {
          print(
              "SearchBloc: Stream error during station search (combineLatestList): $error");
          emit(SearchError(message: error.toString(),
              currentQuery: query,
              currentSearchType: searchType,
              selectedCityCodes: selectedCityCodes));
        }).asFuture();
      }
      print("SearchBloc: _onSearchQueryChanged finished setting up streams.");
    } catch (e) {
      print("SearchBloc: Error in _onSearchQueryChanged: $e");
      emit(SearchError(message: e.toString(),
          currentQuery: query,
          currentSearchType: searchType,
          selectedCityCodes: selectedCityCodes));
    }
  }
  Future<void> _onAddRecentSearchItem(AddRecentSearchItem event, Emitter<SearchState> emit) async {
    print("SearchBloc: Received AddRecentSearchItem event for item: ${event.item.itemName}");

    // 현재 최근 검색 목록 가져오기
    final List<RecentSearchItem> currentRecentSearches = List.from(state.recentSearches); // 기존 리스트 복사

    // 추가하려는 항목과 동일한 항목이 이미 리스트에 있는지 확인
    final int existingIndex = currentRecentSearches.indexWhere(
          (item) =>
      item.searchType == event.item.searchType &&
          item.cityCode == event.item.cityCode &&
          item.itemId == event.item.itemId,
    );

    if (existingIndex != -1) {
      // 동일한 항목이 있으면 기존 항목 제거
      currentRecentSearches.removeAt(existingIndex);
      print("SearchBloc: Removed existing duplicate recent search item.");
    }

    // 새로운 항목을 리스트 맨 앞에 추가
    currentRecentSearches.insert(0, event.item);
    print("SearchBloc: Added new recent search item to the front. Total items: ${currentRecentSearches.length}");

    // 최대 개수 제한 (선택 사항, 예: 10개)
    // if (currentRecentSearches.length > 10) {
    //   currentRecentSearches = currentRecentSearches.take(10).toList();
    //   print("SearchBloc: Trimmed recent searches list to 10 items.");
    // }


    final newState = state.copyWith(recentSearches: currentRecentSearches); // <--- 새로운 상태 객체 생성
    print("SearchBloc: About to emit state with recent searches count: ${newState.recentSearches.length}"); // <--- emit 직전 로그
    emit(newState);
    print("SearchBloc: Updated state with new recent searches list.");
    await busRepository.saveRecentSearches(currentRecentSearches); // Repository 메서드 호출
    print("SearchBloc: Saved recent searches to SharedPreferences.");

  }

  Future<void> _onRemoveRecentSearchItem(RemoveRecentSearchItem event, Emitter<SearchState> emit) async {
    print("SearchBloc: Received RemoveRecentSearchItem event for item: ${event.item.itemName}");

    // 현재 최근 검색 목록 가져오기
    final List<RecentSearchItem> currentRecentSearches = List.from(state.recentSearches); // 기존 리스트 복사

    // 추가하려는 항목과 동일한 항목이 이미 리스트에 있는지 확인
    final int existingIndex = currentRecentSearches.indexWhere(
          (item) =>
      item.searchType == event.item.searchType &&
          item.cityCode == event.item.cityCode &&
          item.itemId == event.item.itemId,
    );

    if (existingIndex != -1) {
      // 동일한 항목이 있으면 기존 항목 제거
      currentRecentSearches.removeAt(existingIndex);
      print("SearchBloc: Removed existing duplicate recent search item.");
    }

    final newState = state.copyWith(recentSearches: currentRecentSearches); // <--- 새로운 상태 객체 생성
    print("SearchBloc: About to emit state with recent searches count: ${newState.recentSearches.length}"); // <--- emit 직전 로그
    emit(newState);
    print("SearchBloc: Updated state with new recent searches list.");
    await busRepository.saveRecentSearches(currentRecentSearches); // Repository 메서드 호출
    print("SearchBloc: Saved recent searches to SharedPreferences.");
  }

  // Future<void> _onClearSearchQuery(ClearSearchQuery event, Emitter<SearchState> emit) async {
  //   return emit(SearchInitial(currentQuery: ''));
  // }
}

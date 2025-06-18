class AppConstants {
  static const Map<String, String> supportedCitiesStringKey = {
    '12': '세종특별시',
    '21': '부산광역시',
    '22': '대구광역시',
    '23': '인천광역시',
    '24': '광주광역시',
    '25': '대전광역시/계룡시',
    '26': '울산광역시',
    '39': '제주도',
    '31010': '수원시',
    '31020': '성남시',
    '31030': '의정부시',
    '31040': '안양시',
    '31050': '부천시',
    '31060': '광명시',
    '31070': '평택시',
    '31080': '동두천시',
    '31090': '안산시',
    '31100': '고양시',
    '31110': '과천시',
    '31120': '구리시',
    '31130': '남양주시',
    '31140': '오산시',
    '31150': '시흥시',
    '31160': '군포시',
    '31170': '의왕시',
    '31180': '하남시',
    '31190': '용인시',
    '31200': '파주시',
    '31210': '이천시',
    '31220': '안성시',
    '31230': '김포시',
    '31240': '화성시',
    '31250': '광주시',
    '31260': '양주시',
    '31270': '포천시',
    '31320': '여주시',
    '31350': '연천군',
    '31370': '가평군',
    '31380': '양평군',
    '32010': '춘천시',
    '32020': '원주시/횡성군',
    '32050': '태백시',
    '32310': '홍천군',
    '32360': '철원군',
    '32410': '양양군',
    '33010': '청주시',
    '33020': '충주시',
    '33030': '제천시',
    '33320': '보은군',
    '33330': '옥천군',
    '33340': '영동군',
    '33350': '진천군',
    '33360': '괴산군',
    '33370': '음성군',
    '33380': '단양군',
    '33390': '당진시',
    '34010': '천안시',
    '34020': '공주시',
    '34040': '아산시',
    '34050': '서산시',
    '34060': '논산시',
    '34070': '계룡시',
    '34330': '부여군',
    '34390': '당진시',
    '35010': '전주시',
    '35020': '군산시',
    '35040': '정읍시',
    '35050': '남원시',
    '35060': '김제시',
    '35320': '진안군',
    '35330': '무주군',
    '35340': '장수군',
    '35350': '임실군',
    '35360': '순창군',
    '35370': '고창군',
    '35380': '부안군',
    '36010': '목포시',
    '36020': '여수시',
    '36030': '순천시',
    '36040': '나주시',
    '36060': '광양시',
    '36320': '곡성군',
    '36330': '구례군',
    '36350': '고흥군',
    '36380': '장흥군',
    '36400': '해남군',
    '36410': '영암군',
    '36420': '무안군',
    '36430': '함평군',
    '36450': '장성군',
    '36460': '완도군',
    '36470': '진도군',
    '36480': '신안군',
    '37010': '포항시',
    '37020': '경주시',
    '37030': '김천시',
    '37040': '안동시',
    '37050': '구미시',
    '37060': '영주시',
    '37070': '영천시',
    '37080': '상주시',
    '37090': '문경시',
    '37100': '경산시',
    '37320': '의성군',
    '37330': '청송군',
    '37340': '영양군',
    '37350': '영덕군',
    '37360': '청도군',
    '37370': '고령군',
    '37380': '성주군',
    '37390': '칠곡군',
    '37400': '예천군',
    '37410': '봉화군',
    '37420': '울진군',
    '37430': '울릉군',
    '38010': '창원시',
    '38030': '진주시',
    '38050': '통영시',
    '38060': '사천시',
    '38070': '김해시',
    '38080': '밀양시',
    '38090': '거제시',
    '38100': '양산시',
    '38310': '의령군',
    '38320': '함안군',
    '38330': '창녕군',
    '38340': '고성군',
    '38350': '남해군',
    '38360': '하동군',
    '38370': '산청군',
    '38380': '함양군',
    '38390': '거창군',
    '38400': '합천군',
  };

  static String getRegionNameByCityCode(String cityCode) {
    final int code = int.parse(cityCode); // 도시 코드를 숫자로 변환

    if (code >= 21 && code <= 26) return "특별시/광역시"; // 주요 도시
    if (code == 39) return "제주특별자치도";
    if (code >= 31000 && code < 32000) return "경기도";
    if (code >= 32000 && code < 33000) return "강원도";
    if (code == 12 || code >= 33000 && code < 35000) return "충청도"; // 33xxx 충북, 34xxx 충남/대전/세종
    if (code >= 35000 && code < 37000) return "전라도"; // 35xxx 전북, 36xxx 전남/광주
    if (code >= 37000 && code < 39000) return "경상도"; // 37xxx 경북/대구, 38xxx 경남/부산/울산

    return "기타"; // 위에 해당하지 않는 경우
  }

  static String removeRegionMap(String regionName) {
    const List<String> suffixesToRemove = ['광역시', '특별시', '시', '군', '도']; // 필요한 명칭 추가/수정
      String cityName = regionName; // 현재 도시 이름

      // ********** 도시 이름에서 행정 구역 명칭 삭제 로직 추가 **********
      for (final suffix in suffixesToRemove) {
        if (cityName.endsWith(suffix)) { // 도시 이름이 해당 명칭으로 끝나면
          cityName = cityName.substring(0, cityName.length - suffix.length); // 해당 명칭 삭제
          break; // 첫 번째 일치하는 명칭만 삭제하고 종료 (예: '세종특별시'에서 '특별시'만 삭제)
        }
      }
      if (cityName.contains('광역시/')) {
        cityName = cityName.replaceAll('광역시/', '/');
      }
      // '원주시/횡성군'과 같이 특별히 처리해야 할 경우 추가 로직
      if (cityName.contains('/')) {
        // 예: '원주시/횡성군' -> '원주/횡성'으로 만들고 싶다면
        cityName = cityName.replaceAll('시/', '/').replaceAll('군', ''); // 예시: '시/' 제거, '군' 제거
        // 또는 더 복잡한 패턴 매칭 사용
      }
    return cityName;
  }

// 지역별로 그룹화하고 도시 이름을 한글 순서로 정렬하는 함수
  static Map<String, List<MapEntry<String, String>>> getGroupedAndSortedCities() {
    final Map<String, List<MapEntry<String, String>>> groupedCities = {};

    // 삭제할 행정 구역 명칭 목록
    const List<String> suffixesToRemove = ['광역시', '특별시', '시', '군', '도']; // 필요한 명칭 추가/수정

    // 전체 도시 목록을 순회하며 그룹화
    for (final entry in supportedCitiesStringKey.entries) {
      final String cityCode = entry.key;
      String cityName = entry.value; // 현재 도시 이름

      // ********** 도시 이름에서 행정 구역 명칭 삭제 로직 추가 **********
      for (final suffix in suffixesToRemove) {
        if (cityName.endsWith(suffix)) { // 도시 이름이 해당 명칭으로 끝나면
          cityName = cityName.substring(0, cityName.length - suffix.length); // 해당 명칭 삭제
          break; // 첫 번째 일치하는 명칭만 삭제하고 종료 (예: '세종특별시'에서 '특별시'만 삭제)
        }
      }
      if (cityName.contains('광역시/')) {
        cityName = cityName.replaceAll('광역시/', '/');
      }
      // '원주시/횡성군'과 같이 특별히 처리해야 할 경우 추가 로직
      if (cityName.contains('/')) {
        // 예: '원주시/횡성군' -> '원주/횡성'으로 만들고 싶다면
        cityName = cityName.replaceAll('시/', '/').replaceAll('군', ''); // 예시: '시/' 제거, '군' 제거
        // 또는 더 복잡한 패턴 매칭 사용
      }
      // '대전광역시/계룡시' -> '대전/계룡' 으로 만들고 싶다면

      final String regionName = getRegionNameByCityCode(cityCode); // 지역 그룹 이름 가져오기

      // 해당 지역 그룹의 리스트가 없으면 새로 생성
      if (!groupedCities.containsKey(regionName)) {
        groupedCities[regionName] = [];
      }

      // 수정된 도시 이름으로 새로운 MapEntry를 만들어 추가
      groupedCities[regionName]!.add(MapEntry(cityCode, cityName)); // <--- 수정된 cityName 사용
    }

    // 각 지역 그룹 내에서 도시 이름을 기준으로 정렬
    for (final regionList in groupedCities.values) {
      regionList.sort((a, b) =>
          a.value.compareTo(b.value)); // value (수정된 도시 이름) 기준으로 정렬
    }

    // 지역 그룹 이름 자체를 특정 순서로 정렬 (선택 사항)
    final List<String> sortedRegionNames = groupedCities.keys.toList();
    sortedRegionNames.sort((a, b) => a.compareTo(b)); // 가나다순 정렬 예시

    final Map<String, List<MapEntry<String, String>>> sortedGroupedCities = {};
    for (final regionName in sortedRegionNames) {
      sortedGroupedCities[regionName] = groupedCities[regionName]!;
    }

    return groupedCities;
  }
}

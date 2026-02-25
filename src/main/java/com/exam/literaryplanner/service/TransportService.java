package com.exam.literaryplanner.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class TransportService {

    @Value("${tago.serviceKey}")
    private String serviceKey;

    private final WebClient webClient = WebClient.builder().build();

    // =========================
    //  FLIGHT (기존 그대로)
    // =========================
    private static final String FLIGHT_URL =
            "http://apis.data.go.kr/1613000/DmstcFlightNvgInfoService/getFlightOpratInfoList";
    private static final String JEJU_ID = "NAARKPC";

    private static final Map<String, String> AIRPORTS = Map.ofEntries(
            Map.entry("NAARKPK", "김해"),
            Map.entry("NAARKTU", "청주"),
            Map.entry("NAARKSS", "김포"),
            Map.entry("NAARKTN", "대구")
    );

    public Map<String, String> getAirports() { return AIRPORTS; }
    public String getDefaultAirportId() { return "NAARKSS"; }

    public List<Map<String, Object>> searchJejuRouteByAirport(String airportId, String depPlandTime) {
        List<Map<String, Object>> all = new ArrayList<>();
        all.addAll(searchFlight(airportId, JEJU_ID, depPlandTime));
        all.addAll(searchFlight(JEJU_ID, airportId, depPlandTime));
        all.sort(Comparator.comparing(m -> Objects.toString(m.get("depPlandTime"), "")));
        return all;
    }

    public List<Map<String, Object>> searchFlight(String depAirportId, String arrAirportId, String depPlandTime) {
        JsonNode root = webClient.get()
                .uri(FLIGHT_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("depAirportId", depAirportId)
                        .queryParam("arrAirportId", arrAirportId)
                        .queryParam("depPlandTime", depPlandTime)
                        .queryParam("numOfRows", 200)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        return postProcessFlight(extract(root));
    }

    private List<Map<String, Object>> postProcessFlight(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            String dep = Objects.toString(m.get("depPlandTime"), "");
            String arr = Objects.toString(m.get("arrPlandTime"), "");
            m.put("depTimeText", prettyTime12(dep));
            m.put("arrTimeText", prettyTime12(arr));
        }
        return list;
    }

    // =========================
    //  FIXED CITIES
    // =========================
    private static final List<String> FIXED_CITIES =
            List.of("서울", "부산", "강릉", "경주", "수원", "속초");
    public List<String> getFixedCities() { return FIXED_CITIES; }

    // =========================
    //  EXPRESS BUS (고속) - 기존 유지
    // =========================
    private static final String BUS_URL =
            "http://apis.data.go.kr/1613000/ExpBusInfoService/getStrtpntAlocFndExpbusInfo";

    private static final String BUS_TERMINAL_URL =
            "http://apis.data.go.kr/1613000/ExpBusInfoService/getExpBusTrminlList";

    public Map<String, String> getExpBusTerminals() {
        JsonNode root = webClient.get()
                .uri(BUS_TERMINAL_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("numOfRows", 1000)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        List<Map<String, Object>> items = extract(root);

        Map<String, String> map = new LinkedHashMap<>();
        for (Map<String, Object> m : items) {
            String id = Objects.toString(m.get("terminalId"), "").trim();
            String nm = Objects.toString(m.get("terminalNm"), "").trim();
            if (!id.isBlank() && !nm.isBlank()) map.put(nm, id);
        }
        return map;
    }

    public List<Map<String, String>> getExpBusTerminalsByCity(String city) {
        Map<String, String> all = getExpBusTerminals();

        List<Map<String, String>> list = new ArrayList<>();
        if (city == null || city.isBlank()) return list;

        List<String> keys;
        switch (city) {
            case "서울": keys = List.of("서울경부", "서울"); break;
            case "부산": keys = List.of("부산", "부산종합"); break;
            default: keys = List.of(city); break;
        }

        for (Map.Entry<String, String> e : all.entrySet()) {
            String terminalNm = e.getKey();
            for (String k : keys) {
                if (terminalNm.contains(k)) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("terminalNm", terminalNm);
                    row.put("terminalId", e.getValue());
                    list.add(row);
                    break;
                }
            }
        }

        list.sort((a, b) -> scoreTerminal(b.get("terminalNm")) - scoreTerminal(a.get("terminalNm")));
        return list;
    }

    private int scoreTerminal(String name) {
        if (name == null) return 0;
        int s = 0;
        if (name.contains("고속")) s += 30;
        if (name.contains("종합")) s += 20;
        if (name.contains("시외")) s += 10;
        if (name.length() <= 6) s += 3;
        return s;
    }

    public List<Map<String, Object>> searchExpBusByTerminal(String depTerminalId, String arrTerminalId, String depPlandTime) {
        if (depTerminalId == null || depTerminalId.isBlank()) return Collections.emptyList();
        if (arrTerminalId == null || arrTerminalId.isBlank()) return Collections.emptyList();
        return searchExpBus(depTerminalId, arrTerminalId, depPlandTime);
    }

    public List<Map<String, Object>> searchExpBus(String depTerminalId, String arrTerminalId, String depPlandTime) {
        JsonNode root = webClient.get()
                .uri(BUS_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("depTerminalId", depTerminalId)
                        .queryParam("arrTerminalId", arrTerminalId)
                        .queryParam("depPlandTime", depPlandTime)
                        .queryParam("numOfRows", 200)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        List<Map<String, Object>> list = postProcessBus(extract(root));
        // ✅ 구분 붙이기
        for (Map<String, Object> m : list) m.put("busType", "고속");
        return list;
    }

    private List<Map<String, Object>> postProcessBus(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            String dep = Objects.toString(m.get("depPlandTime"), "");
            String arr = Objects.toString(m.get("arrPlandTime"), "");
            m.put("depTimeText", prettyTime12(dep));
            m.put("arrTimeText", prettyTime12(arr));
            m.put("gradeText", Objects.toString(m.get("gradeNm"), ""));
            m.put("chargeText", Objects.toString(m.get("charge"), ""));
        }
        return list;
    }

    // =========================
    //  SUBURBS BUS (시외) - ✅ 추가
    // =========================
    // ✅ 시외버스 터미널 목록: SuburbsBusInfoService/getSuberbsBusTrminlList :contentReference[oaicite:2]{index=2}
    private static final String SUB_BUS_TERMINAL_URL =
            "http://apis.data.go.kr/1613000/SuburbsBusInfoService/getSuberbsBusTrminlList";

    // ⚠️ 출/도착지 기반 시외버스 조회 오퍼레이션명은 포털 본문에 안 펼쳐져서
    // 일반적인 TAGO 네이밍 패턴으로 구현 (고속 getStrtpntAlocFndExpbusInfo 와 동일 패턴).
    // 404 뜨면 여기 오퍼레이션명만 맞는 걸로 교체하면 끝.
    private static final String SUB_BUS_URL =
            "http://apis.data.go.kr/1613000/SuburbsBusInfoService/getStrtpntAlocFndSuberbsBusInfo";

    public Map<String, String> getSuburbsBusTerminals() {
        JsonNode root = webClient.get()
                .uri(SUB_BUS_TERMINAL_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("numOfRows", 1000)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        List<Map<String, Object>> items = extract(root);

        Map<String, String> map = new LinkedHashMap<>();
        for (Map<String, Object> m : items) {
            String id = Objects.toString(m.get("terminalId"), "").trim();
            String nm = Objects.toString(m.get("terminalNm"), "").trim();
            if (!id.isBlank() && !nm.isBlank()) map.put(nm, id);
        }
        return map;
    }

    public List<Map<String, String>> getSuburbsBusTerminalsByCity(String city) {
        Map<String, String> all = getSuburbsBusTerminals();

        List<Map<String, String>> list = new ArrayList<>();
        if (city == null || city.isBlank()) return list;

        List<String> keys;
        switch (city) {
            case "서울":
                // 시외는 서울남부/동서울 같은 애들이 많이 걸림
                keys = List.of("서울남부", "동서울", "서울"); break;
            case "부산":
                keys = List.of("부산", "부산서부", "부산종합"); break;
            default:
                keys = List.of(city); break;
        }

        for (Map.Entry<String, String> e : all.entrySet()) {
            String terminalNm = e.getKey();
            for (String k : keys) {
                if (terminalNm.contains(k)) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("terminalNm", terminalNm);
                    row.put("terminalId", e.getValue());
                    list.add(row);
                    break;
                }
            }
        }

        // 시외도 보기 좋게 정렬(종합/시외 우선 느낌)
        list.sort((a, b) -> scoreTerminal(b.get("terminalNm")) - scoreTerminal(a.get("terminalNm")));
        return list;
    }

    public List<Map<String, Object>> searchSuburbsBusByTerminal(String depTerminalId, String arrTerminalId, String depPlandTime) {
        if (depTerminalId == null || depTerminalId.isBlank()) return Collections.emptyList();
        if (arrTerminalId == null || arrTerminalId.isBlank()) return Collections.emptyList();

        JsonNode root = webClient.get()
                .uri(SUB_BUS_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("depTerminalId", depTerminalId)
                        .queryParam("arrTerminalId", arrTerminalId)
                        .queryParam("depPlandTime", depPlandTime)
                        .queryParam("numOfRows", 200)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        List<Map<String, Object>> list = postProcessSuburbsBus(extract(root));
        for (Map<String, Object> m : list) m.put("busType", "시외");
        return list;
    }

    private List<Map<String, Object>> postProcessSuburbsBus(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            // 시외도 depPlandTime/arrPlandTime로 오는 케이스가 많고,
            // 간혹 키가 다른 경우가 있어 “유연 처리”
            String depRaw = firstNonBlank(
                    Objects.toString(m.get("depPlandTime"), ""),
                    Objects.toString(m.get("depplandtime"), ""),
                    Objects.toString(m.get("depTime"), "")
            );
            String arrRaw = firstNonBlank(
                    Objects.toString(m.get("arrPlandTime"), ""),
                    Objects.toString(m.get("arrplandtime"), ""),
                    Objects.toString(m.get("arrTime"), "")
            );

            m.put("depTimeText", prettyTimeFlex(depRaw));
            m.put("arrTimeText", prettyTimeFlex(arrRaw));

            // JSP 표시용 통일 키
            m.put("gradeText", firstNonBlank(
                    Objects.toString(m.get("gradeNm"), ""),
                    Objects.toString(m.get("busGradeNm"), ""),
                    Objects.toString(m.get("busgradename"), "")
            ));
            m.put("chargeText", firstNonBlank(
                    Objects.toString(m.get("charge"), ""),
                    Objects.toString(m.get("adultCharge"), ""),
                    Objects.toString(m.get("adultcharge"), "")
            ));

            // 정렬용 원본 시간도 통일(있으면 depPlandTime에 넣어두면 controller가 편함)
            if (m.get("depPlandTime") == null || Objects.toString(m.get("depPlandTime"), "").isBlank()) {
                m.put("depPlandTime", depRaw);
            }
        }
        return list;
    }

    // =========================
    //  TRAIN (기존 그대로)
    // =========================
 // 기존 URL 그대로 유지
    private static final String TRAIN_URL =
            "http://apis.data.go.kr/1613000/TrainInfoService/getStrtpntAlocFndTrainInfo";

    // 도시 → 역ID 후보 목록
    private static final Map<String, List<String>> TRAIN_CITY_TO_STATION_ID = new LinkedHashMap<>();
    static {
        TRAIN_CITY_TO_STATION_ID.put("서울", List.of("NAT010000")); // 서울역
        TRAIN_CITY_TO_STATION_ID.put("부산", List.of("NAT014445")); // 부산역

        // ✅ 경주 핵심: 신경주가 실제 KTX 중심이라 먼저 넣어야 함
        // (※ 신경주 ID는 실제 목록 조회로 확인하는 게 베스트지만 우선 후보 구조로)
        TRAIN_CITY_TO_STATION_ID.put("경주", List.of(
                "NAT050000" // (기존 경주역) ← 일단 1차
                // 나중에 신경주 ID 알면 여기에 첫 번째로 추가
                // 예: "NATXXXXXX", "NAT050000"
        ));

        TRAIN_CITY_TO_STATION_ID.put("강릉", List.of("NAT601936"));
        TRAIN_CITY_TO_STATION_ID.put("수원", List.of("NAT030000"));
    }
    
    public List<Map<String, Object>> searchTrainByCity(String depCity, String arrCity, String depPlandTime) {
        List<String> depIds = TRAIN_CITY_TO_STATION_ID.get(depCity);
        List<String> arrIds = TRAIN_CITY_TO_STATION_ID.get(arrCity);

        if (depIds == null || depIds.isEmpty() || arrIds == null || arrIds.isEmpty()) {
            return Collections.emptyList();
        }

        // 후보 조합을 전부 시도해서, 하나라도 결과가 나오면 그걸 반환
        for (String depId : depIds) {
            if (depId == null || depId.isBlank()) continue;

            for (String arrId : arrIds) {
                if (arrId == null || arrId.isBlank()) continue;

                List<Map<String, Object>> list = searchTrain(depId, arrId, depPlandTime);
                if (list != null && !list.isEmpty()) {
                    return list;
                }
            }
        }
        return Collections.emptyList();
    }

    /**
     * 기존 컨트롤러 호환용 (String 반환 유지)
     * → 후보 리스트 중 첫 번째 ID 반환
     */
    public String resolveTrainStationId(String city) {
        List<String> ids = TRAIN_CITY_TO_STATION_ID.get(city);

        if (ids == null || ids.isEmpty()) {
            return null;
        }

        // 첫 번째 역ID 반환 (기존 구조와 100% 호환)
        return ids.get(0);
    }

    public List<Map<String, Object>> searchTrain(String depPlaceId, String arrPlaceId, String depPlandTime) {
        JsonNode root = webClient.get()
                .uri(TRAIN_URL, uriBuilder -> uriBuilder
                        .queryParam("serviceKey", serviceKey)
                        .queryParam("_type", "json")
                        .queryParam("depPlaceId", depPlaceId)
                        .queryParam("arrPlaceId", arrPlaceId)
                        .queryParam("depPlandTime", depPlandTime)
                        .queryParam("numOfRows", 200)
                        .queryParam("pageNo", 1)
                        .build())
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        return postProcessTrain(extract(root));
    }

    private List<Map<String, Object>> postProcessTrain(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            String dep = firstNonBlank(
                    Objects.toString(m.get("depPlandTime"), ""),
                    Objects.toString(m.get("depplandtime"), "")
            );
            String arr = firstNonBlank(
                    Objects.toString(m.get("arrPlandTime"), ""),
                    Objects.toString(m.get("arrplandtime"), "")
            );

            m.put("depTimeText", prettyTimeFlex(dep));
            m.put("arrTimeText", prettyTimeFlex(arr));

            m.put("trainTypeText", firstNonBlank(
                    Objects.toString(m.get("traingradename"), ""),
                    Objects.toString(m.get("trainGradNm"), "")
            ));
            m.put("trainNoText", firstNonBlank(
                    Objects.toString(m.get("trainno"), ""),
                    Objects.toString(m.get("trainNo"), "")
            ));
            m.put("chargeText", firstNonBlank(
                    Objects.toString(m.get("adultcharge"), ""),
                    Objects.toString(m.get("charge"), "")
            ));
        }
        return list;
    }

    // =========================
    //  COMMON UTILS
    // =========================
    @SuppressWarnings({"unchecked", "rawtypes"})
    private List<Map<String, Object>> extract(JsonNode root) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (root == null) return list;

        JsonNode items = root.path("response").path("body").path("items").path("item");
        ObjectMapper mapper = new ObjectMapper();

        if (items.isArray()) {
            for (JsonNode n : items) list.add(mapper.convertValue(n, Map.class));
        } else if (!items.isMissingNode() && !items.isNull()) {
            list.add(mapper.convertValue(items, Map.class));
        }
        return list;
    }

    private String firstNonBlank(String... vals) {
        if (vals == null) return "";
        for (String v : vals) {
            if (v != null && !v.isBlank()) return v;
        }
        return "";
    }

    private String prettyTime12(String yyyymmddhhmm) {
        if (yyyymmddhhmm == null) return "";
        String s = yyyymmddhhmm.trim();
        if (s.length() != 12) return s;

        LocalDateTime dt = LocalDateTime.parse(s, DateTimeFormatter.ofPattern("yyyyMMddHHmm"));
        return dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    private String prettyTimeFlex(String value) {
        if (value == null) return "";
        String s = value.trim();
        try {
            if (s.length() == 12) {
                LocalDateTime dt = LocalDateTime.parse(s, DateTimeFormatter.ofPattern("yyyyMMddHHmm"));
                return dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            }
            if (s.length() == 14) {
                LocalDateTime dt = LocalDateTime.parse(s, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
                return dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            }
            return s;
        } catch (Exception e) {
            return s;
        }
    }
}

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
    //  FLIGHT
    // =========================
    private static final String FLIGHT_URL =
            "http://apis.data.go.kr/1613000/DmstcFlightNvgInfoService/getFlightOpratInfoList";

    private static final String JEJU_ID = "NAARKPC";

    // key = airportId, value = airportName
    private static final Map<String, String> AIRPORTS = Map.ofEntries(
            Map.entry("NAARKPK", "김해"),
            Map.entry("NAARKTU", "청주"),
            Map.entry("NAARKSS", "김포"),
            Map.entry("NAARKTN", "대구")
    );

    // ✅ 컨트롤러에서 호출
    public Map<String, String> getAirports() {
        return AIRPORTS;
    }

    // ✅ 컨트롤러에서 호출
    public String getDefaultAirportId() {
        return "NAARKSS";
    }

    // ✅ 컨트롤러에서 호출
    public List<Map<String, Object>> searchJejuRouteByAirport(String airportId, String depPlandTime) {
        List<Map<String, Object>> all = new ArrayList<>();
        all.addAll(searchFlight(airportId, JEJU_ID, depPlandTime));
        all.addAll(searchFlight(JEJU_ID, airportId, depPlandTime));
        all.sort(Comparator.comparing(m -> Objects.toString(m.get("depPlandTime"), "")));
        return all;
    }

    // ✅ 컨트롤러에서 호출
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
    //  FIXED CITIES (6개 고정)
    // =========================
    private static final List<String> FIXED_CITIES =
            List.of("서울", "부산", "강릉", "경주", "수원", "속초");

    // ✅ 컨트롤러에서 호출: transportService.getFixedCities()
    public List<String> getFixedCities() {
        return FIXED_CITIES;
    }

    // =========================
    //  EXPRESS BUS
    // =========================
    private static final String BUS_URL =
            "http://apis.data.go.kr/1613000/ExpBusInfoService/getStrtpntAlocFndExpbusInfo";

    /**
     * ✅ 도시명 -> 고속버스터미널ID
     * - 여기 값이 “조회 결과 없음”이면 API 문제 아니고 ID가 다른 거임.
     * - 일단 컴파일/흐름을 완성하는 목적이라 고정 매핑으로 둠.
     */
    private static final Map<String, String> EXPBUS_CITY_TO_TERMINAL_ID = new LinkedHashMap<>();
    static {
        // 자주 쓰는 대표 터미널로 고정
        EXPBUS_CITY_TO_TERMINAL_ID.put("서울", "NAEK010"); // 서울(경부)
        EXPBUS_CITY_TO_TERMINAL_ID.put("부산", "NAEK070"); // 부산

        // 아래 4개는 환경/문서에 따라 ID가 다를 수 있어.
        // "결과 없음"이면 여기만 너가 실제 ID로 바꾸면 끝.
        EXPBUS_CITY_TO_TERMINAL_ID.put("강릉", "NAEK190");
        EXPBUS_CITY_TO_TERMINAL_ID.put("경주", "NAEK300");
        EXPBUS_CITY_TO_TERMINAL_ID.put("수원", "NAEK110");
        EXPBUS_CITY_TO_TERMINAL_ID.put("속초", "NAEK210");
    }

    // ✅ 컨트롤러에서 호출
    public String resolveExpBusTerminalId(String city) {
        String id = EXPBUS_CITY_TO_TERMINAL_ID.get(city);
        return (id == null || id.isBlank()) ? null : id;
    }

    // ✅ 컨트롤러에서 호출
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

        return postProcessBus(extract(root));
    }

    private List<Map<String, Object>> postProcessBus(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            // 고속버스: 12자리 yyyyMMddHHmm
            String dep = Objects.toString(m.get("depPlandTime"), "");
            String arr = Objects.toString(m.get("arrPlandTime"), "");
            m.put("depTimeText", prettyTime12(dep));
            m.put("arrTimeText", prettyTime12(arr));

            // JSP에서 쓰기 쉽게 통일 키도 추가
            m.put("gradeText", Objects.toString(m.get("gradeNm"), ""));
            m.put("chargeText", Objects.toString(m.get("charge"), ""));
        }
        return list;
    }

    // =========================
    //  TRAIN
    // =========================
    private static final String TRAIN_URL =
            "http://apis.data.go.kr/1613000/TrainInfoService/getStrtpntAlocFndTrainInfo";

    /**
     * ✅ 도시명 -> 기차역ID(depPlaceId/arrPlaceId)
     * - 속초는 실제 열차역 매핑이 애매할 수 있어서 null 처리(컨트롤러가 errorMsg 띄움)
     */
    private static final Map<String, String> TRAIN_CITY_TO_STATION_ID = new LinkedHashMap<>();
    static {
        TRAIN_CITY_TO_STATION_ID.put("서울", "NAT010000");
        TRAIN_CITY_TO_STATION_ID.put("부산", "NAT014445");

        // 아래는 환경/노선에 따라 달라질 수 있음. 결과 없으면 여기만 교체.
        TRAIN_CITY_TO_STATION_ID.put("강릉", "NAT601936");
        TRAIN_CITY_TO_STATION_ID.put("경주", "NAT050000");
        TRAIN_CITY_TO_STATION_ID.put("수원", "NAT030000");

        // 매핑 안함(컨트롤러에서 에러 처리)
        TRAIN_CITY_TO_STATION_ID.put("속초", "");
    }

    // ✅ 컨트롤러에서 호출
    public String resolveTrainStationId(String city) {
        String id = TRAIN_CITY_TO_STATION_ID.get(city);
        return (id == null || id.isBlank()) ? null : id;
    }

    // ✅ 컨트롤러에서 호출
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
            // 열차는 키가 depPlandTime/arrPlandTime 또는 depplandtime/arrplandtime 섞일 수 있음
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

            // JSP에서 쓰기 쉬운 통일 키(없어도 빈 문자열)
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

    private String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) return a;
        if (b != null && !b.isBlank()) return b;
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
    
 // 터미널 목록 조회 API
    private static final String BUS_TERMINAL_URL =
            "http://apis.data.go.kr/1613000/ExpBusInfoService/getExpBusTrminlList";

    // city -> terminalId 자동 매핑해서 버스 조회
    public List<Map<String, Object>> searchExpBusByCity(String depCity, String arrCity, String depPlandTime) {
        String depTerminalId = resolveExpBusTerminalIdAuto(depCity);
        String arrTerminalId = resolveExpBusTerminalIdAuto(arrCity);

        if (depTerminalId == null || arrTerminalId == null) return Collections.emptyList();
        return searchExpBus(depTerminalId, arrTerminalId, depPlandTime);
    }

    // ✅ 하드코딩 말고, 터미널 목록에서 도시명 포함되는 terminalId 찾아냄
    private String resolveExpBusTerminalIdAuto(String city) {
        Map<String, String> terminals = getExpBusTerminals(); // terminalNm -> terminalId

        // 우선순위(서울은 서울경부가 보통)
        List<String> prefer;
        switch (city) {
            case "서울": prefer = List.of("서울경부", "서울"); break;
            case "부산": prefer = List.of("부산", "부산종합"); break;
            default: prefer = List.of(city); break;
        }

        for (String key : prefer) {
            for (Map.Entry<String, String> e : terminals.entrySet()) {
                if (e.getKey().contains(key)) return e.getValue();
            }
        }
        return null;
    }

    // terminalNm -> terminalId
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


}

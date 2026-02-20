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

    // 터미널 목록 조회 API
    private static final String BUS_TERMINAL_URL =
            "http://apis.data.go.kr/1613000/ExpBusInfoService/getExpBusTrminlList";

    // ✅ terminalNm -> terminalId
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

    /**
     * ✅ 도시명으로 "해당 도시 터미널 목록" 반환
     * - 우선순위: (서울/부산 특수) + "고속" "종합" "시외" 같은 키워드를 앞으로.
     * - 반환형: List<Map<String,String>>  (JSP에서 쓰기 편하게)
     */
    public List<Map<String, String>> getExpBusTerminalsByCity(String city) {
        Map<String, String> all = getExpBusTerminals();

        List<Map<String, String>> list = new ArrayList<>();
        if (city == null || city.isBlank()) return list;

        // 1) 매칭 키워드 구성(도시별 우선 키워드)
        List<String> keys;
        switch (city) {
            case "서울":
                keys = List.of("서울경부", "서울"); break;
            case "부산":
                keys = List.of("부산", "부산종합"); break;
            default:
                keys = List.of(city); break;
        }

        // 2) terminalNm에 키워드 포함되는 것들 수집
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

        // 3) 보기 좋게 정렬(고속/종합/시외 우선)
        list.sort((a, b) -> scoreTerminal(b.get("terminalNm")) - scoreTerminal(a.get("terminalNm")));
        return list;
    }

    private int scoreTerminal(String name) {
        if (name == null) return 0;
        int s = 0;
        if (name.contains("고속")) s += 30;
        if (name.contains("종합")) s += 20;
        if (name.contains("시외")) s += 10;
        // 너무 긴 이름은 뒤로(선택사항)
        if (name.length() <= 6) s += 3;
        return s;
    }

    // ✅ terminalId로 바로 조회 (UI에서 선택한 터미널ID를 그대로 넣는 방식)
    public List<Map<String, Object>> searchExpBusByTerminal(String depTerminalId, String arrTerminalId, String depPlandTime) {
        if (depTerminalId == null || depTerminalId.isBlank()) return Collections.emptyList();
        if (arrTerminalId == null || arrTerminalId.isBlank()) return Collections.emptyList();
        return searchExpBus(depTerminalId, arrTerminalId, depPlandTime);
    }

    // 기존 searchExpBus 그대로
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

}

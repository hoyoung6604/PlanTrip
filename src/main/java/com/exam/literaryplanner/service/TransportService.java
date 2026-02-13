package com.exam.literaryplanner.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TransportService {

    @Value("${tago.serviceKey}")
    private String serviceKey;

    private final WebClient webClient = WebClient.builder().build();

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

    // ✅ 공항 버튼용
    public Map<String, String> getAirports() {
        return AIRPORTS;
    }

    public String getDefaultAirportId() {
        return "NAARKSS"; // 기본: 김포
    }

    // ✅ 버튼에서 선택한 공항 ↔ 제주만
    public List<Map<String, Object>> searchJejuRouteByAirport(String airportId, String depPlandTime) {
        List<Map<String, Object>> all = new ArrayList<>();

        all.addAll(searchFlight(airportId, JEJU_ID, depPlandTime)); // airport -> jeju
        all.addAll(searchFlight(JEJU_ID, airportId, depPlandTime)); // jeju -> airport

        all.sort(Comparator.comparing(m -> Objects.toString(m.get("depPlandTime"), "")));
        return all;
    }

    // ✅ (옵션) 제주 ↔ 전체 공항 전부
    public List<Map<String, Object>> searchJejuAllAirports(String depPlandTime) {
        List<Map<String, Object>> all = new ArrayList<>();

        for (String otherAirportId : AIRPORTS.keySet()) { // ✅ keySet()!!!
            if (JEJU_ID.equals(otherAirportId)) {
				continue;
			}

            all.addAll(searchFlight(otherAirportId, JEJU_ID, depPlandTime));
            all.addAll(searchFlight(JEJU_ID, otherAirportId, depPlandTime));
        }

        all.sort(Comparator.comparing(m -> Objects.toString(m.get("depPlandTime"), "")));
        return all;
    }

    // ✅ 특정 구간 조회
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

        return postProcess(extract(root));
    }

    private List<Map<String, Object>> extract(JsonNode root) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (root == null) {
			return list;
		}

        JsonNode items = root.path("response").path("body").path("items").path("item");
        ObjectMapper mapper = new ObjectMapper();

        if (items.isArray()) {
            for (JsonNode n : items) {
				list.add(mapper.convertValue(n, Map.class));
			}
        } else if (!items.isMissingNode() && !items.isNull()) {
            list.add(mapper.convertValue(items, Map.class));
        }
        return list;
    }

    // ✅ 보기 좋은 시간 문자열 추가
    private List<Map<String, Object>> postProcess(List<Map<String, Object>> list) {
        for (Map<String, Object> m : list) {
            String dep = Objects.toString(m.get("depPlandTime"), "");
            String arr = Objects.toString(m.get("arrPlandTime"), "");

            m.put("depTimeText", prettyTime(dep));
            m.put("arrTimeText", prettyTime(arr));
        }
        return list;
    }

    private String prettyTime(String yyyymmddhhmi) {
        if (yyyymmddhhmi == null) {
			return "";
		}
        String s = yyyymmddhhmi.trim();
        if (s.length() != 12) {
			return s;
		}

        LocalDateTime dt = LocalDateTime.parse(s, DateTimeFormatter.ofPattern("yyyyMMddHHmm"));
        return dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
}



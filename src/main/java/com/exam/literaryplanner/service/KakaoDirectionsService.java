package com.exam.literaryplanner.service;

import com.exam.literaryplanner.dto.RouteSpotDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.DefaultUriBuilderFactory;

import java.util.*;

@Service
@RequiredArgsConstructor
public class KakaoDirectionsService {

    @Value("${kakao.mobility.restKey}")
    private String kakaoRestKey;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // WebClient 대신 RestClient 사용
    private final RestClient restClient = buildKakaoClient();

    private static RestClient buildKakaoClient() {
        DefaultUriBuilderFactory factory =
                new DefaultUriBuilderFactory("https://apis-navi.kakaomobility.com");
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.VALUES_ONLY);

        return RestClient.builder()
                .uriBuilderFactory(factory)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, "application/json")
                .requestInterceptor((request, body, execution) -> {
                    System.out.println("[KAKAO][REAL REQUEST] " + request.getMethod() + " " + request.getURI());
                    return execution.execute(request, body);
                })
                .build();
    }

    public DirectionsResult getDirections(List<RouteSpotDto> spots) {

        if (spots == null || spots.size() < 2) {
            throw new IllegalArgumentException("경로 계산은 최소 2개 장소가 필요합니다.");
        }

        List<RouteSpotDto> valid = spots.stream()
                .filter(Objects::nonNull)
                .filter(s -> s.getLat() != 0.0 && s.getLng() != 0.0)
                .toList();

        if (valid.size() < 2) {
            throw new IllegalArgumentException("좌표(lat/lng)가 없는 장소가 섞여 있습니다.");
        }

        RouteSpotDto originSpot = valid.get(0);
        RouteSpotDto destSpot   = valid.get(valid.size() - 1);

        final String origin = originSpot.getLng() + "," + originSpot.getLat();
        final String destination = destSpot.getLng() + "," + destSpot.getLat();

        String wpTmp = null;
        if (valid.size() > 2) {
            List<RouteSpotDto> mid = valid.subList(1, valid.size() - 1);
            if (mid.size() > 5) {
                throw new IllegalArgumentException("GET /v1/directions waypoints는 최대 5개까지 허용됩니다.");
            }
            wpTmp = String.join("|", mid.stream()
                    .map(s -> s.getLng() + "," + s.getLat())
                    .toList());
        }

        final String waypoints = wpTmp;

        // WebClient의 체이닝 방식을 RestClient 형식으로 변경
        String json = restClient.get()
                .uri(uriBuilder -> {
                    var b = uriBuilder
                            .path("/v1/directions")
                            .queryParam("origin", origin)
                            .queryParam("destination", destination)
                            .queryParam("priority", "RECOMMEND");

                    if (waypoints != null) {
                        b = b.queryParam("waypoints", waypoints);
                    }
                    return b.build();
                })
                .header(HttpHeaders.AUTHORIZATION, "KakaoAK " + kakaoRestKey.trim())
                .retrieve()
                .body(String.class); // block() 없이 바로 동기식으로 응답을 받음

        try {
            JsonNode root = objectMapper.readTree(json);
            JsonNode route0 = root.path("routes").path(0);
            JsonNode summary = route0.path("summary");

            long distanceM = summary.path("distance").asLong(0);
            long durationSec = summary.path("duration").asLong(0);

            List<Map<String, Double>> path = new ArrayList<>();
            JsonNode sections = route0.path("sections");

            for (JsonNode sec : sections) {
                JsonNode roads = sec.path("roads");
                for (JsonNode road : roads) {
                    JsonNode vtx = road.path("vertexes");
                    for (int i = 0; i + 1 < vtx.size(); i += 2) {
                        double x = vtx.get(i).asDouble();     // lng
                        double y = vtx.get(i + 1).asDouble(); // lat
                        path.add(Map.of("lat", y, "lng", x));
                    }
                }
            }

            return new DirectionsResult(distanceM, durationSec, path);

        } catch (Exception e) {
            throw new RuntimeException("Kakao Directions JSON parse failed: " + e.getMessage(), e);
        }
    }

    public record DirectionsResult(long distanceM, long durationSec, List<Map<String, Double>> path) {}
}
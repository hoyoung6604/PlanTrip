package com.exam.literaryplanner.service;

import com.exam.literaryplanner.dto.RouteSpotDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.DefaultUriBuilderFactory;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;

import java.util.*;

@Service
@RequiredArgsConstructor
public class KakaoDirectionsService {

    @Value("${kakao.mobility.restKey}")
    private String kakaoRestKey;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final WebClient webClient = buildKakaoClient();

    private static WebClient buildKakaoClient() {
        DefaultUriBuilderFactory factory =
                new DefaultUriBuilderFactory("https://apis-navi.kakaomobility.com");
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.VALUES_ONLY);

        return WebClient.builder()
                .uriBuilderFactory(factory)
                .clientConnector(new ReactorClientHttpConnector(HttpClient.create().noProxy()))
                .filter((request, next) -> {
                    System.out.println("[KAKAO][REAL REQUEST] " + request.method() + " " + request.url());
                    return next.exchange(request);
                })
                .defaultHeader(HttpHeaders.CONTENT_TYPE, "application/json")
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

        final String origin = originSpot.getLng() + "," + originSpot.getLat();        // lng,lat
        final String destination = destSpot.getLng() + "," + destSpot.getLat();       // lng,lat

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

        // ✅ 람다에서 쓸 “확정값”으로 final 복사
        final String waypoints = wpTmp;

        String json = webClient.get()
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
                .onStatus(HttpStatusCode::isError, resp ->
                        resp.bodyToMono(String.class).flatMap(body ->
                                Mono.error(new RuntimeException(
                                        "Kakao Directions error: HTTP " + resp.statusCode() + " / body=" + body
                                ))
                        )
                )
                .bodyToMono(String.class)
                .block();

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
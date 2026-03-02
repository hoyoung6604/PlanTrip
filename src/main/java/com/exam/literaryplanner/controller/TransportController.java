package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.exam.literaryplanner.service.TransportService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/transport")
@RequiredArgsConstructor
public class TransportController {

    private final TransportService transportService;

//    public TransportController(TransportService transportService) {
//    	this.transportService = transportService;
//    }

    // =========================
    //  항공권 (기존 유지)
    // =========================
    @GetMapping("/flight")
    public String flight(
            @RequestParam(required = false) String depPlandTime,
            @RequestParam(required = false) String airportId,
            @RequestParam(defaultValue = "JEJU_OUT") String direction,
            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {
        String date = (depPlandTime == null || depPlandTime.isBlank())
                ? LocalDate.now(ZoneId.of("Asia/Seoul")).format(DateTimeFormatter.BASIC_ISO_DATE)
                : depPlandTime;

        model.addAttribute("airports", transportService.getAirports());
        model.addAttribute("depPlandTime", date);

        String depPlandTimeIso = LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE)
                .format(DateTimeFormatter.ISO_LOCAL_DATE);
        model.addAttribute("depPlandTimeIso", depPlandTimeIso);

        String selected = (airportId == null || airportId.isBlank())
                ? transportService.getDefaultAirportId()
                : airportId;

        model.addAttribute("selectedAirportId", selected);
        model.addAttribute("direction", direction);

        List<Map<String, Object>> all = transportService.searchJejuRouteByAirport(selected, date);

        String jejuId = "NAARKPC";
        List<Map<String, Object>> filtered = new ArrayList<>();

        for (Map<String, Object> m : all) {
            String depId = Objects.toString(m.get("depAirportId"), "").trim();
            String arrId = Objects.toString(m.get("arrAirportId"), "").trim();
            String depNm = Objects.toString(m.get("depAirportNm"), "").trim();
            String arrNm = Objects.toString(m.get("arrAirportNm"), "").trim();

            boolean depIsJeju = jejuId.equals(depId) || depNm.contains("제주");
            boolean arrIsJeju = jejuId.equals(arrId) || arrNm.contains("제주");

            if ("JEJU_OUT".equals(direction)) {
                if (depIsJeju) {
					filtered.add(m);
				}
            } else if ("JEJU_IN".equals(direction)) {
                if (arrIsJeju) {
					filtered.add(m);
				}
            }
        }

        addPaging(model, filtered, page, 10);
        return "transport/flight";
    }

    @GetMapping("/flight/search")
    public String searchFlight(
            @RequestParam String depAirportId,
            @RequestParam String arrAirportId,
            @RequestParam String depPlandTime,
            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {

        List<?> all = transportService.searchFlight(depAirportId, arrAirportId, depPlandTime);
        if (all == null) {
			all = Collections.emptyList();
		}

        // ✅ JSP UI(칩/달력) 렌더링에 필요한 공통 값 세팅
        model.addAttribute("airports", transportService.getAirports());
        model.addAttribute("depPlandTime", depPlandTime);

        String depPlandTimeIso = LocalDate.parse(depPlandTime, DateTimeFormatter.BASIC_ISO_DATE)
                .format(DateTimeFormatter.ISO_LOCAL_DATE);
        model.addAttribute("depPlandTimeIso", depPlandTimeIso);

        model.addAttribute("depAirportId", depAirportId);
        model.addAttribute("arrAirportId", arrAirportId);
        model.addAttribute("selectedAirportId", arrAirportId);

        addPagingGeneric(model, all, page, 10);
        return "transport/flight";
    }

    // 출발 공항 기준으로 도착 공항 후보를 계산(프론트 자동 필터링용)
    @GetMapping("/flight/arrivals")
    @ResponseBody
    public java.util.List<String> flightArrivals(
            @RequestParam String depAirportId,
            @RequestParam String depPlandTime
    ) {
        java.util.List<String> ids = new java.util.ArrayList<>();
        java.util.Map<String, String> airports = transportService.getAirports(); // id -> name

        for (String arrId : airports.keySet()) {
            if (arrId == null || arrId.isBlank() || arrId.equals(depAirportId)) {
				continue;
			}

            try {
                java.util.List<java.util.Map<String, Object>> tmp = transportService.searchFlight(depAirportId, arrId, depPlandTime);
                if (tmp != null && !tmp.isEmpty()) {
                    ids.add(arrId);
                }
            } catch (Exception ignore) {
                // 일부 조합은 API에서 에러가 날 수 있어요 → 제외
            }
        }
        return ids;
    }



    @GetMapping("/expbus")
    public String expbus(
            @RequestParam(required = false) String depPlandTime,
            @RequestParam(required = false) String depCity,
            @RequestParam(required = false) String arrCity,

            // ✅ 고속 터미널
            @RequestParam(required = false) String depTerminalId,
            @RequestParam(required = false) String arrTerminalId,

            // ✅ 시외 터미널 (추가)
            @RequestParam(required = false) String depSubTerminalId,
            @RequestParam(required = false) String arrSubTerminalId,

            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {
        String date = (depPlandTime == null || depPlandTime.isBlank())
                ? LocalDate.now(ZoneId.of("Asia/Seoul")).format(DateTimeFormatter.BASIC_ISO_DATE)
                : depPlandTime;

        List<String> cities = transportService.getFixedCities();
        model.addAttribute("cities", cities);

        String dep = (depCity == null || depCity.isBlank()) ? "서울" : depCity;
        String arr = (arrCity == null || arrCity.isBlank()) ? "부산" : arrCity;

        /* AUTO: dep==arr */
        if (dep.equals(arr)) {
            arr = dep.equals("부산") ? "서울" : "부산";
        }

        model.addAttribute("depCity", dep);
        model.addAttribute("arrCity", arr);

        model.addAttribute("depPlandTime", date);
        model.addAttribute("depPlandTimeIso",
                LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE).format(DateTimeFormatter.ISO_LOCAL_DATE));

        // =========================
        // 터미널 목록 내려주기
        // =========================
        // 고속
        List<Map<String, String>> depTerminals = transportService.getExpBusTerminalsByCity(dep);
        List<Map<String, String>> arrTerminals = transportService.getExpBusTerminalsByCity(arr);
        model.addAttribute("depTerminals", depTerminals);
        model.addAttribute("arrTerminals", arrTerminals);

        // 시외 (추가)
        List<Map<String, String>> depSubTerminals = transportService.getSuburbsBusTerminalsByCity(dep);
        List<Map<String, String>> arrSubTerminals = transportService.getSuburbsBusTerminalsByCity(arr);
        model.addAttribute("depSubTerminals", depSubTerminals);
        model.addAttribute("arrSubTerminals", arrSubTerminals);

        // AUTO: 기본 터미널 선택(도시 변경 시 자동으로 첫 터미널로 맞춰줌)
        if ((depTerminalId == null || depTerminalId.isBlank()) && depTerminals != null && !depTerminals.isEmpty()) {
            depTerminalId = depTerminals.get(0).get("terminalId");
        }
        if ((arrTerminalId == null || arrTerminalId.isBlank()) && arrTerminals != null && !arrTerminals.isEmpty()) {
            arrTerminalId = arrTerminals.get(0).get("terminalId");
        }

        // 선택값 유지
        model.addAttribute("depTerminalId", depTerminalId);
        model.addAttribute("arrTerminalId", arrTerminalId);
        model.addAttribute("depSubTerminalId", depSubTerminalId);
        model.addAttribute("arrSubTerminalId", arrSubTerminalId);

        // =========================
        // 조회(고속 + 시외) → 합치기
        // =========================
        List<Map<String, Object>> merged = new ArrayList<>();

        boolean hasExp = depTerminalId != null && !depTerminalId.isBlank()
                && arrTerminalId != null && !arrTerminalId.isBlank();
        boolean hasSub = depSubTerminalId != null && !depSubTerminalId.isBlank()
                && arrSubTerminalId != null && !arrSubTerminalId.isBlank();

        if (hasExp) {
            merged.addAll(transportService.searchExpBusByTerminal(depTerminalId, arrTerminalId, date));
        }
        if (hasSub) {
            merged.addAll(transportService.searchSuburbsBusByTerminal(depSubTerminalId, arrSubTerminalId, date));
        }

        // 정렬(출발시간 기준)
        merged.sort(Comparator.comparing(m -> Objects.toString(m.get("depPlandTime"), "")));

        // 에러 메시지
        if ((hasExp || hasSub) && merged.isEmpty()) {
            model.addAttribute("errorMsg",
                    "조회 결과가 없습니다. (선택한 터미널 조합에 운행이 없을 수 있어요)");
        }

        addPaging(model, merged, page, 10);
        return "transport/expbus";
    }

    // =========================
    //  기차 (기존 유지)
    // =========================
    @GetMapping("/train")
    public String train(
            @RequestParam(required = false) String depPlandTime,
            @RequestParam(required = false) String depCity,
            @RequestParam(required = false) String arrCity,
            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {
        String date = (depPlandTime == null || depPlandTime.isBlank())
                ? LocalDate.now(ZoneId.of("Asia/Seoul")).format(DateTimeFormatter.BASIC_ISO_DATE)
                : depPlandTime;

        List<String> cities = transportService.getFixedCities();
        model.addAttribute("cities", cities);

        String dep = (depCity == null || depCity.isBlank()) ? "서울" : depCity;
        String arr = (arrCity == null || arrCity.isBlank()) ? "부산" : arrCity;

        /* AUTO: dep==arr */
        if (dep.equals(arr)) {
            arr = dep.equals("부산") ? "서울" : "부산";
        }

        model.addAttribute("depCity", dep);
        model.addAttribute("arrCity", arr);

        model.addAttribute("depPlandTime", date);
        model.addAttribute("depPlandTimeIso",
                LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE).format(DateTimeFormatter.ISO_LOCAL_DATE));

        String depPlaceId = transportService.resolveTrainStationId(dep);
        String arrPlaceId = transportService.resolveTrainStationId(arr);

        if (depPlaceId == null || arrPlaceId == null) {
            model.addAttribute("errorMsg", "선택한 지역의 기차역 ID를 찾지 못했습니다. (예: 속초는 열차역 매핑이 없을 수 있어요)");
            addPaging(model, Collections.emptyList(), 1, 10);
            return "transport/train";
        }

        List<Map<String, Object>> all = transportService.searchTrain(depPlaceId, arrPlaceId, date);

        model.addAttribute("depPlaceId", depPlaceId);
        model.addAttribute("arrPlaceId", arrPlaceId);

        addPaging(model, all, page, 10);
        return "transport/train";
    }

    // =========================
    //  paging utils
    // =========================
    private void addPaging(Model model, List<Map<String, Object>> list, int page, int pageSize) {
        if (list == null) {
			list = Collections.emptyList();
		}

        int total = list.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages == 0) {
			totalPages = 1;
		}

        if (page < 1) {
			page = 1;
		}
        if (page > totalPages) {
			page = totalPages;
		}

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, total);

        List<Map<String, Object>> paged = (fromIndex < total)
                ? list.subList(fromIndex, toIndex)
                : Collections.emptyList();

        model.addAttribute("result", paged);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
    }

    private void addPagingGeneric(Model model, List<?> list, int page, int pageSize) {
        if (list == null) {
			list = Collections.emptyList();
		}

        int total = list.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages == 0) {
			totalPages = 1;
		}

        if (page < 1) {
			page = 1;
		}
        if (page > totalPages) {
			page = totalPages;
		}

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, total);

        List<?> paged = (fromIndex < total)
                ? list.subList(fromIndex, toIndex)
                : Collections.emptyList();

        model.addAttribute("result", paged);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
    }
}

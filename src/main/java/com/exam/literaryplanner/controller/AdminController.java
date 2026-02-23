package com.exam.literaryplanner.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.exam.literaryplanner.domain.Board;
import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.repository.QnaRepository;
import com.exam.literaryplanner.service.AdminQnaService;
import com.exam.literaryplanner.service.BoardService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final BoardService boardService;
    private final AdminQnaService adminQnaService;
    private final QnaRepository qnaRepository;
    private final LiteraryRepository literaryRepository;

    public AdminController(BoardService boardService,
    		AdminQnaService adminQnaService,
    		QnaRepository qnaRepository,
    		LiteraryRepository literaryRepository) {
        this.boardService = boardService;
        this.adminQnaService = adminQnaService;
        this.qnaRepository = qnaRepository;
        this.literaryRepository = literaryRepository;
    }

    @GetMapping({"", "/"})
    public String adminIndex(Model model) {

        long pendingQnaCount = qnaRepository.countPendingByStatus(0);
        model.addAttribute("pendingQnaCount", pendingQnaCount);

        // 최근 문의 목록(미처리만, 최신순)
        // - 카운트는 뜨는데 목록/문의관리에서 비어 보이는 현상은
        //   findAll + 화면 필터 조합이 꼬여서 생기는 경우가 많아서
        //   "미처리(0)"를 DB에서 직접 최신순으로 뽑아옵니다.
        List<java.util.Map<String, Object>> recentQnaList = new java.util.ArrayList<>();
        for (com.exam.literaryplanner.domain.Qna q : qnaRepository.findTop5ByQStatusOrderByQRegDateDesc(0)) {
            java.util.Map<String, Object> v = new java.util.HashMap<>();
            v.put("qIdx", q.getQIdx());
            v.put("qTitle", q.getQTitle());
            v.put("qStatus", q.getQStatus());
            v.put("qRegDate", q.getQRegDate());
            v.put("mName", (q.getMember() != null ? q.getMember().getMName() : "-"));
            recentQnaList.add(v);
        }
        model.addAttribute("recentQnaList", recentQnaList);


        // 최근 FAQ (최신 5개)
        List<Board> allFaqs = boardService.listFaqs();
        List<Board> recentFaqList = new ArrayList<>();
        if (allFaqs != null) {
            for (int i = 0; i < allFaqs.size() && i < 5; i++) {
                recentFaqList.add(allFaqs.get(i));
            }
        }
        model.addAttribute("recentFaqList", recentFaqList);

        return "admin/admin_index";
    }


    // ✅ 공지사항 목록 페이지
    @GetMapping("/notices")
    public String notices(Model model) {
        List<Board> notices = boardService.listNotices();
        model.addAttribute("notices", notices);
        return "admin/admin_notices";
    }

    // ✅ 공지 작성 페이지 (페이지 이름: admin_notice)
    @GetMapping("/notice")
    public String noticeWriteForm() {
        return "admin/admin_notice";
    }

    // ✅ 공지 등록 처리
    @PostMapping("/notice")
    public String noticeWrite(@RequestParam String title,
                              @RequestParam String cont,
                              @RequestParam(required = false) String isTop) {

        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.createNotice(title, cont, top);

        return "redirect:/admin/notices";
    }

    @GetMapping("/notices/{bIdx}")
    public String adminNoticeDetail(@PathVariable Integer bIdx, Model model) {
        model.addAttribute("notice", boardService.getNoticeDetail(bIdx)); // 기존 메서드 재사용
        return "admin/admin_noticeDetail";
    }

 // ✅ 수정 폼
    @GetMapping("/notices/{bIdx}/edit")
    public String adminNoticeEditForm(@PathVariable Integer bIdx, Model model) {
        model.addAttribute("notice", boardService.getNoticeDetail(bIdx));
        return "admin/admin_noticeEdit";
    }

    // ✅ 수정 처리
    @PostMapping("/notices/{bIdx}/edit")
    public String adminNoticeEditSubmit(@PathVariable Integer bIdx,
                                        @RequestParam String title,
                                        @RequestParam String cont,
                                        @RequestParam(required = false) String isTop) {

        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.updateNotice(bIdx, title, cont, top);

        return "redirect:/admin/notices/" + bIdx;
    }

    // ✅ 삭제 처리
    @PostMapping("/notices/{bIdx}/delete")
    public String adminNoticeDelete(@PathVariable Integer bIdx) {
        boardService.deleteNotice(bIdx);
        return "redirect:/admin/notices";
    }

 // ✅ FAQ 목록
    @GetMapping("/faqs")
    public String adminFaqList(Model model) {
        model.addAttribute("faqList", boardService.listFaqs());
        return "admin/admin_faqs";
    }

    // ✅ FAQ 작성 폼
    @GetMapping("/faq")
    public String adminFaqWriteForm() {
        return "admin/admin_faq";
    }

    // ✅ FAQ 등록
    @PostMapping("/faq")
    public String adminFaqWrite(@RequestParam String title,
                                @RequestParam String cont,
                                @RequestParam(required = false) String isTop) {
        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.createFaq(title, cont, top);
        return "redirect:/admin/faqs";
    }

    // ✅ FAQ 상세
    @GetMapping("/faqs/{bIdx}")
    public String adminFaqDetail(@PathVariable Integer bIdx, Model model) {
        model.addAttribute("faq", boardService.getFaqDetail(bIdx));
        return "admin/admin_faqDetail";
    }

    // ✅ FAQ 수정 폼
    @GetMapping("/faqs/{bIdx}/edit")
    public String adminFaqEditForm(@PathVariable Integer bIdx, Model model) {
        model.addAttribute("faq", boardService.getFaqDetail(bIdx));
        return "admin/admin_faqEdit";
    }

    // ✅ FAQ 수정 처리
    @PostMapping("/faqs/{bIdx}/edit")
    public String adminFaqEditSubmit(@PathVariable Integer bIdx,
                                     @RequestParam String title,
                                     @RequestParam String cont,
                                     @RequestParam(required = false) String isTop) {
        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.updateFaq(bIdx, title, cont, top);
        return "redirect:/admin/faqs/" + bIdx;
    }

    // ✅ FAQ 삭제 처리
    @PostMapping("/faqs/{bIdx}/delete")
    public String adminFaqDelete(@PathVariable Integer bIdx) {
        boardService.deleteFaq(bIdx);
        return "redirect:/admin/faqs";
    }

    private boolean isAdmin(HttpSession session) {
        Member m = (Member) session.getAttribute("loginMember");
        return (m != null && m.getMRole() != null && m.getMRole() == 9);
    }

    @GetMapping("/inquiries")
    public String inquiries(HttpSession session, Model model, RedirectAttributes ra) {
        Member m = (Member) session.getAttribute("loginMember");
        if (m == null || m.getMRole() == null || m.getMRole() != 9) {
            ra.addFlashAttribute("msg", "관리자만 접근 가능합니다.");
            return "redirect:/";
        }

        // 사이드바 배지(미처리 문의 수) 공통 제공
        model.addAttribute("pendingQnaCount", qnaRepository.countPendingByStatus(0));

        // =========================
        // ✅ 문의 목록
        // - 카운트는 정상인데 목록이 비어 보이는 문제를 막기 위해,
        //   상태값으로 DB에서 직접 가져와서 화면에 전달합니다.
        // =========================
        List<java.util.Map<String, Object>> pending = new ArrayList<>();
        List<java.util.Map<String, Object>> done = new ArrayList<>();

        for (com.exam.literaryplanner.domain.Qna q : qnaRepository.findByQStatusOrderByQRegDateDesc(0)) {
            java.util.Map<String, Object> v = new java.util.HashMap<>();
            v.put("qIdx", q.getQIdx());
            v.put("qTitle", q.getQTitle());
            v.put("qStatus", q.getQStatus());
            v.put("qRegDate", q.getQRegDate());
            v.put("mName", (q.getMember() != null ? q.getMember().getMName() : "-"));
            pending.add(v);
        }

        for (com.exam.literaryplanner.domain.Qna q : qnaRepository.findByQStatusOrderByQRegDateDesc(1)) {
            java.util.Map<String, Object> v = new java.util.HashMap<>();
            v.put("qIdx", q.getQIdx());
            v.put("qTitle", q.getQTitle());
            v.put("qStatus", q.getQStatus());
            v.put("qRegDate", q.getQRegDate());
            v.put("mName", (q.getMember() != null ? q.getMember().getMName() : "-"));
            done.add(v);
        }

        int total = pending.size() + done.size();
        int pendingCnt = pending.size();
        int doneCnt = done.size();
        int donePct = (total == 0) ? 0 : (int) Math.round((doneCnt * 100.0) / total);

        model.addAttribute("qnaTotal", total);
        model.addAttribute("qnaPendingCount", pendingCnt);
        model.addAttribute("qnaDoneCount", doneCnt);
        model.addAttribute("qnaDonePct", donePct);

        model.addAttribute("qnaPendingList", pending);
        model.addAttribute("qnaDoneList", done);

        return "admin/inquiries"; // /WEB-INF/views/admin/inquiries.jsp
    }

    @GetMapping("/inquiries/{qIdx}")
    public String inquiryDetail(@PathVariable Integer qIdx, HttpSession session, Model model, RedirectAttributes ra) {
        Member m = (Member) session.getAttribute("loginMember");
        if (m == null || m.getMRole() == null || m.getMRole() != 9) {
            ra.addFlashAttribute("msg", "관리자만 접근 가능합니다.");
            return "redirect:/";
        }

        model.addAttribute("qna", adminQnaService.getQnaDetail(qIdx));
        return "admin/inquiry_detail";
    }

    @PostMapping("/inquiries/{qIdx}/answer")
    public String inquiryAnswer(@PathVariable Integer qIdx,
                                @RequestParam String qAnswer,
                                HttpSession session,
                                RedirectAttributes ra) {
        Member m = (Member) session.getAttribute("loginMember");
        if (m == null || m.getMRole() == null || m.getMRole() != 9) {
            ra.addFlashAttribute("msg", "관리자만 접근 가능합니다.");
            return "redirect:/";
        }

        adminQnaService.saveAnswer(qIdx, qAnswer);
        ra.addFlashAttribute("msg", "답변이 저장되었습니다.");
        return "redirect:/admin";
    }

    @GetMapping("/members")
    public String adminMembers(HttpSession session, Model model, RedirectAttributes ra,
                               @RequestParam(required = false) String kw) {
        Member m = (Member) session.getAttribute("loginMember");
        if (m == null || m.getMRole() == null || m.getMRole() != 9) {
            ra.addFlashAttribute("msg", "관리자만 접근 가능합니다.");
            return "redirect:/";
        }

        List<Member> members;
        if (kw != null && !kw.trim().isEmpty()) {
            members = literaryRepository.searchMembers(kw.trim());
        } else {
            members = literaryRepository.findAllOrderByRegDateDesc();
            // 또는 관리자 제외라면: findAllUsersOrderByRegDateDesc()
        }

        model.addAttribute("members", members);
        model.addAttribute("kw", kw);
        return "admin/admin_members";
    }

    @GetMapping("/blacklist")
    public String blacklistPage(Model model) {

        // 아직 기능 없으니까 더미 리스트 (안 넣어도 됨)
        model.addAttribute("blacklist", new ArrayList<>());

        return "admin/blacklist";
        // → /WEB-INF/views/admin/blacklist.jsp
    }


}
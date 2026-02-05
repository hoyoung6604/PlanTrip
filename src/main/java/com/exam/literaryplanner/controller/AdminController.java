package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Board;
import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.QnaRepository;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.service.AdminQnaService;
import com.exam.literaryplanner.service.BoardService;
import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

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

        // 공지/FAQ도 나중에 추가 가능
        model.addAttribute("pendingQnaCount", pendingQnaCount);

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
    public String adminNoticeDetail(@PathVariable Long bIdx, Model model) {
        model.addAttribute("notice", boardService.getNoticeDetail(bIdx)); // 기존 메서드 재사용
        return "admin/admin_noticeDetail";
    }

 // ✅ 수정 폼
    @GetMapping("/notices/{bIdx}/edit")
    public String adminNoticeEditForm(@PathVariable Long bIdx, Model model) {
        model.addAttribute("notice", boardService.getNoticeDetail(bIdx));
        return "admin/admin_noticeEdit";
    }

    // ✅ 수정 처리
    @PostMapping("/notices/{bIdx}/edit")
    public String adminNoticeEditSubmit(@PathVariable Long bIdx,
                                        @RequestParam String title,
                                        @RequestParam String cont,
                                        @RequestParam(required = false) String isTop) {

        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.updateNotice(bIdx, title, cont, top);

        return "redirect:/admin/notices/" + bIdx;
    }

    // ✅ 삭제 처리
    @PostMapping("/notices/{bIdx}/delete")
    public String adminNoticeDelete(@PathVariable Long bIdx) {
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
    public String adminFaqDetail(@PathVariable Long bIdx, Model model) {
        model.addAttribute("faq", boardService.getFaqDetail(bIdx));
        return "admin/admin_faqDetail";
    }

    // ✅ FAQ 수정 폼
    @GetMapping("/faqs/{bIdx}/edit")
    public String adminFaqEditForm(@PathVariable Long bIdx, Model model) {
        model.addAttribute("faq", boardService.getFaqDetail(bIdx));
        return "admin/admin_faqEdit";
    }

    // ✅ FAQ 수정 처리
    @PostMapping("/faqs/{bIdx}/edit")
    public String adminFaqEditSubmit(@PathVariable Long bIdx,
                                     @RequestParam String title,
                                     @RequestParam String cont,
                                     @RequestParam(required = false) String isTop) {
        boolean top = "1".equals(isTop) || "on".equalsIgnoreCase(isTop);
        boardService.updateFaq(bIdx, title, cont, top);
        return "redirect:/admin/faqs/" + bIdx;
    }

    // ✅ FAQ 삭제 처리
    @PostMapping("/faqs/{bIdx}/delete")
    public String adminFaqDelete(@PathVariable Long bIdx) {
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

        model.addAttribute("qnaList", adminQnaService.listAllQna());
        return "admin/inquiries"; // /WEB-INF/views/admin/inquiries.jsp
    }

    @GetMapping("/inquiries/{qIdx}")
    public String inquiryDetail(@PathVariable Long qIdx, HttpSession session, Model model, RedirectAttributes ra) {
        Member m = (Member) session.getAttribute("loginMember");
        if (m == null || m.getMRole() == null || m.getMRole() != 9) {
            ra.addFlashAttribute("msg", "관리자만 접근 가능합니다.");
            return "redirect:/";
        }

        model.addAttribute("qna", adminQnaService.getQnaDetail(qIdx));
        return "admin/inquiry_detail";
    }

    @PostMapping("/inquiries/{qIdx}/answer")
    public String inquiryAnswer(@PathVariable Long qIdx,
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


}

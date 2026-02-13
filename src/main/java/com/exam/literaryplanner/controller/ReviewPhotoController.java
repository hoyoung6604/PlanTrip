package com.exam.literaryplanner.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.domain.ReviewPhoto;
import com.exam.literaryplanner.repository.ReviewRepository;
import com.exam.literaryplanner.service.ReviewPhotoService;

import jakarta.servlet.http.HttpSession;

///login 만 하면 다른 사람 글에서도 업로드가 가능.

@Controller
@RequestMapping("/review-photos")
public class ReviewPhotoController {

    private final ReviewPhotoService reviewPhotoService;
    private final ReviewRepository reviewRepository;

    public ReviewPhotoController(ReviewPhotoService reviewPhotoService,
                                 ReviewRepository reviewRepository) {
        this.reviewPhotoService = reviewPhotoService;
        this.reviewRepository = reviewRepository;
    }

    // (1) 특정 후기(rvIdx)의 사진 목록(JSON)
    @GetMapping("/list")
    @ResponseBody
    public List<ReviewPhoto> list(@RequestParam Integer rvIdx) {
        return reviewPhotoService.list(rvIdx);
    }

    @GetMapping("/file/{photoId}")
    public ResponseEntity<Resource> file(@PathVariable("photoId") Integer photoId) {
        try {
            ReviewPhoto photo = reviewPhotoService.getPhoto(photoId);

            // ReviewPhotoService의 uploadRoot 규칙과 동일하게 맞춰야 함
            Path uploadRoot = Paths.get(System.getProperty("user.home"), "literaryplanner_uploads", "reviews");
            Path filePath = uploadRoot.resolve(photo.getRpStoredName());

            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new UrlResource(filePath.toUri());

            String contentType = photo.getRpContentType();
            if (contentType == null || contentType.isBlank()) {
                contentType = Files.probeContentType(filePath);
                if (contentType == null) {
					contentType = "application/octet-stream";
				}
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CACHE_CONTROL, "no-cache, no-store, must-revalidate")
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // (2) 사진 업로드 (작성자만 가능)
    @PostMapping("/upload")
    public String upload(@RequestParam Integer rvIdx,
                         @RequestParam("photos") MultipartFile[] photos,
                         @RequestParam(required = false, defaultValue = "/community/view?rvIdx=") String redirectBase,
                         HttpSession session) throws Exception {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
			return "redirect:/community";
		}

        // ✅ 작성자만 업로드 허용
        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:" + redirectBase + rvIdx;
        }

        // ✅ 여러 장 저장
        reviewPhotoService.saveAll(rvIdx, photos);

        return "redirect:" + redirectBase + rvIdx;
    }


    // (3) 이미지 파일 제공
    @GetMapping("/{rpIdx}")
    public ResponseEntity<Resource> serve(@PathVariable Integer rpIdx) {

        ReviewPhoto meta = reviewPhotoService.getMeta(rpIdx);
        Resource resource = reviewPhotoService.loadAsResource(rpIdx);

        MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;
        try {
            if (meta.getRpContentType() != null) {
                mediaType = MediaType.parseMediaType(meta.getRpContentType());
            }
        } catch (Exception ignored) {}

        return ResponseEntity.ok()
                .contentType(mediaType)
                .cacheControl(CacheControl.noCache())
                .body(resource);
    }

    // 추가부분
    @PostMapping("/delete")
    public String delete(@RequestParam Integer rpIdx,
                         @RequestParam Integer rvIdx,
                         HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
			return "redirect:/community";
		}

        // 작성자만 삭제 가능
        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/community/view?rvIdx=" + rvIdx;
        }

        reviewPhotoService.delete(rpIdx);
        return "redirect:/community/view?rvIdx=" + rvIdx;
    }


 // (4) 여러 장 업로드
    @PostMapping("/upload-multi")
    public String uploadMulti(@RequestParam Integer rvIdx,
                              @RequestParam("photos") MultipartFile[] photos,
                              HttpSession session) throws Exception {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        reviewPhotoService.saveMany(rvIdx, photos);

        return "redirect:/community/view?rvIdx=" + rvIdx;
    }



}

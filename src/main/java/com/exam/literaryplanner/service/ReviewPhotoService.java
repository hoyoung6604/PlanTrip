package com.exam.literaryplanner.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.exam.literaryplanner.domain.ReviewPhoto;
import com.exam.literaryplanner.repository.ReviewPhotoRepository;

@Service
public class ReviewPhotoService {

    private final ReviewPhotoRepository reviewPhotoRepository;

    // ✅ (중요) Tomcat 임시폴더가 아니라 "고정 폴더"로 저장

    private final Path uploadRoot = Paths.get(
            System.getProperty("user.home"),
            "literaryplanner_uploads",
            "reviews"
    );

    public ReviewPhotoService(ReviewPhotoRepository reviewPhotoRepository) {
        this.reviewPhotoRepository = reviewPhotoRepository;
    }

    public List<ReviewPhoto> list(Integer rvIdx) {
        return reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(rvIdx);
    }

    public ReviewPhoto save(Integer rvIdx, MultipartFile file) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("파일이 비어있습니다.");
        }

        String original = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String ext = "";
        int dot = original.lastIndexOf(".");
        if (dot > -1) {
			ext = original.substring(dot);
		}

        String stored = UUID.randomUUID() + ext;

        // ✅ 저장될 파일 경로
        Path target = uploadRoot.resolve(stored);

        // ✅ (핵심) 부모 폴더 무조건 생성
        Files.createDirectories(target.getParent());

        // ✅ 파일 저장
        file.transferTo(target.toFile());

        ReviewPhoto photo = new ReviewPhoto();
        photo.setRvIdx(rvIdx);
        photo.setRpOriginalName(original);
        photo.setRpStoredName(stored);
        photo.setRpContentType(file.getContentType());
        photo.setRpSize((int) file.getSize());

        return reviewPhotoRepository.save(photo);
    }

    public Resource loadAsResource(Integer rpIdx) {
        ReviewPhoto photo = reviewPhotoRepository.findById(rpIdx).orElseThrow();
        File f = uploadRoot.resolve(photo.getRpStoredName()).toFile();
        return new FileSystemResource(f);
    }

    public ReviewPhoto getMeta(Integer rpIdx) {
        return reviewPhotoRepository.findById(rpIdx).orElseThrow();
    }

    // 추가
    public void delete(Integer rpIdx) {
        ReviewPhoto photo = reviewPhotoRepository.findById(rpIdx).orElseThrow();

        // 1) 파일 삭제 (파일이 없어도 예외 안 터지게)
        try {
            Path filePath = uploadRoot.resolve(photo.getRpStoredName());
            Files.deleteIfExists(filePath);
        } catch (Exception ignored) {}

        // 2) DB 삭제
        reviewPhotoRepository.deleteById(rpIdx);
    }

    public void saveAll(Integer rvIdx, MultipartFile[] files) throws Exception {
        if (files == null || files.length == 0) {
			return;
		}

        for (MultipartFile f : files) {
            if (f == null || f.isEmpty()) {
				continue;
			}
            save(rvIdx, f); // 기존 save 재사용
        }
    }

    public void saveMany(Integer rvIdx, MultipartFile[] photos) throws Exception {
        if (photos == null) {
			return;
		}
        for (MultipartFile f : photos) {
            if (f == null || f.isEmpty()) {
				continue;
			}
            save(rvIdx, f); // 기존 save 재사용 (기존코드 안 건드림)
        }
    }

    public ReviewPhoto getPhoto(Integer rpIdx) {
        // ✅ 여기 repo -> reviewPhotoRepository 로 수정 (컴파일 에러 해결)
        return reviewPhotoRepository.findById(rpIdx)
                .orElseThrow(() -> new IllegalArgumentException("사진이 없습니다. rpIdx=" + rpIdx));
    }

}

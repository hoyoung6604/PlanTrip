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
    // 현재(기준) 경로
    private final Path uploadRoot = Paths.get(
            System.getProperty("user.home"),
            "literaryplanner_uploads",
            "reviews"
    );
    // 과거 버전 호환: 이전에 다른 폴더명으로 저장된 사진이 있을 수 있어서 조회 시 함께 탐색
    private final Path legacyUploadRoot = Paths.get(
            System.getProperty("user.home"),
            "plantrip_uploads",
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
        String stored = photo.getRpStoredName();

        // 1) 기본 경로에서 먼저 찾기
        File f = uploadRoot.resolve(stored).toFile();
        FileSystemResource res = new FileSystemResource(f);
        if (res.exists() && res.isReadable()) {
            return res;
        }

        // 2) 과거 경로(폴더명 변경 등)에서도 찾아보기
        File legacy = legacyUploadRoot.resolve(stored).toFile();
        FileSystemResource legacyRes = new FileSystemResource(legacy);
        if (legacyRes.exists() && legacyRes.isReadable()) {
            return legacyRes;
        }

        // ✅ 파일이 실제로 없으면 컨트롤러에서 404로 처리할 수 있게 null 반환
        return null;
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
            // ✅ 파일 하나가 실패해도 나머지는 계속 저장 (상세보기에서 "사진 없음"이 뜨는 상황 방지)
            try {
                save(rvIdx, f); // 기존 save 재사용
            } catch (Exception ignored) {
                // 사진 저장 실패해도 글/다른 사진 저장은 유지
            }
        }
    }

    public ReviewPhoto getPhoto(Integer rpIdx) {
        // ✅ 여기 repo -> reviewPhotoRepository 로 수정 (컴파일 에러 해결)
        return reviewPhotoRepository.findById(rpIdx)
                .orElseThrow(() -> new IllegalArgumentException("사진이 없습니다. rpIdx=" + rpIdx));
    }

}

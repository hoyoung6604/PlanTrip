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

    // ✅ (매우 중요) 한글 사용자명("이은아")에서 발생하는 파일 저장 에러 방지
    // user.home 대신 현재 프로젝트 실행 경로(user.dir)에 폴더를 만듭니다.
    private final Path uploadRoot = Paths.get(
            System.getProperty("user.dir"),
            "uploads",
            "reviews"
    );
    
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

        Path target = uploadRoot.resolve(stored);

        // 부모 폴더 무조건 생성
        Files.createDirectories(target.getParent());

        // 파일 물리적 저장
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

        File f = uploadRoot.resolve(stored).toFile();
        FileSystemResource res = new FileSystemResource(f);
        if (res.exists() && res.isReadable()) {
            return res;
        }

        File legacy = legacyUploadRoot.resolve(stored).toFile();
        FileSystemResource legacyRes = new FileSystemResource(legacy);
        if (legacyRes.exists() && legacyRes.isReadable()) {
            return legacyRes;
        }

        return null;
    }

    public ReviewPhoto getMeta(Integer rpIdx) {
        return reviewPhotoRepository.findById(rpIdx).orElseThrow();
    }

    public void delete(Integer rpIdx) {
        ReviewPhoto photo = reviewPhotoRepository.findById(rpIdx).orElseThrow();

        try {
            Path filePath = uploadRoot.resolve(photo.getRpStoredName());
            Files.deleteIfExists(filePath);
        } catch (Exception ignored) {}

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
            save(rvIdx, f); 
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
            try {
                save(rvIdx, f);
            } catch (Exception ignored) { }
        }
    }

    public ReviewPhoto getPhoto(Integer rpIdx) {
        return reviewPhotoRepository.findById(rpIdx)
                .orElseThrow(() -> new IllegalArgumentException("사진이 없습니다. rpIdx=" + rpIdx));
    }
}
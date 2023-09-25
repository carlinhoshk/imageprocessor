package io.github.carlinhoshk.imageprocessor.controllers;

import io.github.carlinhoshk.imageprocessor.services.ImageProcessorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("image")
public class ImageProcessorController {
    static final String targetPath = "./src/main/resources/data/output/output.png";

    @Autowired
    private ImageProcessorService imageService;

    @PostMapping("/upload")
    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {

            imageService.processImageAndSave(file, targetPath);
            return ResponseEntity.ok("Imagem processada e salva com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao processar e salvar a imagem: " + e.getMessage());
        }
    }
}


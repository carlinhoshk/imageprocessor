package io.github.carlinhoshk.imageprocessor.controllers;

import io.github.carlinhoshk.imageprocessor.services.ImageProcessorService;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;


import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;


@RestController
@RequestMapping("image")
public class ImageProcessorController {
    static final String targetPath = "./src/main/resources/data/output/";

    @Autowired
    private ImageProcessorService imageService;

    @PostMapping("/upload")
    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            // Obter o nome do arquivo do objeto MultipartFile
            String fileName = file.getOriginalFilename();
            
            // Processar a imagem e salvar com sucesso
            imageService.processImageAndSave(file, targetPath);
            
            // Retornar o nome do arquivo no corpo da resposta
            return ResponseEntity.ok("Imagem '" + fileName + "' processada e salva com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao processar e salvar a imagem: " + e.getMessage());
        }
    }

    @GetMapping("download/filename")
    public ResponseEntity<byte[]> getImage(@PathVariable ("filename") String fileName) {
        byte[] image = new byte[0];
        try {
            image = FileUtils.readFileToByteArray(new File(targetPath + fileName));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ResponseEntity.ok().contentType(MediaType.IMAGE_JPEG).body(image);
    }

}


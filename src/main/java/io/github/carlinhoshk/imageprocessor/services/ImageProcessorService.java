package io.github.carlinhoshk.imageprocessor.services;

import org.opencv.core.*;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class ImageProcessorService {

    public Mat loadImage(MultipartFile file) {
        try {
            byte[] bytes = file.getBytes();
            return Imgcodecs.imdecode(new MatOfByte(bytes), Imgcodecs.IMREAD_COLOR);
        } catch (IOException e) {
            throw new RuntimeException("Erro ao carregar a imagem.", e);
        }
    }

    public void processImageAndSave(MultipartFile file, String targetDirectory) {
        Mat loadedImage = loadImage(file);
        MatOfRect facesDetected = new MatOfRect();

        CascadeClassifier cascadeClassifier = new CascadeClassifier();
        int minFaceSize = Math.round(loadedImage.rows() * 0.1f);
        cascadeClassifier.load("src/main/resources/haarcascades/haarcascade_frontalface_alt.xml");
        cascadeClassifier.detectMultiScale(loadedImage,
                facesDetected,
                1.1,
                3,
                Objdetect.CASCADE_SCALE_IMAGE,
                new Size(minFaceSize, minFaceSize),
                new Size()
        );

        Rect[] facesArray = facesDetected.toArray();
        for (Rect face : facesArray) {
            Imgproc.rectangle(loadedImage, face.tl(), face.br(), new Scalar(0, 0, 255), 3);
        }

        // Obtém a data e hora atuais
        LocalDateTime currentDateTime = LocalDateTime.now();

        // Formata a data e hora atual como parte do nome do arquivo
        String fileName = currentDateTime.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".jpg";

        // Caminho completo para o arquivo de destino
        String targetPath = Paths.get(targetDirectory, fileName).toString();

        saveImage(loadedImage, targetPath);
    }

    private void saveImage(Mat imageMatrix, String targetPath) {
        Imgcodecs imgcodecs = new Imgcodecs();
        imgcodecs.imwrite(targetPath, imageMatrix);
    }
}
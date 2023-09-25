package io.github.carlinhoshk.imageprocessor;

import org.opencv.core.*;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import nu.pattern.OpenCV;

@SpringBootApplication
public class ImageprocessorApplication {

    public static void main(String[] args) {

        OpenCV.loadShared();
        SpringApplication.run(ImageprocessorApplication.class, args);
    }


}

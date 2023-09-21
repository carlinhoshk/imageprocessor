package io.github.carlinhoshk.imageprocessor.services;

import org.opencv.core.Mat;
import org.opencv.imgcodecs.Imgcodecs;

public class ImageProcessorService {


    public static Mat loadImage(String imagePath) {
        Imgcodecs imageCodecs = new Imgcodecs();
        return imageCodecs.imread(imagePath);
    }

    public static void saveImage(Mat imageMatrix, String targetPath) {
        Imgcodecs imgcodecs = new Imgcodecs();
        imgcodecs.imwrite(targetPath, imageMatrix);
    }


}

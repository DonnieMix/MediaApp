//
//  CameraViewControllerExtension.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 10.10.2023.
//

import Foundation
import AVFoundation
import UIKit

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error making photo: \(error.localizedDescription)")
            return
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)
        let fileName = "\(formattedDate).jpg"
        
        let fileUrl = paths[0].appendingPathComponent(fileName)
        
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            do {
                try image.jpegData(compressionQuality: 1.0)?.write(to: fileUrl)
            }
            catch {
                print("Error writing photo: \(error.localizedDescription)")
            }
        }
    }
}

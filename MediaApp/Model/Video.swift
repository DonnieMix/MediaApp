//
//  Video.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import Foundation
import UIKit
import AVFoundation

struct Video: Media {
    var fileURL: URL?
    var thumbnail: UIImage?
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.thumbnail = makeThumbnail(from: fileURL)
    }
    
    private func makeThumbnail(from fileURL: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: fileURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true

            let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)

            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("Error creating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

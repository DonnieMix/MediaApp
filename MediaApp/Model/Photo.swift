//
//  Photo.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import Foundation
import UIKit

struct Photo: Media {
    var fileURL: URL?
    var image: UIImage?
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.image = loadImage(from: fileURL)
    }
    init(image: UIImage) {
        self.image = image
    }
    
    private func loadImage(from fileURL: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
}

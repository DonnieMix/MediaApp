//
//  MediaCell.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import Foundation
import UIKit

class MediaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView?
    var media: Media?
    var index: Int?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        imageView?.contentMode = .scaleAspectFill
        imageView?.frame = contentView.bounds
    }
    
    func configure(with media: Media, index: Int) {
        self.index = index
        guard let fileURL = media.fileURL else { return }
        switch fileURL.pathExtension {
        case "jpg":
            let photo = media as? Photo
            imageView?.image = photo?.image
        case "mp4":
            let video = media as? Video
            imageView?.image = video?.thumbnail
        default:
            print("Error: Couldn't load thumbnail because of unknown type of file")
        }
    
            
    }
}


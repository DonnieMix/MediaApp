//
//  MediaManager.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import Foundation
import UIKit

class MediaManager: NSObject {
    private var medias: [Media] = []
    
    var sortedMedia: [Media] { get { getSortedMedia() }}
    
    static let shared = MediaManager()
    
    private override init() {
        super.init()
        loadRecordedData()
    }
    
    private func getSortedMedia() -> [Media] {
        updateManagerData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"

        let sortedMedia = medias.sorted(by: { (media1, media2) -> Bool in
            guard let url1 = media1.fileURL,
                  let url2 = media2.fileURL else { return false }
            let fileName1 = url1.deletingPathExtension().lastPathComponent
            let fileName2 = url2.deletingPathExtension().lastPathComponent
            if let date1 = dateFormatter.date(from: fileName1),
               let date2 = dateFormatter.date(from: fileName2) {
                return date1 < date2
            }
            return false
        })

        return sortedMedia
    }
    
    func updateManagerData() {
        self.medias = []
        self.loadRecordedData()
    }
    
    private func loadRecordedData() {
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let mediaFiles = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let videoFiles = mediaFiles.filter { $0.pathExtension == "mp4" }
            let photoFiles = mediaFiles.filter { $0.pathExtension == "jpg" }
            for videoFile in videoFiles {
                let video = Video(fileURL: videoFile)
                medias.append(video)
            }
            for photoFile in photoFiles {
                let photo = Photo(fileURL: photoFile)
                medias.append(photo)
            }
        } catch {
            print("Error loading recorded videos: \(error.localizedDescription)")
        }
    }
    
    func deleteMedia(at index: Int) {
        guard (0..<medias.count) ~= index else { return }
        let media = medias[index]
        let fileManager = FileManager.default
        do {
            guard let url = media.fileURL else { return }
            try fileManager.removeItem(at: url)
            medias.remove(at: index)
        } catch {
            print("Error deleting video: \(error.localizedDescription)")
        }
    }
    
    func makeVideoQueue() -> [Video] {
        let filteredMedia = sortedMedia.filter { $0 is Video }
        var videos: [Video] = []
        for item in filteredMedia {
            guard let video = item as? Video else { return [] }
            videos.append(video)
        }
        return videos
    }
}

extension MediaManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell

        let media = sortedMedia[indexPath.item]
        
        cell.configure(with: media, index: indexPath.item)
        
        return cell
    }
}

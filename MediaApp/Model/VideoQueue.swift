//
//  VideoQueue.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 10.10.2023.
//

import Foundation

class VideoQueue {
    
    var videos: [Video]
    var currentIndex: Int
    
    init(videos: [Video], currentVideo: Video) {
        self.videos = videos
        self.currentIndex = VideoQueue.defineIndex(videos: videos, from: currentVideo)
    }
    
    static func defineIndex(videos: [Video], from currentVideo: Video) -> Int {
        for i in (0..<videos.count) {
            if currentVideo.fileURL == videos[i].fileURL {
                return i
            }
        }
        return -1
    }
    
    func currentVideo() -> Video {
        return videos[currentIndex]
    }
    
    func hasPrevious() -> Bool {
        return currentIndex > 0
    }
    func hasNext() -> Bool {
        return currentIndex < videos.count - 1
    }
    
    func previousVideo() -> Video? {
        guard hasPrevious() else { return nil }
        currentIndex -= 1
        return videos[currentIndex]
        
    }
    func nextVideo() -> Video? {
        guard hasNext() else { return nil }
        currentIndex += 1
        return videos[currentIndex]
    }
}

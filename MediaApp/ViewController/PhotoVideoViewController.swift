//
//  PhotoVideoViewController.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 10.10.2023.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

class PhotoVideoViewController: UIViewController {
    
    @IBOutlet var rootView: UIView!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoControlsView: UIView!
    var videoQueue: VideoQueue?
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var media: Media?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRightGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        view.addGestureRecognizer(swipeRightGestureRecognizer)
    
        if let photo = media as? Photo {
            displayPhoto(photo: photo)
        } else if let video = media as? Video,
                  let url = video.fileURL{
            playVideo(videoURL: url)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let sublayers = videoView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.frame = videoView.bounds
            }
        }
    }
    
    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: view)
        if gesture.state == .ended && velocity.x > 0 {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func displayPhoto(photo: Photo) {
        if let image = photo.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = rootView.bounds
            rootView.addSubview(imageView)
        }
    }
    
    func playVideo(videoURL: URL) {
        player.pause()
        playerLayer.removeFromSuperlayer()
        player = AVPlayer(url: videoURL)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.handleVideoPlaybackCompletion()
        }
    }
    
    func handleVideoPlaybackCompletion() {
        guard let videoQueue else { return }
        
        if let nextVideo = videoQueue.nextVideo(),
           let url = nextVideo.fileURL {
            playVideo(videoURL: url)
        }
    }
    
    func previousVideo() {
        guard let videoQueue else { return }
        if let previousVideo = videoQueue.previousVideo(),
           let url = previousVideo.fileURL {
            playVideo(videoURL: url)
        }
    }
    
    func nextVideo() {
        guard let videoQueue else { return }
        if let nextVideo = videoQueue.nextVideo(),
           let url = nextVideo.fileURL {
            playVideo(videoURL: url)
        }
    }
    @IBSegueAction func emberSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: VideoControlsView(viewController: self))
    }
}

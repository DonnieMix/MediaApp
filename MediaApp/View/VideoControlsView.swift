//
//  PhotoVideoView.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import SwiftUI

struct VideoControlsView: View {
    @State var viewController: PhotoVideoViewController
    
    @State private var isPlaying = true
    @State private var volume: Float = 1.0
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying ? viewController.player.pause() : viewController.player.play()
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
            }
            Spacer()
            Button(action: {
                if let queue = viewController.videoQueue,
                   queue.hasPrevious() {
                    viewController.previousVideo()
                    isPlaying = true
                    viewController.player.volume = volume
                }
            }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 30))
            }
            Button(action: {
                if let queue = viewController.videoQueue,
                   queue.hasNext() {
                    viewController.nextVideo()
                    isPlaying = true
                    viewController.player.volume = volume
                }
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 30))
            }
            Spacer()
            Button(action: {
                volume = volume == 0 ? 1.0 : 0
                viewController.player.volume = volume
            }) {
                Image(systemName: volume == 0 ? "speaker.slash.fill" : "speaker.fill")
                    .font(.system(size: 30))
            }
        }
        .foregroundColor(.white)
    }
}


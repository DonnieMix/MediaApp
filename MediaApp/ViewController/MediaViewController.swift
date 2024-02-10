//
//  MediaViewController.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 09.10.2023.
//

import Foundation
import UIKit

class MediaViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    let mediaManager = MediaManager.shared
    
    var selectedMedia: Media?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacing: CGFloat = 20
        let columnCount: CGFloat = 3
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let itemWidth = (containerWidth - (columnCount - 1) * CGFloat(spacing)) / columnCount
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(itemWidth))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: .fixed(spacing / 2),
                top: .fixed(spacing / 2),
                trailing: .fixed(0),
                bottom: .fixed(spacing / 2)
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemWidth))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: .fixed(0),
                top: .fixed(0),
                trailing: .fixed(0),
                bottom: .fixed(spacing / 2))
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaManager.sortedMedia.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        
        let media = mediaManager.sortedMedia[indexPath.item]
        cell.configure(with: media, index: indexPath.item)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = mediaManager.sortedMedia[indexPath.item]
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let point = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView?.indexPathForItem(at: point) {
            let alertController = UIAlertController(title: "Media Options", message: nil, preferredStyle: .actionSheet)
            
            let saveAction = UIAlertAction(title: "Save to Gallery", style: .default) { action in
                let media = MediaManager.shared.sortedMedia[indexPath.item]
                if let photo = media as? Photo,
                   let image = photo.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                } else if let video = media as? Video,
                          let url = video.fileURL {
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
                }
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                MediaManager.shared.deleteMedia(at: indexPath.item)
                self.collectionView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(saveAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Photo Video Open" {
            if let photoVideoViewController = segue.destination as? PhotoVideoViewController {
                if let indexPaths = self.collectionView.indexPathsForSelectedItems,
                   let indexPath = indexPaths.first {
                    self.selectedMedia = mediaManager.sortedMedia[indexPath.item]
                }
                if let selectedMedia {
                    photoVideoViewController.media = selectedMedia
                    if let currentVideo = selectedMedia as? Video {
                        photoVideoViewController.videoQueue = VideoQueue(videos: MediaManager.shared.makeVideoQueue(), currentVideo: currentVideo)
                    }
                }
            }
        }
    }
}

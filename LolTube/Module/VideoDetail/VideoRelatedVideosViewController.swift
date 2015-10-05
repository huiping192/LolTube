//
//  VideoRelatedVideosViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/4/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class VideoRelatedVideosViewController:VideoCollectionViewController {
    
    var videoId:String!
    
    private let imageLoadingOperationQueue = NSOperationQueue()
    
    var viewModel:VideoRelatedVideosViewModel!
    
    override var emptyDataTitle:String{
        return NSLocalizedString("HistoryEmptyData", comment: "")
    }
   
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = VideoRelatedVideosViewModel(videoId: videoId)
        return viewModel
    }
    
    override var cellCount: Int {
         return 1
    }
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: VideoRelatedVideoCell.self)
        let video = viewModel.videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text =  video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: VideoRelatedVideoCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}
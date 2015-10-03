//
//  TwitchStreamListViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/26/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit


class TwitchStreamListViewController: VideoCollectionViewController {
    
    var viewModel:TwitchStreamListViewModel!
    let imageLoadingOperationQueue = NSOperationQueue()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventTracker.trackViewContentView(viewName: "Twitch Stream List", viewType: TwitchStreamListViewController.self)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = TwitchStreamListViewModel()
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: VideoCellectionViewCell.self)
        
        let stream = viewModel.streamList[indexPath.row]
        
        cell.titleLabel.text = stream.title
        cell.channelLabel.text = stream.displayName
        cell.viewCountLabel.text = stream.viewersString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = stream.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: VideoCellectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let stream = viewModel.streamList[indexPath.row]
        stream.selectedAction(sourceViewController: self)
    }
    
}
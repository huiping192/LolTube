//
//  TodayViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/25/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter

let kMaxCellNumber: Int = 5

let kCellId: String = "videoCell"

let kCellHeight: CGFloat = 60.0

// scheme
let kLolTubeSchemeHost: String = "loltube://"

let kLolTubeSchemeVideoPath: String = ""

class TodayViewController:UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var tableViewModel: TodayVideoTableViewModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let channelService: ChannelService = ChannelService()
        self.tableViewModel = TodayVideoTableViewModel(channelIds: channelService.channelIds())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //load cache data
        self.tableViewModel.updateCacheDataWithSuccess({[weak self](hasCacheData: Bool) -> Void in
            if hasCacheData {
                self?.p_reloadData()
            }
        })
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: (NCUpdateResult) -> Void) {
        self.tableViewModel.updateWithSuccess({[weak self](hasNewData: Bool) -> Void in
            self?.p_reloadData()
            completionHandler(hasNewData ? .NewData : .NoData)
            }, failure: {(error: NSError) -> Void in
                completionHandler(.Failed)
        })
    }
    
    func p_reloadData() {
        self.tableView.reloadData()
        self.tableView.tableFooterView = self.p_tableViewFootView()
        self.preferredContentSize = self.tableView.contentSize
    }
    
    func p_tableViewFootView() -> UIView? {
        if self.tableViewModel.items?.count ?? 0 <= kMaxCellNumber {
            return nil
        }
        let moreInformationLabel: UILabel = UILabel()
        moreInformationLabel.frame = CGRectMake(18, 0, self.tableView.frame.size.width, kCellHeight)
        moreInformationLabel.textColor = UIColor.whiteColor()
        moreInformationLabel.font = UIFont.systemFontOfSize(16)
        moreInformationLabel.text = String(format: NSLocalizedString("VideoWidgetMoreVideos",comment: "Check %d more videos on LolTube"), self.tableViewModel.items?.count ?? 0 - kMaxCellNumber)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreInformationLabelTapped))
        moreInformationLabel.addGestureRecognizer(tapGestureRecognizer)
        moreInformationLabel.userInteractionEnabled = true
        return moreInformationLabel
    }
    
    func moreInformationLabelTapped() {
        self.extensionContext?.openURL(NSURL(string: kLolTubeSchemeHost)!, completionHandler: nil)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.items?.count ?? 0 > kMaxCellNumber ? kMaxCellNumber : self.tableViewModel.items?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kCellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath)
        guard let  cellVo: RSVideoListTableViewCellVo = self.tableViewModel.items?[Int(indexPath.row)]  else {
            return  cell
        }
        cell.imageView?.asynLoadingImageWithUrlString(cellVo.defaultThumbnailUrl, placeHolderImage: UIImage(named: "DefaultThumbnail")!)
        cell.textLabel?.text = cellVo.title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        guard let cellVo = self.tableViewModel.items?[Int(indexPath.row)]  else {
            return
        }
        let urlString: String = cellVo.videoId != nil ? "\(kLolTubeSchemeHost)\(kLolTubeSchemeVideoPath)\(cellVo.videoId)" : kLolTubeSchemeHost
        self.extensionContext?.openURL(NSURL(string: urlString)!, completionHandler: nil)
    }
}
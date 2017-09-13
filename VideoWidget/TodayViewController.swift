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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //load cache data
        self.tableViewModel.updateCacheDataWithSuccess({[weak self](hasCacheData: Bool) -> Void in
            if hasCacheData {
                self?.p_reloadData()
            }
        })
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        self.tableViewModel.updateWithSuccess({[weak self](hasNewData: Bool) -> Void in
            self?.p_reloadData()
            completionHandler(hasNewData ? .newData : .noData)
            }, failure: {(error: NSError) -> Void in
                completionHandler(.failed)
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
        moreInformationLabel.frame = CGRect(x: 18, y: 0, width: self.tableView.frame.size.width, height: kCellHeight)
        moreInformationLabel.textColor = UIColor.white
        moreInformationLabel.font = UIFont.systemFont(ofSize: 16)
        moreInformationLabel.text = String(format: NSLocalizedString("VideoWidgetMoreVideos",comment: "Check %d more videos on LolTube"), self.tableViewModel.items?.count ?? 0 - kMaxCellNumber)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreInformationLabelTapped))
        moreInformationLabel.addGestureRecognizer(tapGestureRecognizer)
        moreInformationLabel.isUserInteractionEnabled = true
        return moreInformationLabel
    }
    
    func moreInformationLabelTapped() {
        self.extensionContext?.open(URL(string: kLolTubeSchemeHost)!, completionHandler: nil)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.items?.count ?? 0 > kMaxCellNumber ? kMaxCellNumber : self.tableViewModel.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath)
        guard let  cellVo: RSVideoListTableViewCellVo = self.tableViewModel.items?[Int(indexPath.row)]  else {
            return  cell
        }
        cell.imageView?.asynLoadingImage(withUrlString: cellVo.defaultThumbnailUrl, placeHolderImage: UIImage(named: "DefaultThumbnail")!)
        cell.textLabel?.text = cellVo.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cellVo = self.tableViewModel.items?[Int(indexPath.row)]  else {
            return
        }
        let urlString: String = cellVo.videoId != nil ? "\(kLolTubeSchemeHost)\(kLolTubeSchemeVideoPath)\(cellVo.videoId)" : kLolTubeSchemeHost
        self.extensionContext?.open(URL(string: urlString)!, completionHandler: nil)
    }
}

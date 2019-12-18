//
//  TwitchStreamViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/24/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

class TwitchStreamViewController: UIViewController {
    
//    @IBOutlet fileprivate weak var webView:UIWebView!{
//        didSet{
//            webView.allowsInlineMediaPlayback = true
//            webView.mediaPlaybackRequiresUserAction = false
//            webView.scrollView.isScrollEnabled = false
//            webView.scalesPageToFit = false
//            webView.delegate = self
//            if #available(iOS 9, *) {
//                webView.allowsPictureInPictureMediaPlayback = false
//            }
//        }
//    }
    
//    @IBOutlet fileprivate weak var chatWebView:UIWebView!
    
    @IBOutlet fileprivate weak var nameLabel:UILabel!
    @IBOutlet fileprivate weak var titleLabel:UILabel!
    @IBOutlet fileprivate weak var viewersLabel:UILabel!
    @IBOutlet fileprivate weak var viewCountLabel:UILabel!
    @IBOutlet fileprivate weak var followersLabel:UILabel!
    @IBOutlet fileprivate weak var thumbnailImageView:UIImageView!
    @IBOutlet fileprivate weak var loadingIndicatorView:UIActivityIndicatorView!
    
    
    let operationQueue = OperationQueue()
    
    var stream:TwitchStream!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventTracker.trackViewContentView(viewName: "Twitch Stream", viewType: TwitchStreamViewController.self, viewId: stream.name)

        nameLabel.text = stream.displayName
        titleLabel.text = stream.title
        viewersLabel.text = stream.viewersString
        viewCountLabel.text = stream.viewCountString
        followersLabel.text = stream.followersString
        
        let imageLoadingOperation = ImageLoadOperation(url: stream.logo){
            [weak self] image in
            self?.thumbnailImageView.image = image
        }
        operationQueue.addOperation(imageLoadingOperation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        loadWebView(self.webView, fileName: "Twitch-iframe-player")
    }
    
//    fileprivate func loadWebView(_ webView:UIWebView,fileName:String){
//        let htmlTemplatePath = Bundle.main.path(forResource: fileName, ofType: "html")
//        let htmlTemplate = try! NSString(contentsOfFile: htmlTemplatePath!, encoding: String.Encoding.utf8.rawValue)
//        let playerSize = self.playerSize()
//        let embedHTML = NSString(format: htmlTemplate, playerSize.width, playerSize.height ,stream.name)
//        webView.loadHTMLString(embedHTML as String, baseURL: nil)
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self]_ in
            guard let strongSelf = self else {
                return
            }
            
//            let playerSize = strongSelf.playerSize()
//            strongSelf.webView.stringByEvaluatingJavaScript(from: "document.getElementById('player').width = '\(playerSize.width)'")
//            strongSelf.webView.stringByEvaluatingJavaScript(from: "document.getElementById('player').height = '\(playerSize.height)'")
//
            })
    }
    
//    fileprivate func playerSize() -> CGSize {
//        let width:CGFloat
//        let height:CGFloat
//        
//        let webViewWidth = webView.frame.width
//        let webViewHeight = webView.frame.height
//        
//        if webViewWidth / webViewHeight > 16.0 / 9.0 {
//            width = floor(webViewHeight * 16.0 / 9.0)
//            height = webViewHeight
//        } else {
//            width = webViewWidth
//            height = floor(webViewWidth * 9.0 / 16.0)
//        }
//        
//        return CGSize(width: width, height: height)
//    }
}

extension TwitchStreamViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        if !loadingIndicatorView.isAnimating {
            loadingIndicatorView.startAnimating()
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        if loadingIndicatorView.isAnimating {
            loadingIndicatorView.stopAnimating()
        }
    }
    
}

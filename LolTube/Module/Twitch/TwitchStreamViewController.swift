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
    
    @IBOutlet private weak var webView:UIWebView!{
        didSet{
            webView.allowsInlineMediaPlayback = true
            webView.mediaPlaybackRequiresUserAction = false
            webView.scrollView.scrollEnabled = false
            webView.scalesPageToFit = false
            webView.delegate = self
            if #available(iOS 9, *) {
                webView.allowsPictureInPictureMediaPlayback = false
            }
        }
    }
    
    @IBOutlet private weak var chatWebView:UIWebView!
    
    @IBOutlet private weak var nameLabel:UILabel!
    @IBOutlet private weak var titleLabel:UILabel!
    @IBOutlet private weak var viewersLabel:UILabel!
    @IBOutlet private weak var viewCountLabel:UILabel!
    @IBOutlet private weak var followersLabel:UILabel!
    @IBOutlet private weak var thumbnailImageView:UIImageView!
    @IBOutlet private weak var loadingIndicatorView:UIActivityIndicatorView!
    
    
    let operationQueue = NSOperationQueue()
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadWebView(self.webView, fileName: "Twitch-iframe-player")
    }
    
    private func loadWebView(webView:UIWebView,fileName:String){
        let htmlTemplatePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "html")
        let htmlTemplate = try! NSString(contentsOfFile: htmlTemplatePath!, encoding: NSUTF8StringEncoding)
        let playerSize = self.playerSize()
        let embedHTML = NSString(format: htmlTemplate, playerSize.width, playerSize.height ,stream.name)
        webView.loadHTMLString(embedHTML as String, baseURL: nil)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: {
            [weak self]_ in
            guard let strongSelf = self else {
                return
            }
            
            let playerSize = strongSelf.playerSize()
            strongSelf.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('player').width = '\(playerSize.width)'")
            strongSelf.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('player').height = '\(playerSize.height)'")
            
            })
    }
    
    private func playerSize() -> CGSize {
        let width:CGFloat
        let height:CGFloat
        
        let webViewWidth = webView.frame.width
        let webViewHeight = webView.frame.height
        
        if webViewWidth / webViewHeight > 16.0 / 9.0 {
            width = floor(webViewHeight * 16.0 / 9.0)
            height = webViewHeight
        } else {
            width = webViewWidth
            height = floor(webViewWidth * 9.0 / 16.0)
        }
        
        return CGSize(width: width, height: height)
    }
}

extension TwitchStreamViewController: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        if !loadingIndicatorView.isAnimating() {
            loadingIndicatorView.startAnimating()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        if loadingIndicatorView.isAnimating() {
            loadingIndicatorView.stopAnimating()
        }
    }
    
}

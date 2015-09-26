//
//  TwitchService.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AFNetworking
import JSONModel

class TwitchService: HttpService {
    private let clientId = "30hu8c5b2scf27lmhsbvyq7ni7eqv6y"
    
    private let steamListUrl = "https://api.twitch.tv/kraken/streams"
    
    func steamList(pageCount pageCount:Int, pageNumber:Int,success: (RSStreamListModel -> Void)?, failure: ((NSError) -> Void)?) {
        let params:[String:AnyObject] = [
            "game": "League of Legends",
            "limit" : pageCount,
            "offset" : pageNumber
        ]
        
        request(steamListUrl, queryParameters: params, jsonModelClass: RSStreamListModel.self, success: success, failure: failure)
    }
}
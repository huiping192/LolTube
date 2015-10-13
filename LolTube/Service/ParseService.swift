//
//  ParseService.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/11/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import Parse

class ParseService {
    func saveSearch(searchText: String) {
        guard let localization = NSBundle.mainBundle().preferredLocalizations.first else {
            return
        }
        let search = SearchModel(text: searchText, localization:localization)        
        search.saveInBackground()
    }
    
    func topSearchList() -> [String]? {
        guard let localization = NSBundle.mainBundle().preferredLocalizations.first else {
            return nil
        }
        
        let searchQuery = SearchModel.query()
        searchQuery?.whereKey("localization", equalTo: localization)
        let then = NSDate(timeIntervalSinceNow: -2 * 24 * 60 * 60)
        searchQuery?.whereKey("updatedAt", equalTo: then)
        
        guard let searchModelList =  (try? searchQuery?.findObjects()) as? [SearchModel] else {
            return nil
        }
        
        let searchStringList = searchModelList.map{ $0.text }
        return Array(uniq(searchStringList).prefix(5))
    }
}
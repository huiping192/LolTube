//
// Created by 郭 輝平 on 3/13/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation

class Channel: Hashable {
    var channelId: String!
    var title: String?

    var thumbnailUrl: String?

    init() {

    }

    var hashValue: Int {
        return 1
    }
}

func ==(lhs: Channel, rhs: Channel) -> Bool {
    return lhs.channelId == rhs.channelId
}
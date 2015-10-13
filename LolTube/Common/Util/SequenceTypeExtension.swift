//
//  SequenceTypeExtension.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/17/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

func uniq<S: SequenceType, E: Hashable where E==S.Generator.Element>(source: S) -> [E] {
    var seen: [E:Bool] = [:]
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}
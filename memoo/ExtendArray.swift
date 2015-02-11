//
//  ExtendArray.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/02/05.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import UIKit

extension Array {
        mutating func shuffle() {
            for i in 0..<(count - 1) {
                
                let j = Int(arc4random_uniform(UInt32(count - i))) + i
                
                swap(&self[i], &self[j])
            }
            
            println(self)
        }
}


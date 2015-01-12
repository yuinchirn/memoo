//
//  Memo.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/01/12.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import Foundation

import Realm

class Memo : RLMObject {
    dynamic var id = 0
    dynamic var body = ""
    dynamic var remindFlg = false
    dynamic var deleteFlg = false
    dynamic var createDate = ""
    dynamic var updateDate = ""
}

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
    dynamic var id = ""
    dynamic var body = ""
    dynamic var remindFlg = false
    dynamic var deleteFlg = false
    dynamic var createDate = ""
    dynamic var updateDate = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    // 全ての値を返します。
    class func find(id:String) -> Memo? {
        let result = Memo.objectsWithPredicate(NSPredicate(format: "id = %@", id))
        if let memos = result {
            return memos.firstObject() as? Memo
        }
        return nil
    }
    
    // 指定したリマインドフラグに一致した値を返します。
    class func findByRemindFlg(remindFlg:Bool) -> Memo? {
        let result = Memo.objectsWithPredicate(NSPredicate(format: "remindFlg = %@", remindFlg))
        if let memos = result {
            return memos.firstObject() as? Memo
        }
        return nil
    }
}

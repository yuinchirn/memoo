//
//  EditMemoViewController.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/01/12.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import UIKit
import Realm

class EditMemoViewController: UIViewController {

    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 「×」ボタンのAction:メモリストへ戻る
    @IBAction func backToListView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 「save」ボタンのAction:メモ内容を更新、メモリストへ戻る
    @IBAction func updateMemo(sender: AnyObject) {
        
        // メモ内容の保存
        let realm = RLMRealm.defaultRealm()
        let memo = Memo()
        memo.body = memoTextView.text
        
        realm.transactionWithBlock() {
            realm.addObject(memo)
        }
        
        for realmBook in Memo.allObjects() {
            // book name:realm sample
            println("DB中身:\((realmBook as Memo).body)")
        }
        
        // メモリストへ
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

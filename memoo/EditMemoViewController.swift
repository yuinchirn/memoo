//
//  EditMemoViewController.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/01/12.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import UIKit
import Realm

class EditMemoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var memoTextView: UITextView!
    
    var index: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {

        if index == nil {
            return
        }
        
        let memo = Memo()
        var bodys = Array<String>()
        var dates = Array<String>()
        
        for realmBook in Memo.allObjects(){
            bodys.append(((realmBook as Memo).body))
        }
        
        if (!bodys.isEmpty) {
            memoTextView.text? = bodys[index!]
        }
    }
    
    // 「×」ボタンのAction:メモリストへ戻る
    @IBAction func backToMemoList(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 「save」ボタンのAction:メモ内容を更新、メモリストへ戻る
    // TODO saveとupdateの切り分け
    @IBAction func updateMemo(sender: AnyObject) {
        
        // メモ内容の保存
        let realm = RLMRealm.defaultRealm()
        let memo = Memo()
        memo.body = memoTextView.text
        
        // 作成時間
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        println(dateFormatter.stringFromDate(now)) // -> Jun 24, 2014, 11:01:31 AM
        memo.createDate = dateFormatter.stringFromDate(now)
        
        let uuid = NSUUID()
        memo.id = uuid.UUIDString
        
        realm.transactionWithBlock() {
            realm.addOrUpdateObject(memo)
        }
        
        // メモリストへ
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    UITextFieldが編集終了する直前に呼ばれる.
    */
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        println("textFieldShouldEndEditing:" + textField.text)
        
        self.view.endEditing(true)
        
        return true
    }

    func textViewDidChange(textView: UITextView) {
        // println("編集中")
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // println("編集終了")
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        // println("編集終了?")
        self.view.endEditing(true)
        textView.resignFirstResponder()
        return true
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

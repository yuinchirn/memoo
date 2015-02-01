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
    
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    var index: Int? = nil
    var memoId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        setToolbarOnKeyboard()
    }
    
    /* キーボードの上にtoolbarを配置します */
    func setToolbarOnKeyboard(){
        var toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        
        var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        var done = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("closeKeyBoard"))
        
        var items = NSArray(objects: spacer,done)
        toolBar.setItems(items, animated: true)
        memoTextView.inputAccessoryView = toolBar
        
    }
    
    override func viewWillAppear(animated: Bool) {

        if index == nil || memoId == nil {
            return
        }
        
        var memo = Memo.find(memoId!)
        
        // メモ内容
        memoTextView.text = memo?.body
        
        // リマインドフラグ
        if (memo?.remindFlg == nil || memo?.remindFlg == false) {
            segmentedControll.selectedSegmentIndex = 0
        } else if memo?.remindFlg == true {
            segmentedControll.selectedSegmentIndex = 1
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
        
        // 作成時間
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        println(dateFormatter.stringFromDate(now)) // -> Jun 24, 2014, 11:01:31 AM
        println("メモID：\(self.memoId)")
        
        if self.memoId == nil {
            
            println("新規作成")
            
            // 新規作成
            var memo = Memo()
            
            memo.body = memoTextView.text
            let uuid = NSUUID()
            memo.id = uuid.UUIDString
            memo.createDate = dateFormatter.stringFromDate(now)
            memo.updateDate = dateFormatter.stringFromDate(now)
            memo.remindFlg = segmentedControll.selectedSegmentIndex == 0 ? false : true
            
            realm.transactionWithBlock() {
                realm.addOrUpdateObject(memo)
            }
            
        } else {
            
            println("更新")
            
            // 更新
            var memo = Memo.find(self.memoId!)
            
            if memo == nil {
                return
            }
            
            // メモの更新r
            memo!.realm.beginWriteTransaction()
            memo!.body = memoTextView.text
            memo!.updateDate = dateFormatter.stringFromDate(now)
            memo!.realm.addOrUpdateObject(memo)
            memo!.realm.commitWriteTransaction()
        }
        
        // メモリストへ
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeKeyBoard() {
        memoTextView.resignFirstResponder()
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

    /* リマインドフラグ変更時の挙動 */
    @IBAction func segmentedControllChanged(sender: UISegmentedControl) {
        
        println(self.memoId)
        
        var memo:Memo?
        
        if (self.memoId != nil) {
            memo = Memo.find(self.memoId!)
        } else {
            memo = Memo()
        }
        
        memo?.realm?.beginWriteTransaction()
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            println("remindFlg:OFF")
            memo?.remindFlg = false
        case 1:
            println("remindFlg:ON")
            memo?.remindFlg = true
        default:
            break;  
        }
        memo?.realm?.commitWriteTransaction()
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

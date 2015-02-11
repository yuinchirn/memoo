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
    
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    var index: Int? = nil
    var memoId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        setToolbarOnKeyboard()
        registerForKeyBoardNotifications()
        
    }
    
    /* キーボードが出現、消失時の通知を登録 */
    func registerForKeyBoardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* キーボード出現時 */
    func keyboardWillShow(notification:NSNotification){
        // TODO キーボード出現時のテキストフィールドの挙動を調整
        
        var keyboardRect = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        //CGRect keyboardFrame;
        var textViewFrame:CGRect
        var overlap:CGFloat
        var keyboardMinY:CGFloat
        keyboardRect = memoTextView.superview!.convertRect(keyboardRect, fromView: nil)
        textViewFrame = memoTextView.frame
        keyboardMinY = max(0.0,CGRectGetMaxX(textViewFrame) - CGRectGetMinY(keyboardRect))
        
        var insets :UIEdgeInsets
        var keyboardMinYInsets:UIEdgeInsets
        
        var currentRect = memoTextView.caretRectForPosition(memoTextView.selectedTextRange?.start)
        println(currentRect)
        
        var currentTextRect = CGRectMake(currentRect.origin.x, currentRect.origin.y, currentRect.width, currentRect.height - keyboardMinY)
        
        overlap = CGRectGetHeight(keyboardRect)
        
        insets = UIEdgeInsetsMake(0.0, 0.0, overlap, 0.0);
        keyboardMinYInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardMinY, 0.0);
        // memoTextView.contentInset = insets
        // memoTextView.scrollIndicatorInsets = keyboardMinYInsets
        

        // アニメーション
        var duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
        var animation = {() -> Void in
            self.memoTextView.textContainerInset = insets
            self.memoTextView.scrollRectToVisible(currentRect, animated: true)
        }

        UIView.animateWithDuration(notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!, animations: animation, completion: {(Bool) -> Void in
                println("移動完了")
        })
    }
    
    func keyboardWillBeHidden() {
        memoTextView.scrollIndicatorInsets = UIEdgeInsetsZero
        memoTextView.textContainerInset = UIEdgeInsetsZero
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
        let nowDateTime = dateFormatter.stringFromDate(now)
        
        if self.memoId == nil {
            
            // テキストが空の場合は抜ける
            if memoTextView.text.isEmpty {
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            println("新規作成")
            
            // 新規作成
            var memo = Memo()
            
            memo.body = memoTextView.text
            let uuid = NSUUID()
            memo.id = uuid.UUIDString
            memo.createDate = nowDateTime
            memo.updateDate = nowDateTime
            memo.remindFlg = segmentedControll.selectedSegmentIndex == 0 ? false : true
            
            realm.transactionWithBlock() {
                realm.addOrUpdateObject(memo)
            }
            
        } else {
            
            println("更新(memoId:\(self.memoId))")
            
            // 更新
            var memo = Memo.find(self.memoId!)
            if memo == nil {
                return
            }
            
            if memoTextView.text.isEmpty {
                
                // メモ削除
                let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.deleteObjects(Memo.objectsWhere("id = '\(memo!.id)'"))
                realm.commitWriteTransaction()
                
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            // メモの更新r
            memo!.realm.beginWriteTransaction()
            memo!.body = memoTextView.text
            memo!.updateDate = nowDateTime
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

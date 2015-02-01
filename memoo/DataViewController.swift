//
//  DataViewController.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/01/01.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import UIKit
import Realm

class DataViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var dataObject: AnyObject?
    
    var ids = Array<String>()
    var bodys = Array<String>()
    var dates = Array<String>()
    var memo: Memo?
    var showResults: RLMResults?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(__FUNCTION__)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        println(RLMRealm.defaultRealmPath())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println(__FUNCTION__)
        
        // NavigationBarのTitleを変更
        if let obj: AnyObject = dataObject {
            self.naviItem.title = obj.description
        } else {
            self.naviItem.title = ""
        }
        // データを更新
        self.refreshTableData()
    }
    
    /*** データを更新します。 ***/
    func refreshTableData() {
        
        // 古いデータを削除
        ids.removeAll(keepCapacity: true)
        bodys.removeAll(keepCapacity: true)
        dates.removeAll(keepCapacity: true)
        
        // 現在保存されているメモを表示
        if self.naviItem.title == "リマインド" {
            showResults = Memo.findByRemindFlg(true)
        } else {
            showResults = Memo.findByRemindFlg(false)
        }
        
        for realmBook in showResults! {
            ids.append(((realmBook as Memo).id))
            bodys.append(((realmBook as Memo).body))
            dates.append(((realmBook as Memo).createDate))
        }
        
        // テーブルを更新
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(__FUNCTION__)
        
        if showResults == nil {
            return 0
        } else {
            return Int(showResults!.count)
        }
    }
    
    // セルの表示項目
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println(__FUNCTION__)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomTableViewCell
        
        println("dates:\(self.dates)")
        println("description:\(self.description)")
        
        if !bodys.isEmpty && !dates.isEmpty {
            // println("Dates\(dates)")
            println("Id\(ids)")
            cell.id = ids[indexPath.row]
            cell.dateLabel.text = dates[indexPath.row]
            cell.descriptionLabel.text = bodys[indexPath.row]
        }
        
        var lpgr = UILongPressGestureRecognizer(target: self, action: "showDeleteActionSheet:")
        lpgr.minimumPressDuration = 1.0;
        cell.addGestureRecognizer(lpgr)
        
        return cell
    }
    
    // セルを押したときのメソッド
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println(__FUNCTION__)
        // 選択するとアラートを表示する
        self.performSegueWithIdentifier("editMemo", sender: indexPath)
    }
    
    // TODO セルを長押しした時の挙動 -> デリートのアクションシート表示
    
    func showDeleteActionSheet(recognizer:UILongPressGestureRecognizer) {
        println("でりーと")
        
        var point = recognizer.locationInView(tableView)
        var indexPath = tableView.indexPathForRowAtPoint(point)
        println("セル番号：\(indexPath?.row)")
        println(bodys[indexPath!.row])
        
        let alertController = UIAlertController(title: "Caution", message: "Can I delete it?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (action:UIAlertAction!) -> Void in
            self.deleteMemo(indexPath!.row)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /** メモを削除 **/
    func deleteMemo(rowIndex:Int!) {
        println("削除")
        
        let memoId = ids[rowIndex]
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        realm.deleteObjects(Memo.objectsWhere("id = '\(memoId)'"))
        realm.commitWriteTransaction()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshTableData()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println(__FUNCTION__)
        if (segue.identifier == "editMemo") {
            let nextViewController: EditMemoViewController = segue.destinationViewController as EditMemoViewController
            nextViewController.index = sender.row
            
            var row = UInt(sender.row)
            var selectedMemo = Memo.allObjects().objectAtIndex(row) as Memo
            
            // 押したデータのハッシュ値
            nextViewController.memoId = selectedMemo.id
        }
    }
}


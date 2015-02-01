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
    
    // StoryBoard上の変数
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    // ローカル変数
    var dataObject: AnyObject?
    var ids = Array<String>()
    var bodys = Array<String>()
    var dates = Array<String>()
    var showResults: RLMResults?
    var refreshControl:UIRefreshControl!
    
    /*** 初回起動時の挙動***/
    override func viewDidLoad() {
        super.viewDidLoad()
        println(__FUNCTION__)
        
        // デリゲート設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // UIRefreshControl設定
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refreshRandom", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    /*** Remindテーブルビューをランダム更新 ***/
    // TODO ランダムロジック実装
    func refreshRandom() {
        println("ランダム更新")
        refreshControl.endRefreshing()
    }

    /*** 画面表示時の挙動 ***/
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
        // TODO ハードコーディングからenum管理へ
        // TODO タイムラインを時系列順へ変更
        if self.naviItem.title == "Remind" {
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
    
    /*** セルの表示行数 ***/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(__FUNCTION__)
        
        if showResults == nil {
            return 0
        } else {
            return Int(showResults!.count)
        }
    }
    
    /*** セルの表示項目 ***/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println(__FUNCTION__)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomTableViewCell
        
        if !bodys.isEmpty && !dates.isEmpty {
            cell.id = ids[indexPath.row]
            cell.dateLabel.text = dates[indexPath.row]
            cell.descriptionLabel.text = bodys[indexPath.row]
        }
        
        var lpgr = UILongPressGestureRecognizer(target: self, action: "showDeleteActionSheet:")
        lpgr.minimumPressDuration = 1.0;
        cell.addGestureRecognizer(lpgr)
        
        return cell
    }
    
    /*** セルを押したときの挙動 ***/
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println(__FUNCTION__)
        // 選択するとアラートを表示する
        self.performSegueWithIdentifier("editMemo", sender: indexPath)
    }
    
    /*** メモ削除用のアクションシート表示 ***/
    func showDeleteActionSheet(recognizer:UILongPressGestureRecognizer) {
        println(__FUNCTION__)
        
        // セル番号
        var point = recognizer.locationInView(tableView)
        var indexPath = tableView.indexPathForRowAtPoint(point)
        
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
        println(__FUNCTION__)
        
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
            
            // 押したデータのハッシュ値
            nextViewController.memoId = ids[sender.row]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


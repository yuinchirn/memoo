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
        
        self.tableView.reloadData()
        
        for realmBook in Memo.allObjects() {
            println("ID:\((realmBook as Memo).id)")
        }
        
        if let obj: AnyObject = dataObject {
            self.naviItem.title = obj.description
        } else {
            self.naviItem.title = ""
        }
        
        bodys.removeAll(keepCapacity: true)
        dates.removeAll(keepCapacity: true)
        
        // 現在保存されているメモを表示
        if self.naviItem.title == "リマインド" {
            showResults = Memo.findByRemindFlg(true)
        } else {
            showResults = Memo.findByRemindFlg(false)
        }
        
        for realmBook in showResults! {
            bodys.append(((realmBook as Memo).body))
            dates.append(((realmBook as Memo).createDate))
        }
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
            // println("Body\(bodys)")
            cell.dateLabel.text = dates[indexPath.row]
            cell.descriptionLabel.text = bodys[indexPath.row]
        }
        
        var lpgr = UILongPressGestureRecognizer(target: self, action: "showDeleteActionSheet:")
        lpgr.minimumPressDuration = 2.0;
        // println(lpgr.valueForKey("tag"))
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
        // println(recognizer.valueForKey("tag"))
        println("でりーと")
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


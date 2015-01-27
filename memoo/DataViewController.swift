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
    var dataObject: AnyObject?
    @IBOutlet weak var tableView: UITableView!
    
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
            self.dataLabel!.text = obj.description
        } else {
            self.dataLabel!.text = ""
        }
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(__FUNCTION__)
        
        return Int(Memo.allObjects().count)
    }
    
    // セルの表示項目
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println(__FUNCTION__)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomTableViewCell
        
        // 現在保存されているメモを表示
        let memo = Memo()
        var ids = Array<String>()
        var bodys = Array<String>()
        var dates = Array<String>()
        
        for realmBook in Memo.allObjects(){
            bodys.append(((realmBook as Memo).body))
            dates.append(((realmBook as Memo).createDate))
        }
        
        if !bodys.isEmpty && !dates.isEmpty {
            cell.dateLabel.text = dates[indexPath.row]
            cell.descriptionLabel.text = bodys[indexPath.row]
            
        }
        
        return cell
    }
    
    // セルを押したときのメソッド
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println(__FUNCTION__)
        // 選択するとアラートを表示する
        self.performSegueWithIdentifier("editMemo", sender: indexPath)
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


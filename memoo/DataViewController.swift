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
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let obj: AnyObject = dataObject {
            self.dataLabel!.text = obj.description
        } else {
            self.dataLabel!.text = ""
        }
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // セルの表示項目
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomTableViewCell
        
        return cell
    }
    
    // セルを押したときのメソッド
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // 選択するとアラートを表示する
        // self.performSegueWithIdentifier("detail", sender: indexPath)
        
        let realm = RLMRealm.defaultRealm()
        
        // Bookオブジェクト生成.
        let memo = Memo()
        memo.body = "てすと"
        memo.remindFlg = true
        
        
        // Bookオブジェクトを保存.
        realm.beginWriteTransaction()
        realm.addObject(memo)
        realm.commitWriteTransaction()
        
        // 先ほどのBookオブジェクトを取得
        // Class.allObjectsで全オブジェクト取得.
        for realmBook in Memo.allObjects() {
            // book name:realm sample
            println("book name:\((realmBook as Memo).body)")
        }
        
        /*
        let book2 = Book()
        book2.isbn = "999998"
        book2.name = "realm tutorial 1"
        book2.price = 1000
        
        // Blockでの保存の仕方.
        realm.transactionWithBlock() {
            realm.addObject(book2)
        }
        */
    }
}


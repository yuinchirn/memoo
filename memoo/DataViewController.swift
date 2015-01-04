//
//  DataViewController.swift
//  memoo
//
//  Created by Yuta Chiba on 2015/01/01.
//  Copyright (c) 2015年 yuinchirn. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: AnyObject?

    @IBOutlet weak var memoAreaView: UIView!
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var memoDescriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        // cell.textLabel?.text = "\(indexPath.section):\(indexPath.row)"
        // cell.imageView?.image = UIImage(named: "circle")
        return cell
    }


}


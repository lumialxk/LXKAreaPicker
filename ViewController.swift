//
//  ViewController.swift
//  LXKAreaPicker
//
//  Created by 李现科 on 16/6/5.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let areaPicker = LXKFullAreaPicker<[String:AnyObject]>(frame: view.frame)
        let helper = LXKAreaPickerHelper()
        areaPicker.areaPicker.numberOfSections = { (areaPicker: LXKAreaPicker) -> Int in
            return helper.numberOfSectionsInAreaPicker(areaPicker)
        }
        areaPicker.areaPicker.itemsInSection = { (section: Int) -> [[String:AnyObject]] in
            return helper.areaPicker(areaPicker.areaPicker, itemsInSection: section)
        }
        areaPicker.areaPicker.didSelectItem = { (indexPath: NSIndexPath) in
            if indexPath.section == 2 {
                let province = areaPicker.areaPicker.seletedItemInSection(0) as? [String:String]
                let city = areaPicker.areaPicker.seletedItemInSection(1) as? [String:String]
                let area = areaPicker.areaPicker.seletedItemInSection(2) as? [String:String]
                print(province, city, area)
                // areaPicker.dismiss()
            }
        }
        view.addSubview(areaPicker)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


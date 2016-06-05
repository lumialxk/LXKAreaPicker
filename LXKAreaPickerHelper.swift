//
//  LXKAreaPickerHelper.swift
//  SwiftPlayground
//
//  Created by 李现科 on 16/5/17.
//  Copyright © 2016年 李现科. All rights reserved.
//

import Foundation

class LXKAreaPickerHelper: LXKAreaPickerDataSource {
    
    private lazy var areaDictionary: Dictionary<String,AnyObject>? = {
        guard let url = NSBundle.mainBundle().pathForResource("area", ofType: "json") else {
            fatalError("no area json file")
        }
        if let data = try? NSData(contentsOfFile: url, options: .DataReadingMappedAlways) {
            let dic = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as! [String:AnyObject]
            return dic
        }
        return nil
    }()
    
    typealias T = [String:AnyObject]
    
    func numberOfSectionsInAreaPicker(areaPicker: LXKAreaPicker<T>) -> Int {
        return 3
    }
    
    func areaPicker(areaPicker: LXKAreaPicker<T>, itemsInSection section: Int) -> [T] {
        switch section {
        case 0:
            return areaDictionary!["province"] as! [T]
        case 1:
            if let selectedProvince = areaPicker.seletedItemInSection(0) as? [String:String] {
                if let id = selectedProvince["id"] {
                    return (areaDictionary!["city"] as! [T]).filter({ (city) -> Bool in
                        if let cityId = city["id"] as? String {
                            return cityId.hasPrefix(id[id.startIndex...id.startIndex.advancedBy(1)])
                        }
                        return false
                    })
                }
            }
            return [T]()
        case 2:
            if let selectedCity = areaPicker.seletedItemInSection(1) as? [String:String] {
                if let id = selectedCity["id"] {
                    return (areaDictionary!["district"] as! [T]).filter({ (area) -> Bool in
                        if let areaId = area["id"] as? String {
                            return areaId.hasPrefix(id[id.startIndex...id.startIndex.advancedBy(3)])
                        }
                        return false
                    })
                }
            }
            return [T]()
        default:
            return [T]()
        }
    }
    
    
}

extension Dictionary: LXKAreaPickerElement {
    var title: String? {
        if let key = "text" as? Key {
            return self[key] as? String
        }
        return nil
    }
}

//
//  LXKFullAreaPicker.swift
//  SwiftPlayground
//
//  Created by 李现科 on 16/5/27.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class LXKFullAreaPicker<T: LXKAreaPickerElement>: UIView {
    
    private let screenWidth = UIScreen.mainScreen().bounds.width
    private let screenHeight = UIScreen.mainScreen().bounds.height
    private let areaPickerHeight: CGFloat = 300.0
    private let titleFont: CGFloat = 14.0
    private let titleColor = UIColor(rgb: 0x333333)
    
    var title: String = "所在地区" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private var mask: UIView!
    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var closeButton: UIButton!
    var areaPicker: LXKAreaPicker<T>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }
    
    private func setUpSubviews() {
        
        mask = {
            var maskFrame = bounds
            maskFrame.size.height = bounds.height - areaPickerHeight - 44.0
            let mask = UIView(frame: maskFrame)
            mask.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
            let tap = UITapGestureRecognizer(target: self, action: #selector(LXKFullAreaPicker.dismiss))
            mask.addGestureRecognizer(tap)
            return mask
        }()
        
        contentView = {
            var contentViewFrame = bounds
            contentViewFrame.origin.y = bounds.height - areaPickerHeight - 44.0
            contentViewFrame.size.height = areaPickerHeight + 44.0
            let contentView = UIView(frame: contentViewFrame)
            contentView.backgroundColor = .whiteColor()
            return contentView
        }()
        
        titleLabel = {
            let label = UILabel(frame: CGRect(x: screenWidth/2.0 - 30, y: 10, width: 60, height: 30))
            label.text = title
            label.font = UIFont.systemFontOfSize(titleFont)
            label.textColor = titleColor
            return label
        }()
        
        
        
        closeButton = {
            var buttonFrame = CGRect(x: screenWidth - 7 - 30, y: 7, width: 30, height: 30)
            let button = UIButton(type: .Custom)
            button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            button.frame = buttonFrame
            button.setImage(UIImage(named: "close"), forState: .Normal)
            button.addTarget(self, action: #selector(LXKFullAreaPicker.dismiss), forControlEvents: .TouchUpInside)
            
            return button
        }()
        
        areaPicker = {
            var areaPickerFrame = contentView.bounds
            areaPickerFrame.origin.y = 44.0
            areaPickerFrame.size.height = contentView.bounds.height - 44.0
            let areaPicker = LXKAreaPicker<T>(frame: areaPickerFrame)
            return areaPicker
        }()
        
        
        addSubview(mask)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(areaPicker)
    }
    
    @objc func dismiss() {
        removeFromSuperview()
    }

}

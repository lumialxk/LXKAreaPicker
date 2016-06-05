//
//  LXKAreaPicker.swift
//  SwiftPlayground
//
//  Created by 李现科 on 16/5/17.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

protocol LXKAreaPickerDataSource {
    associatedtype T: LXKAreaPickerElement
    func numberOfSectionsInAreaPicker(areaPicker: LXKAreaPicker<T>) -> Int
    func areaPicker(areaPicker: LXKAreaPicker<T>, itemsInSection section: Int) -> [T]
}

protocol LXKAreaPickerElement {
    var title: String? { get }
}

/// 选择区域,自动覆盖下级目录
struct SeletedAreaItems<T: LXKAreaPickerElement> {
    
    private (set) var rawValue: Array<T>
    
    init(_ rawValue: [T]) {
        self.rawValue = rawValue
    }
    
    init() {
        rawValue = [T]()
    }
    
    subscript(index: Int) -> T {
        get {
            return rawValue[index]
        }
        set {
            if rawValue.endIndex > index + 1 {
                let range = index + 1...rawValue.endIndex.predecessor()
                rawValue.removeRange(range)
            } else if index == rawValue.endIndex {
                rawValue.append(newValue)
                return
            } else if index > rawValue.endIndex {
                fatalError("should add previous items firstly")
            }
            rawValue[index] = newValue
        }
    }
}

private let tableViewCellIdentifier = "tableViewCellIdentifier"
/// 标题栏文字大小
private let titleFontSize: CGFloat = 14.0
/// 标题栏文字颜色
private let titleColor = UIColor.lightGrayColor()
/// 条目文字颜色
private let itemFontSize: CGFloat = 13.0
/// 条目颜色
private let itemColor = UIColor.lightGrayColor()

@IBDesignable
class LXKAreaPicker<T: LXKAreaPickerElement>: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var titleCollectionView: UICollectionView!
    private var itemCollectionView: UICollectionView!
    private var seperatorView: UIView!
    
    private let titleCollectionViewCellIdentifier = "titleCollectionViewCellIdentifier"
    private let itemCollectionViewCellIdentifier = "itemCollectionViewCellIdentifier"
    
    
    var numberOfSections: ((areaPicker: LXKAreaPicker) -> Int)?
    var itemsInSection: ((section: Int) -> [T])?
    var didSelectItem: ((indexPath: NSIndexPath) -> ())?
    
    private var selectedItems = SeletedAreaItems<T>()
    
    /// 顶部栏高度
    @IBInspectable
    private let topBarHeight: CGFloat = 44.0
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = {
            var collectionViewFrame = bounds
            collectionViewFrame.size.height = topBarHeight
            let flowLayout = titleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = collectionViewFrame.size
            titleCollectionView.frame = collectionViewFrame
        }()

        _ = {
            let seperatorViewFrame = CGRect(x: 0.0, y: topBarHeight, width: bounds.size.width, height: 1.0)
            seperatorView.frame = seperatorViewFrame
        }()
        
        _ = {
            var collectionViewFrame = bounds
            collectionViewFrame.origin.y = topBarHeight + 1.0
            collectionViewFrame.size.height = bounds.size.height - topBarHeight - 1.0
            let flowLayout = itemCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = collectionViewFrame.size
            itemCollectionView.frame = collectionViewFrame
        }()
    }
    
    /// 初始化控件
    func setUpSubviews() {
        
        titleCollectionView = {
            var collectionViewFrame = bounds
            collectionViewFrame.size.height = topBarHeight
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.itemSize = collectionViewFrame.size
            flowLayout.minimumInteritemSpacing = 16.0
            flowLayout.scrollDirection = .Horizontal
            let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
            collectionView.registerClass(TitleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCellIdentifier)
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
            collectionView.scrollsToTop = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.backgroundColor = .whiteColor()
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        }()
        
        seperatorView = {
            let view = UIView(frame: CGRect(x: 0.0, y: topBarHeight, width: bounds.size.width, height: 1.0))
            view.backgroundColor = UIColor(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0, alpha: 1.0)
            return view
        }()
        
        itemCollectionView = {
            var collectionViewFrame = bounds
            collectionViewFrame.origin.y = topBarHeight + 1.0
            collectionViewFrame.size.height = bounds.size.height - topBarHeight - 1.0
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.itemSize = collectionViewFrame.size
            flowLayout.minimumInteritemSpacing = 0.0
            flowLayout.minimumLineSpacing = 0.0
            flowLayout.scrollDirection = .Horizontal
            let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
            collectionView.registerClass(ItemCollectionViewCell<T>.self, forCellWithReuseIdentifier: itemCollectionViewCellIdentifier)
            collectionView.scrollsToTop = false
            collectionView.pagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.backgroundColor = .whiteColor()
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        }()

        addSubview(titleCollectionView)
        addSubview(seperatorView)
        addSubview(itemCollectionView)
        
    }
    
    func dismiss() {
        removeFromSuperview()
    }
    
    /// 刷新数据
    func reloadData() {
        titleCollectionView.reloadData()
        itemCollectionView.reloadData()
    }
    
    /// 获取选中的item
    func seletedItemInSection(section: Int) -> T? {
        guard section >= 0 && section < selectedItems.rawValue.count else {
            return nil
        }
        return selectedItems[section]
    }
    
    // MARK: - UITableViewDataSource,UITableViewDelegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cell = tableView.superview as? UICollectionViewCell {
            if let indexPath = itemCollectionView.indexPathForCell(cell) {
                return itemsInSection?(section: indexPath.row).count ?? 0
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as! ItemTableViewCell
        if let collectionViewCell = tableView.superview as? UICollectionViewCell {
            if let collectionIndexPath = itemCollectionView.indexPathForCell(collectionViewCell) {
                let item = itemsInSection?(section: collectionIndexPath.row)[indexPath.row] as? LXKAreaPickerElement
                cell.item = item
                if selectedItems.rawValue.count > collectionIndexPath.row {
                    if selectedItems.rawValue[collectionIndexPath.row].title == item?.title {
                        cell.accessoryType = .Checkmark
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.superview as? UICollectionViewCell {
            if let collectionIndexPath = itemCollectionView.indexPathForCell(cell) {
                if let item = itemsInSection?(section: collectionIndexPath.row)[indexPath.row] {
                    let seletedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: collectionIndexPath.row)
                    selectedItems[collectionIndexPath.row] = item
                    reloadData()
                    let nextIndex = min(collectionIndexPath.row + 1, (numberOfSections?(areaPicker: self) ?? 1) - 1)
                    itemCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: nextIndex, inSection: 0), atScrollPosition: .None, animated: true)
                    didSelectItem?(indexPath: seletedIndexPath)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(selectedItems.rawValue.count + 1,numberOfSections?(areaPicker: self) ?? 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch collectionView {
        case titleCollectionView:
            let title = indexPath.row < selectedItems.rawValue.count ? (selectedItems[indexPath.row].title ?? "未知") : "请选择"
            let rect = (title as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options: [.UsesLineFragmentOrigin,.UsesFontLeading], attributes: [NSFontAttributeName:UIFont.systemFontOfSize(titleFontSize)], context: nil)
            return CGSize(width: CGRectGetWidth(rect) + 4.0, height: topBarHeight)
        case itemCollectionView:
            return collectionView.bounds.size
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch collectionView {
        case titleCollectionView:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(titleCollectionViewCellIdentifier, forIndexPath: indexPath) as! TitleCollectionViewCell
            let title = indexPath.row < selectedItems.rawValue.count ? (selectedItems[indexPath.row].title ?? "未知") : "请选择"
            cell.titleLabel.text = title
            return cell
        case itemCollectionView:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(itemCollectionViewCellIdentifier, forIndexPath: indexPath) as! ItemCollectionViewCell<T>
            cell.tableView.dataSource = self
            cell.tableView.delegate = self
            return cell
        default:
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == titleCollectionView {
            itemCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
        }
    }
}

class TitleCollectionViewCell: UICollectionViewCell {
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    func setUpSubviews() {
        titleLabel = {
            let label = UILabel(frame: bounds)
            label.font = UIFont.systemFontOfSize(titleFontSize)
            label.textColor = titleColor
            return label
        }()
        
        addSubview(titleLabel)
    }
}

class ItemCollectionViewCell<T: LXKAreaPickerElement>: UICollectionViewCell {
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }

    func setUpSubviews() {
        tableView = {
            let tableView = UITableView(frame: bounds)
            tableView.registerClass(ItemTableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
            tableView.tableFooterView = UIView()
            return tableView
        }()
        
        addSubview(tableView)
    }
    
    override func prepareForReuse() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.reloadData()
    }
}

class ItemTableViewCell: UITableViewCell {
    
    var itemLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var labelFrame = bounds
        labelFrame.origin.x = 16.0
        itemLabel.frame = labelFrame
    }
    
    func setUpSubviews() {
        itemLabel = {
            var labelFrame = bounds
            labelFrame.origin.x = 16.0
            let label = UILabel(frame: labelFrame)
            label.font = UIFont.systemFontOfSize(itemFontSize)
            label.textColor = itemColor
            return label
        }()
        
        addSubview(itemLabel)
    }
    
    var item: LXKAreaPickerElement? {
        didSet {
            itemLabel.text = item?.title ?? "未知"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .None
    }
}

extension UIColor {
    convenience init(rgb: Int,alpha: CGFloat = 1.0) {
        let r = CGFloat(rgb / 0x10000) / 255.0
        let g = CGFloat(rgb % 0x10000 / 0x100) / 255.0
        let b = CGFloat(rgb % 0x100) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}














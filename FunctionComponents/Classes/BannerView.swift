//

import UIKit
import FSPagerView
import SnapKit
import Then
import SDWebImage

public class BannerView: UIView {
    
    public weak var banner: FSPagerView!
    public weak var pageControl: FSPageControl!
    public var imageArray : Array<String> = []
    public var bannerSeleted: ((Int) -> ())?
    
    public var bannerNumberItems = 0
    
    // MARK: - LifeCycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetViews
    func setView() {
		
        banner = FSPagerView().then({ (v) in
            addSubview(v)
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
            v.isInfinite = true
            v.automaticSlidingInterval = 5
            v.delegate = self
            v.dataSource = self
            v.interitemSpacing = 0
            v.register(BannerItemViewCell.self, forCellWithReuseIdentifier: BannerItemViewCell.identifier)
            v.snp.makeConstraints { (make) in
                make.top.left.right.bottom.equalTo(self)
            }
        })
        
        pageControl = {
            let p = FSPageControl()
            addSubview(p)
            p.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.snp.bottom)
                make.left.equalTo(self)
                make.right.equalTo(self.snp.right).offset(-8)
                make.height.equalTo(15)
            }
            p.itemSpacing = 10
            p.interitemSpacing = 4
            p.contentHorizontalAlignment = .right
            p.setFillColor(UIColor(hexadecimalStr: "#FFFFFF", alpha: 0.6), for: .normal)
            p.setFillColor(UIColor.white, for: .selected)
            p.setPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 7, height: 2), cornerRadius: 0), for: .normal)
            p.setPath(UIBezierPath(roundedRect: CGRect(x: -4.5, y: 0, width: 16, height: 2), cornerRadius: 0), for: .selected)
            p.currentPage = 0
            return p
        }()
    }
    
    // MARK: - LoadData
    public func loadData(_ imagesArr: Array<String>) {
        imageArray.removeAll()
        imageArray.append(contentsOf: imagesArr)
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = 0
        banner.reloadData()
        DispatchQueue.main.async {
            if self.bannerNumberItems > 0 {
                self.banner.scrollToItem(at: 0, animated: false)
            }
        }
    }
    
    public func resetBannerScrool() {
        DispatchQueue.main.async {
            if self.bannerNumberItems > 0 {
                self.banner.scrollToItem(at: 0, animated: false)
            }
        }
    }
}

//  bannerStyleSetting
public extension BannerView {
    //  设置轮播时间
    func setBanner(automaticSlidingInterval: CGFloat) {
        banner.automaticSlidingInterval = automaticSlidingInterval
    }
    
    //  设置轮播按钮风格
    func setFillColor(_ fillColor: UIColor?, for state: UIControl.State) {
        pageControl.setFillColor(fillColor, for: state)
    }
}

// MARK: - FSPagerViewDataSource, FSPagerViewDelegate
extension BannerView: FSPagerViewDataSource, FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        bannerNumberItems = imageArray.count
        return imageArray.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BannerItemViewCell.identifier, at: index)
        cell.imageView?.load(with: imageArray[index], placeHolderImage: UIImage(named: "homeBannerPlaceHolder"), completion: nil)
        return cell
    }
    
    public func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        pageControl.currentPage = index
        bannerSeleted?(index)
    }
    
    public func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        pageControl.currentPage = pagerView.currentIndex
    }
}


public class BannerItemViewCell: FSPagerViewCell {
    
    static let identifier: String = "BannerItemViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    func setUI() {
        
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        contentView.layer.shadowColor = UIColor.clear.cgColor
    }
}

public extension UIColor {
    
    /**
     根据给定的16进制颜色代码生成UIColor
     
     - parameter hexString: 6位16进制颜色代码，支持前缀带“#”和"0x"的字符串
     - parameter alpha:     透明度
     */
    convenience init(hexadecimalStr: String, alpha: CGFloat = 1) {
        var hex = hexadecimalStr.lowercased().replacingOccurrences(of: "#", with: "")
        hex = hex.replacingOccurrences(of: "0x", with: "")
        
        guard hex.count == 6 else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        let startIndex = hex.startIndex
        let endindex = hex.endIndex
        let redIndex = hex.index(startIndex, offsetBy: 2)
        let redString = String(hex[startIndex..<redIndex])
        let greenString = String(hex[hex.index(startIndex, offsetBy: 2)..<hex.index(startIndex, offsetBy: 4)])
        let blueIndex = hex.index(endindex, offsetBy: -2)
        let blueString = String(hex[blueIndex...])
        
        var red:UInt32 = 0
        var green:UInt32 = 0
        var blue:UInt32 = 0
        Scanner(string: redString).scanHexInt32(&red)
        Scanner(string: greenString).scanHexInt32(&green)
        Scanner(string: blueString).scanHexInt32(&blue)
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
}

public extension UIImageView {
    
    /// 用SDWebImage加载网络图片
    /// - Parameters:
    ///   - urlStr: 图片Url地址
    ///   - placeHolderImage: 默认占位图
    ///   - completion: 回调加载完成之后的图片
    func load(with urlStr: String, placeHolderImage: UIImage? = nil, completion: ((UIImage)->())? = nil) {
        
        if urlStr.length <= 0 {
            return
        }
        let url = URL(string: urlStr)
        if let img = placeHolderImage {
            self.sd_setImage(with: url, placeholderImage: img) { (image, error, type, url) in
                if let currentImage = image {
                    completion?(currentImage)
                }
            }
        }else{
            self.sd_setImage(with: url) { (image, error, type, url) in
                if let currentImage = image {
                    completion?(currentImage)
                }
            }
        }
    }
}


//
//  MarketDetailViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/15.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import Charts
class MarketDetailViewController: UIViewController,ChartViewDelegate {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeLineView: LineChartView!
    @IBOutlet weak var changeLabel: UILabel!
    var datas:[TimeLineModel]?
    @IBOutlet weak var headerView: MarketDetailHeaderView!

    
    
    @IBOutlet weak var menuView: MarketDetailMenuView!
    @IBOutlet weak var bottomScrollView: MarketDetailScrollView!
    @IBOutlet weak var headerTopMargin: NSLayoutConstraint!

    var subViews = [UIView]()
    var starModel:MarketListModel?
    var currentY:CGFloat = 0
    var realTimeModel:RealTimeModel?
    var currentVC:MarketBaseViewController?
    @IBOutlet weak var handleMenuView: ImageMenuView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false

        requestRealTime()
        requestLineData()
        setupSubView()
        setupCustomUI()
        setIcon()
        setCustomTitle(title: "\(starModel!.name)（\(starModel!.symbol)）")
    }
    
    func setIcon() {
        var string = ""
        if starModel != nil {
            string = starModel!.pic_tail
        } else {
            return
        }

        let url = URL(string:ShareDataModel.share().qiniuHeader + string)
        iconImageView.kf.setImage(with: url)
    }
    
    func setupSubView() {
        let imageStrings = ["market_buy","market_sell","market_meetfans","market_optional"]
        var images:[UIImage] = []
        let types:[String] = ["MarketDetaiBaseInfoViewController", "MarketFansListViewController", "MarketAuctionViewController", "MarketCommentViewController"]
        let storyboard = UIStoryboard(name: "Market", bundle: nil)
        
        for (index, type) in types.enumerated() {
            let image = UIImage(named: imageStrings[index])
            images.append(image!)
            let vc = storyboard.instantiateViewController(withIdentifier: type) as! MarketBaseViewController
            addChildViewController(vc)
            vc.starCode = starModel!.symbol
            vc.starName = starModel!.name
            vc.delegate = self
            vc.view.frame = CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight - 50 - 64)
            subViews.append(vc.view)
        }
        
        let baseInfoVC = childViewControllers.first as! MarketDetaiBaseInfoViewController
        let auctionVC =  childViewControllers[2] as! MarketAuctionViewController
        baseInfoVC.refreshImageDelegate = auctionVC
        
        bottomScrollView.scrollView.delegate = self
        currentVC = childViewControllers.first as? MarketBaseViewController
        headerView.currentSubView = currentVC?.scrollView
        headerView.menuView = menuView.menuView
        headerView.timeLineView = timeLineView
        bottomScrollView.setSubViews(views: subViews)
        handleMenuView.images = images
//        handleMenuView.titles = ["获取", "回收", "粉丝见面会", "自选"]
        handleMenuView.titles = ["获取", "回收", "粉丝见面会"]

        handleMenuView.delegate = self
        currentVC = childViewControllers.first as? MarketBaseViewController
        menuView.menuView.delegate = self
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YD_CountDownHelper.shared.marketTimeLineRefresh = nil

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        YD_CountDownHelper.shared.marketTimeLineRefresh = { [weak self] (result)in
            self?.requestLineData()
            self?.requestRealTime()
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func requestLineData() {
        let requestModel = TimeLineRequestModel()
        if starModel != nil {
            requestModel.symbol = starModel!.wid
        } else {
            return
        }
        AppAPIHelper.marketAPI().requestTimeLine(requestModel: requestModel, complete: { (response) in
            if let models = response as? [TimeLineModel] {
                TimeLineModel.cacheLineData(datas: models)
                self.setData(datas: models)
            }
        }, error: errorBlockFunc())
    }
    func requestRealTime() {
        let requestModel = RealTimeRequestModel()
        let syModel = SymbolInfo()
        if starModel != nil {
            syModel.symbol = starModel!.wid
        } else  {
            return
        }
        requestModel.symbolInfos.append(syModel)
        AppAPIHelper.marketAPI().requestRealTime(requestModel: requestModel, complete: { (response) in
            if let model = response as? [RealTimeModel] {
                self.setRealTimeData(realTimeModel: model.first!)
            } 
        }) { (error) in

        }
    }
    
    func setupCustomUI() {
        changeLabel.layer.cornerRadius = 3
        changeLabel.clipsToBounds = true
        changeLabel.backgroundColor = UIColor.init(hexString: AppConst.Color.main)
        timeLineView.legend.setCustom(entries: [])
        priceLabel.textColor = UIColor.init(hexString: AppConst.Color.orange)
        timeLineView.noDataText = "暂无数据"
        timeLineView.xAxis.labelPosition = .bottom
        timeLineView.xAxis.drawGridLinesEnabled = false
        timeLineView.xAxis.drawAxisLineEnabled = false
        timeLineView.doubleTapToZoomEnabled = false
        timeLineView.scaleXEnabled = false
        timeLineView.scaleYEnabled = false
        timeLineView.xAxis.axisMinimum = 0
        timeLineView.xAxis.axisMaximum = 30
//        timeLineView.leftAxis.axisMinimum = 0
        timeLineView.xAxis.labelFont = UIFont.systemFont(ofSize: 0)
        timeLineView.leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        timeLineView.leftAxis.gridColor = UIColor.init(rgbHex: 0xf2f2f2)
        timeLineView.rightAxis.labelFont = UIFont.systemFont(ofSize: 0)
        timeLineView.delegate = self
        timeLineView.chartDescription?.text = ""
        timeLineView.rightAxis.forceLabelsEnabled = false
        timeLineView.animate(xAxisDuration: 1)
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let model:TimeLineModel = datas?[Int(entry.x)] {
            let markerView = WPMarkerLineView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 50))
            markerView.titleLabel.text = markerLineText(model: model)
            let marker = MarkerImage.init()
            marker.chartView = chartView
            marker.image = imageFromUIView(markerView)
            chartView.marker = marker
        }
    }
    
    func markerLineText(model: TimeLineModel) -> String {
        let time = Date.yt_convertDateToStr(Date.init(timeIntervalSince1970: TimeInterval(model.priceTime)), format: "MM-dd HH:mm")
        let price = String.init(format: "%.2f", model.currentPrice)
        return "\(time)\n最新价\(price)"
    }
    func imageFromUIView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage!
    }
    
    func setRealTimeData(realTimeModel:RealTimeModel) {
        realTimeModel.cacheSelf()
        self.realTimeModel = realTimeModel
        let percent = realTimeModel.pchg * 100
        priceLabel.text = String(format: "%.2f", realTimeModel.currentPrice)
        var colorString = AppConst.Color.up
        if realTimeModel.pchg < 0 {
            changeLabel.text = String(format: "%.2f/%.2f%%", realTimeModel.change, -percent)
            colorString = AppConst.Color.down
        }  else if realTimeModel.pchg == 0{
            changeLabel.text = String(format: "%.2f/%.2f%%", realTimeModel.change, -percent)
            colorString = "333333"
        } else {
            changeLabel.text = String(format: "%.2f/+%.2f%%",realTimeModel.change,percent)
        }
        priceLabel.textColor = UIColor(hexString: colorString)
        changeLabel.backgroundColor = UIColor(hexString: colorString)
    }
    
    func setData(datas:[TimeLineModel]) {
        var entrys: [ChartDataEntry] = []
        
        self.datas = datas.sorted(by: { (model1, model2) -> Bool in
            return model1.priceTime < model2.priceTime
        })
        for (index,model) in self.datas!.enumerated() {
            let entry = ChartDataEntry(x: Double(index), y: model.currentPrice)
            entrys.append(entry)
        }

        let set = LineChartDataSet(values: entrys, label: "分时图")
        set.colors = [UIColor.red]
        set.circleRadius = 0
        set.form = .empty
        set.circleHoleRadius = 0
        set.mode = .cubicBezier
        set.valueFont = UIFont.systemFont(ofSize: 0)
        set.drawFilledEnabled = true
        set.fillColor = UIColor(red: 203.0 / 255, green: 66.0 / 255, blue: 50.0 / 255, alpha: 0.5)
        let data: LineChartData  = LineChartData.init(dataSets: [set])
        timeLineView.xAxis.axisMaximum = Double(entrys.count > 30 ? entrys.count+5 : 30)
        timeLineView.data = data
        timeLineView.data?.notifyDataChanged()
        timeLineView.setNeedsDisplay()
    }
}

extension MarketDetailViewController:UIScrollViewDelegate, MenuViewDelegate, BottomItemSelectDelegate, ScrollStopDelegate{
    

    func itemDidSelectAtIndex(index:Int) {
        switch index {
        case 0:
            pushToDealPage(index:index)

        case 1:
            pushToDealPage(index:index)
        case 2:

           doGetRelam()
        case 3:
            addOptinal()
        default:
            break
        }
    }
    func doGetRelam() {
        self.getUserRealmInfo { (result) in
            if let model = result{
                let object =  model as! [String : AnyObject]
                let alertVc = AlertViewController()
                if object["realname"] as! String == ""{
                   self.showRealname()
                }else {
                    
                    self.performSegue(withIdentifier: "meetFans", sender: nil)
                }
            }
        }
    }

    
    // Segue传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "meetFans"{
            if let vc = segue.destination as? OrderStarViewController{
//                vc.starInfo = starModel
            }
        }
    }
    
    func pushToDealPage(index:Int) {
        let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Deal.rawValue, bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "DealViewController") as? DealViewController {
//            vc.starListModel = starModel
//            vc.realTimeData = realTimeModel
            vc.index = index
            let auctionVC = childViewControllers[2] as? MarketAuctionViewController
            vc.totalCount = auctionVC?.totalCount ?? 0
            navigationController?.pushViewController(vc, animated: true)
        }

    }

    func addOptinal() {
        guard starModel != nil else {
            return
        }
        AppAPIHelper.marketAPI().addOptinal(starcode: starModel!.symbol, complete: { (response) in
            
        }, error: errorBlockFunc())
    }
    
    
    func menuViewDidSelect(indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            self.bottomScrollView.scrollView.contentOffset = CGPoint(x: kScreenWidth * CGFloat(indexPath.row), y: 0)
        }
    }
    func scrollBegin() {
        bottomScrollView.scrollView.isScrollEnabled = false
    }
    func scrollStop() {
        bottomScrollView.scrollView.isScrollEnabled = true
        var contentOffset = currentVC?.scrollView?.contentOffset
        if contentOffset!.y > 400{
            contentOffset =   CGPoint(x: contentOffset!.x, y: 424)
        }
        for vc in childViewControllers {
            let viewController = vc as? MarketBaseViewController
            if viewController != currentVC {
                viewController?.scrollView?.contentOffset = contentOffset!
            }
        }
    }
    func subScrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != bottomScrollView.scrollView {
            let distance = scrollView.contentOffset.y - currentY
            if scrollView.contentOffset.y > 0 {
                if headerTopMargin.constant > -400  || distance < 0{
                    headerTopMargin.constant -= distance
                    currentY = scrollView.contentOffset.y
                } else if headerTopMargin.constant < -400{
                    headerTopMargin.constant = -400
                    currentY = 400
                }
            } else {
                headerTopMargin.constant = 0
            }
        }
     }


    

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == bottomScrollView.scrollView {
            currentVC?.scrollView?.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == bottomScrollView.scrollView {
            currentVC?.scrollView?.isScrollEnabled = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        if scrollView != bottomScrollView.scrollView {
            if scrollView.contentOffset.y > 0 {
                headerTopMargin.constant -= (scrollView.contentOffset.y - currentY)
                currentY = headerTopMargin.constant
            }
        } else {
            let index = Int(scrollView.contentOffset.x / kScreenWidth)
            let vc = childViewControllers[index] as? MarketBaseViewController
            var contentOffset = currentVC?.scrollView?.contentOffset
            if contentOffset!.y > 400{
                contentOffset =   CGPoint(x: contentOffset!.x, y: 400)
            }
            vc?.scrollView?.contentOffset = contentOffset!
            currentVC = vc
            headerView.currentSubView = currentVC?.scrollView
            menuView.menuView.selected(index: index)
        }
    }
    
}
class WPMarkerLineView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        return view
    }()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        layer.cornerRadius = 5
        layer.masksToBounds = true
        backView.frame = frame
        titleLabel.frame = CGRect.init(x: 2, y: 2, width: frame.size.width-4, height: frame.size.height-4)
        addSubview(backView)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

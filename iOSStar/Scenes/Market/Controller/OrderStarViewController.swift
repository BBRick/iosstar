//
//  OrderStarViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/17.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderType : UITableViewCell,UITextViewDelegate{
    
    // 具体时间
    @IBOutlet weak var orderAccount: UILabel!
    // 连接时间
    @IBOutlet weak var orderType: UILabel!
}

// MARK: - 反馈Cell

protocol FeedbackCellDelegate {
    
    func didSelectRules()
}

class FeedbackCell: UITableViewCell , UITextViewDelegate {
 
    var delegate : FeedbackCellDelegate?
    
    // 意见反馈
    @IBOutlet weak var feedBack: UITextView!
    
    // placeholder
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    // tips
    @IBOutlet weak var tipsTextView: UITextView!
    

    let contentStr = "    TIPS：请提前一个月申请连接。确定连接即表示您已阅读并同意《连接规则》"  as NSString
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedBack.delegate = self
        
        
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 12.0),
                          NSForegroundColorAttributeName:UIColor.colorFromRGB(0x999999)]
        let tipsAttrs  = NSMutableAttributedString(string: contentStr as String, attributes: attributes)
        let attrs = [NSForegroundColorAttributeName:UIColor(hexString: AppConst.Color.main)]
        tipsAttrs.addAttributes(attrs, range: NSMakeRange(NSString(string:contentStr).length - 6, 6))
        let range = contentStr.range(of: "《连接规则》", options: .regularExpression, range: NSMakeRange(0,contentStr.length))
        tipsAttrs.addAttribute(NSLinkAttributeName, value: "frist://", range: range)
        tipsTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(hexString: AppConst.Color.main)]
        tipsTextView.attributedText = tipsAttrs
        tipsTextView.delegate = self
        tipsTextView.isEditable = false
        tipsTextView.isScrollEnabled = false
        tipsTextView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: NSNotification.Name.UITextViewTextDidChange, object: nil);
    }
   
    // 限制不超过200字
    func textViewNotifitionAction(userInfo:NSNotification){
        let textVStr = feedBack.text as NSString;
        if (textVStr.length > 200) {
            SVProgressHUD.showErrorMessage(ErrorMessage: "备注信息不超过200字", ForDuration: 2.0, completion: nil)
            feedBack.resignFirstResponder()
            return
        }
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        textView.resignFirstResponder()
        if URL.scheme == "frist" {
            // 代理
            if self.delegate != nil {
                delegate?.didSelectRules()
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        feedBack.text = textView.text
        if textView.text == nil {
            placeHolderLabel.text = "请输入您对此次连接的其他要求200字以内... "
            placeHolderLabel.isHidden = false
        } else {
            placeHolderLabel.text = ""
            placeHolderLabel.isHidden = true
        }
    }

}

// MARK: -  网红资料Cell
class StarDataCell: UITableViewCell {
    
    // 背景图片
    @IBOutlet weak var bkImageView: UIImageView!
    // 中间内容View
    @IBOutlet weak var centerContentView: UIView!
    // 头像View
    @IBOutlet weak var iconImageView: UIImageView!
    // 名字
    @IBOutlet weak var nameLabel: UILabel!
    // 描述
    @IBOutlet weak var describeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // 设置网红信息
    func setStarInfo(model:StarSortListModel) {

        bkImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model.home_pic_tail))
        nameLabel.text = String.init(format: "%@ (%@)", model.name,model.symbol)
        iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model.pic_tail))
    }
    // 设置网红信息
    func setStarModelInfo(model:BannerDetaiStarModel) {
        bkImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model.pic_url_tail))
        describeLabel.text = model.introduction
    }
}

// MRAK: - viewDidLoad
class OrderStarViewController: UIViewController {

    // MarketDetailViewController 传过来的模型
    var starInfo:StarSortListModel?

    var starModelInfo:BannerDetaiStarModel?
    
    // OrderStartViewCell 传过来的模型
    var serviceTypeModel : ServiceTypeModel!
    
    // 获取网红服务类型的数组
    var serviceModel : [ServiceTypeModel]?
    
    // 确定连接按钮
    @IBOutlet weak var completeButton: UIButton!
    
    // 秒数价格
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // @IBOutlet weak var pageControl: UIPageControl!
    // 意见反馈
    var feedBack : UITextView!
    // 连接时间
    var orderTime: UILabel!
    // 连接地址
    var orderPalace: UILabel!
    
    // 假的框为了弹出(Date)键盘
    @IBOutlet weak var inputDateTextField: UITextField!
    
    // datePickerView
    var datePickerView = UIDatePicker()
    
    // dateToolBar
    var dateToolBar = UIToolbar()
    
    // 假的框为了弹出(city)键盘
   @IBOutlet weak var inputCityTextField: UITextField!
   
    // cityPickerView
    var cityPickerView = UIPickerView()
    
    // cityToolBar
    var cityToolBar = UIToolbar()
    
    //  cityList
    var dataCity = Array<Dictionary<String, AnyObject>>()
    
    // cityPickerView选择的row (省份)
    var selectRow = 0
    
    // cityPickerView选择的Componentow (市)
    var selectComponent = 0
     override func viewDidLoad() {
        
        super.viewDidLoad()
        completeButton.backgroundColor = UIColor(hexString: AppConst.Color.main)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        tableView.showsVerticalScrollIndicator = false
        
        setupNav()
        // 城市
        initCity()
        initCityPickerView()
        // 时间
        initDatePickerView()
        // 网红数据
        requestStarInfos()
        // 获取网红服务
        requestStarServiceTypeInfo()
        // 确定连接事件
        completeButton.addTarget(self, action: #selector(completeClick(_:)), for: .touchUpInside)
        
        // 通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // 接收连接类型发出的通知
        NotificationCenter.default.addObserver(self, selector: #selector(chooseServiceType(_:)), name:
            Notification.Name(rawValue:AppConst.chooseServiceTypeSuccess), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    // 移除通知
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:AppConst.chooseServiceTypeSuccess), object: nil)
    }
    
    // 键盘显示的通知
    func keyBoardWillShow(_ notification: Notification){
        tableView.scrollToRow(at: NSIndexPath.init(row: 4, section: 0) as IndexPath, at: .bottom, animated: true)
    }
    
    func chooseServiceType(_ notification :Notification ) {
        
        if notification.object != nil {
            let serviceType = notification.object as! ServiceTypeModel
            serviceTypeModel = serviceType
            // // print("===\(serviceTypeModel)")
            
            let strString = String.init(format:"即将消耗: %@秒",serviceType.price)
            let attrs = [NSForegroundColorAttributeName:UIColor.colorFromRGB(0xFB9938)]
            
            let attributedString  = NSMutableAttributedString(string: strString, attributes: attrs)
            let attrsM = [NSForegroundColorAttributeName:UIColor.colorFromRGB(0x666666)]
            attributedString.addAttributes(attrsM, range: NSMakeRange(0, 5))
            self.priceLabel.attributedText = attributedString
            
            orderPalace.text = serviceType.meet_city.length() == 0 ? AppConst.meetCityDefault : serviceType.meet_city
            datePickerView.minimumDate = Date.yt_convertDateStrToDate(serviceTypeModel.startdate, format: "yyyy-MM-dd")
            datePickerView.maximumDate = Date.yt_convertDateStrToDate(serviceTypeModel.enddate, format: "yyyy-MM-dd")
            orderTime.text = Date.yt_convertDateToStr(datePickerView.minimumDate!, format: "yyyy-MM-dd")
            // self.priceLabel.text = String.init(format:"即将消耗: %@秒",serviceType.price)
        }
    }
    
    // MARK: - 获取网红信息
    func requestStarInfos() {
        
        var starCode = ""
        if starInfo != nil {
            starCode = (starInfo?.symbol)!
        }
        AppAPIHelper.newsApi().requestStarInfo(code: starCode, complete: { (response) in
            if let model = response as? BannerDetaiStarModel {
                self.starModelInfo = model
                self.tableView.reloadData()
            }
        }, error: errorBlockFunc())
    }
    
    // MARK: - 获取网红服务类型
    func requestStarServiceTypeInfo() {
        var starCode = ""
        if starInfo != nil {
            starCode = (starInfo?.symbol)!
        }
        AppAPIHelper.marketAPI().requestStarServiceType(starcode: starCode, complete: { (response) in
            if let models = response as? [ServiceTypeModel] {
                self.serviceModel = models
                self.tableView.reloadData()
            }
        }) { (error) in
            self.didRequestError(error)
        }
    }
    
    
    // MARK: - 确定连接
    func completeClick(_ sender : UIButton) {
        if serviceTypeModel == nil {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请选择连接类型", ForDuration: 2.0, completion: nil)
            return;
        }
        if orderTime.text?.length() == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请选择时间", ForDuration: 2.0, completion: nil)
            return
        }
        if orderPalace.text?.length() == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "网红尚未选择连接城市，请耐心等待", ForDuration: 2.0, completion: nil)
            return
        }
        if feedBack.text.length() == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "备注信息不能为空,且不超过200字", ForDuration: 2.0, completion: nil)
            return
        }
        if feedBack.text.length() > 200 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "备注信息200字内", ForDuration: 2.0, completion: nil)
            return
        }
        SVProgressHUD.show(withStatus: "加载中")
        self.getUserRealmInfo { [weak self](result) in
            if let model = result{
                if let object =  model as? [String : AnyObject]{
                    if object["realname"] as! String == ""{
                         SVProgressHUD.dismiss()
                        self?.showRealname()
                         return
                    }else{
                    self?.docheckPayPaas()
                    }
                }
            }
        }
        
    }
    func docheckPayPaas(){
        //判断是否实名认证
        self.getUserInfo { (result) in
            if let response = result{
               
                if let object = response as? UserInfoModel{
                     SVProgressHUD.dismiss()
                    if object.is_setpwd == 1{
                       
                        let alertVc = AlertViewController()
                        alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                                            
                                            titleLabelText: "开通支付",
                                            subTitleText: "需要开通支付才能进行充值等后续操作。\n开通支付后，您可以求购网红时间，转让网红时间，\n和网红在‘星聊’中聊天，并且还能连接网红。",
                                            completeButtonTitle: "我 知 道 了") {[weak alertVc] (completeButton) in
                                                alertVc?.dismissAlertVc()
                                                
                                                
                                                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "TradePassWordVC")
                                                _ = vc as! TradePassWordVC
                                                self.navigationController?.pushViewController(vc, animated: true )
                                                return
                        }
                    }
                    else{
                        let model = OrderInformation()
                        model.orderStatus = self.serviceTypeModel.name
                        if self.starInfo != nil {
                            model.orderInfomation = String.init(format: "%@ (%@)", (self.starInfo?.name)! ,(self.starInfo?.symbol)!)
                        }
                        model.orderPrice = "\(self.serviceTypeModel.price)秒"
                        model.ordertitlename = "连接"
                        //将值传给 sharedatemodel
                        ShareDataModel.share().orderInfo = model
                        let storyboard = UIStoryboard.init(name: "Order", bundle: nil)
                        let controller = storyboard.instantiateInitialViewController() as!  UINavigationController
                        
                        
                        let rootvc = controller.viewControllers[0] as! ContainPayVC
                        
                        rootvc.showAll = false
                        
                        rootvc.resultBlock = { (result) in
                            
                            if result is String{
                                SVProgressHUD.showSuccessMessage(SuccessMessage: "密码校验成功", ForDuration: 0.5, completion: {
                                    self.domeet()
                                    controller.dismissController()
                                    
                                })
                                
                            }
                            else{
                                SVProgressHUD.showErrorMessage(ErrorMessage:  "连接已取消,请重新连接！", ForDuration: 2, completion: nil)
                            }
                        }
                        controller.modalPresentationStyle = .custom
                        controller.modalTransitionStyle = .crossDissolve
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                }
            }
        }

    }
    // 连接
    func domeet(){
        
        var starCode = ""
        if starInfo != nil {
            starCode = (starInfo?.symbol)!
        }
        let requestModel = ServiceTypeRequestModel()
        requestModel.uid = (StarUserModel.getCurrentUser()?.userinfo?.id)!
        requestModel.starcode = starCode
        requestModel.mid = serviceTypeModel.mid
        requestModel.city_name = orderPalace.text!
        requestModel.appoint_time = orderTime.text!
        requestModel.meet_type = 1
        requestModel.comment = feedBack.text
        
        AppAPIHelper.marketAPI().requestBuyStarService(requestModel: requestModel, complete: { (result) in
            
            
            if let response = result {
                if response["result"] as! Int == 1 {
                    //
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "连接成功，请耐心等待，并保持手机通话畅通", ForDuration: 2.0, completion: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        },error: errorBlockFunc())
        
    }
}
// MARK: - date相关
extension OrderStarViewController {
    
    func initDatePickerView(){
        
        datePickerView =  UIDatePicker.init(frame: CGRect.init(x: 0,
                                                               y: 0,
                                                               width: self.view.frame.size.width,
                                                               height: 120))
        inputDateTextField.inputView = datePickerView
        
        dateToolBar = UIToolbar.init(frame:  CGRect.init(x: 0,
                                                         y: self.view.frame.size.height - self.dateToolBar.frame.size.height - 44.0,
                                                         width: self.view.frame.size.width,
                                                         height: 44))
        
        inputDateTextField.inputAccessoryView = dateToolBar
        
        let local = Locale.init(identifier: "zh_CN")
        datePickerView.locale = local
        datePickerView.datePickerMode = .date
        
        // 一个月之后的时间
//        let oneDay : TimeInterval = 24 * 60 * 60 * 1
//        let afterAMonth = NSDate.init(timeIntervalSinceNow: oneDay * 31)
//        datePickerView.minimumDate = afterAMonth as Date
        
        // 确定按钮
        let sure : UIButton = UIButton.init(frame: CGRect.init(x: 0,
                                                               y: 0,
                                                               width: 40,
                                                               height: 44))
        sure.setTitle("确定", for: .normal)
        let sureItem : UIBarButtonItem = UIBarButtonItem.init(customView: sure)
        sure.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        sure.addTarget(self, action: #selector(datesureClick), for: .touchUpInside)
        
        
        let space : UIButton = UIButton.init(frame: CGRect.init(x: 40,
                                                                y: 0,
                                                                width: self.view.frame.size.width-140,
                                                                height: 44))
        space.setTitle("", for: .normal)
        let spaceItem : UIBarButtonItem = UIBarButtonItem.init(customView: space)
        
        // 取消按钮
        let cancel : UIButton = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width-44,
                                                                 y: 0,
                                                                 width: 40,
                                                                 height: 44))
        cancel.setTitle("取消", for: .normal)
        cancel.addTarget(self, action: #selector(datecancelClick), for: .touchUpInside)
        cancel.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        cancel.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        let cancelItem : UIBarButtonItem = UIBarButtonItem.init(customView: cancel)
        
        dateToolBar.setItems([sureItem,spaceItem,cancelItem], animated: true)
        
    }
}

extension OrderStarViewController {
    
    // 确定时间按钮
    func datesureClick() {
        
        // 获取选择时间的字符串
        let time = Date.yt_convertDateToStr(datePickerView.date, format: "yyyy-MM-dd")
        orderTime.text = time
        inputDateTextField.resignFirstResponder()
//        // 获取选择时间的字符串
//        let time = Date.yt_convertDateToStr(datePickerView.date, format: "yyyy-MM-dd")
//        // 现在时间的字符串
//        let nowTime = Date.yt_convertDateToStr(NSDate() as Date, format: "yyyy-MM-dd")
//    
//        // // print("选择的时间=\(time) , 现在的时间=\(nowTime)")
//        
//        // 选择的时间
//        let chooseDate = datePickerView.date
//        
//        // nowDate
//        let nowDate = NSDate() as Date
//
//        let compsMonth = Calendar.current.dateComponents([.month], from: nowDate, to: chooseDate)
//        
//        // // print("===\(String(describing: compsMonth.month))")
//        
//        // 只能选择一个月之后的时间
//        if compsMonth.month! >= 1 {
//            orderTime.text = time
//            inputDateTextField.resignFirstResponder()
//        } else {
//            SVProgressHUD.showErrorMessage(ErrorMessage: "请至少提前一个月连接", ForDuration: 2.0, completion: nil)
//            inputDateTextField.resignFirstResponder()
//            orderTime.text = ""
//            return
//
//            
//        }
//        
        // 只能选择大于今天的时间[
//        if chooseDate.timeIntervalSince(NSDate() as Date) <= 0 {
//            
//            /** 最好提示用户,且选择当前的时间*/
//            // print("不能选择之前的时间")
//            let nowTime = Date.yt_convertDateToStr(NSDate() as Date, format: "yyyy-MM-dd")
//            orderTime.text = nowTime
//            inputDateTextField.resignFirstResponder()
//            return
//            
//        } else {
//            orderTime.text = time
//            
//            inputDateTextField.resignFirstResponder()
//        }
    }
    func datecancelClick() {
        
        inputDateTextField.resignFirstResponder()
    }
}


// MARK: - city相关
extension OrderStarViewController {
    
    // 获取cityData
    fileprivate func initCity() {
        
        let address : String =  Bundle.main.path(forResource: "City", ofType: "plist")!
        
        let dic =  NSDictionary.init(contentsOfFile: address) as! [String : Array<Any>]
        
        dataCity = dic["city"]! as! Array<Dictionary<String, AnyObject>> as Array<Dictionary<String, AnyObject>>
        
        // // print(dataCity)
    }
    
    
    // cityPickerView
    fileprivate func initCityPickerView(){
        
        cityPickerView = UIPickerView.init()
        
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        
        cityToolBar = UIToolbar.init(frame:  CGRect.init(x: 0,
                                                         y: self.view.frame.size.height - self.cityToolBar.frame.size.height - 44.0,
                                                         width: self.view.frame.size.width,
                                                         height: 44))
        
        inputCityTextField.inputView = cityPickerView
        inputCityTextField.inputAccessoryView = cityToolBar
        
        // 确定按钮
        let sure : UIButton = UIButton.init(frame: CGRect.init(x: 0,
                                                               y: 0,
                                                               width: 40,
                                                               height: 44))
        sure.setTitle("确定", for: .normal)
        sure.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        sure.addTarget(self, action: #selector(sureClick), for: .touchUpInside)
        let sureItem : UIBarButtonItem = UIBarButtonItem.init(customView: sure)
        
        let space : UIButton = UIButton.init(frame: CGRect.init(x: 40, y: 0, width: self.view.frame.size.width-140, height: 44))
        space.setTitle("", for: .normal)
        let spaceItem : UIBarButtonItem = UIBarButtonItem.init(customView: space)
        
        // 取消按钮
        let cancel : UIButton = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width-44,
                                                                 y: 0,
                                                                 width: 40,
                                                                 height: 44))
        cancel.setTitle("取消", for: .normal)
        cancel.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        cancel.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        cancel.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        let cancelItem : UIBarButtonItem = UIBarButtonItem.init(customView: cancel)
        
        cityToolBar.setItems([sureItem,spaceItem,cancelItem], animated: true)
    }
}

extension OrderStarViewController {
    
    // city确定按钮事件
    func sureClick(){
    
    let dic : Dictionary = dataCity[selectComponent]
            if let name = dic["name"] as? String{
                if  let arr : Array = (dic[name] as AnyObject) as? Array<AnyObject> {
                    if let nameDic = arr[selectRow]["name"] {
                        if nameDic != nil {
                            orderPalace.text = nameDic as? String
                        }
                        inputCityTextField.resignFirstResponder()
                        selectRow = 0
                        selectComponent = 0
                        cityPickerView.selectRow(selectComponent, inComponent: 0, animated: true)
                        cityPickerView.selectRow(0, inComponent: 1, animated: true)
                    }
                }
            }
        }
    func cancelClick(){
        selectRow = 0
        selectComponent = 0
        cityPickerView.selectRow(0
            , inComponent: 0, animated: true)
        cityPickerView.selectRow(0
            , inComponent: 1, animated: true)
        
        
        inputCityTextField.resignFirstResponder()
        
    }
}

// MARK: - cityPickerView [DataSource -- Delegate]
extension OrderStarViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            
            return dataCity.count
            
        }else{
            
            let dic : Dictionary = dataCity[selectComponent]
            let name = dic["name"] as! String
            let arr : Array = dic[name] as! Array<AnyObject>
            return  arr.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            
            return  dataCity[row]["name"] as? String
            
        }else{
            
            let dic : Dictionary = dataCity[selectComponent]
            let name = dic["name"] as! String
            let arr : Array = (dic[name] as AnyObject) as! Array<AnyObject>
            let nameDic = arr[row]["name"]
            return nameDic as? String
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0{
            
            selectComponent = row
            pickerView.reloadComponent(1)
            
        }else{
            
            selectRow = row

        }
    }
}

// MARK: - 设置UI
extension OrderStarViewController {
    
    fileprivate func setupNav() {
        setCustomTitle(title: "连接网红")
    }
}

// MARK: - 导航点击事件
extension OrderStarViewController {
    
    // 右边导航栏点击事件
    @objc fileprivate func rightButtonItemClick(_ sender : Any) {
        
//        
//        let view : ShareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?.last as! ShareView
//        view.title = "你好网红"
//        view.thumbImage = "QQ"
//        view.descr = "关于你好网红"
//        view.webpageUrl = "http://www.baidu.com"
//        view.shareViewController(viewController: self)
//        
    }
}

// MARK: - tableView [DataSource -- Delegate]
extension OrderStarViewController :UITableViewDataSource,UITableViewDelegate,FeedbackCellDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 181
        }
        
        if indexPath.row == 1 {
            return 197
        }
        
        if indexPath.row == 2 {
            return ShareDataModel.share().meetSwitch == 0 ? 0 : 45
        }
        
        if indexPath.row == 3 {
            return ShareDataModel.share().meetSwitch == 0 ? 0 : 45
        }
        
        if indexPath.row == 4 {
            return 200
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell") as! StarDataCell
            // cell?.selectionStyle = .none
            if starInfo != nil {
                cell.setStarInfo(model: starInfo!)
            }
            if starModelInfo != nil {
                cell.setStarModelInfo (model:starModelInfo!)
            }
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderStartViewCell
            if self.serviceModel != nil{
                cell.setStarServiceType(serviceModel: serviceModel)
            }
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTime") as! OrderType
            orderTime = cell.orderAccount
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCity") as! OrderType
            cell.selectionStyle = .none
            orderPalace = cell.orderAccount
            return cell
        }
        if indexPath.row == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell") as! FeedbackCell
            feedBack = cell.feedBack
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        return cell!
        
    }
    
    func didSelectRules() {
        
        // print("点击了连接规则")
        let baseWebVc = BaseWebVC()
        baseWebVc.loadRequest = "http://122.144.169.219:3389/meet"
        baseWebVc.navtitle = "连接规则"
        self.navigationController?.pushViewController(baseWebVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 2 {
            
            if serviceTypeModel == nil{
              SVProgressHUD.showErrorMessage(ErrorMessage: "请选择连接类型", ForDuration: 1, completion: nil)
                return
            }
            inputDateTextField.becomeFirstResponder()
        }
        
        if indexPath.row == 3 {
            return
//            inputCityTextField.becomeFirstResponder()
        }
    }
    
}





//
//  YDSSessionViewController.swift
//  iOSStar
//
//  Created by sum on 2017/5/10.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class YDSSessionViewController: NIMSessionViewController ,UIScrollViewDelegate{
    var isbool : Bool = false
    var starcode = ""
    var starname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
          setupNavbar()
         self.navBarBgAlpha = 1
    }
    
    func setupNavbar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem.creatRightBarButtonItem(title: "连接网红须知", target: self, action: #selector(rightButtonClick))
        navigationItem.leftBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.imageWith("\u{e61a}", fontSize: CGSize.init(width: 22, height: 22), fontColor: UIColor(hexString: AppConst.Color.main)), style: .plain, target: self, action: #selector(leftItemTapped))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: AppConst.Color.main)
        if starname != "" {
         titleLabel.text = starname
        }else{
         titleLabel.text = starcode
        }
        navigationItem.leftItemsSupplementBackButton = false
       
        titleLabel.textColor = UIColor(hexString: AppConst.Color.main)
    
    }
    
    func leftItemTapped() {
        if (navigationController?.viewControllers.count)! > 1 {
           _ = navigationController?.popViewController(animated: true)
        }else{
            dismissController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShareDataModel.share().voiceSwitch = true
        
//        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ShareDataModel.share().voiceSwitch = false
         navigationController?.navigationBar.isTranslucent = false
    }
    
    func rightButtonClick() {
        let vc = BaseWebVC()
        vc.loadRequest = "http://122.144.169.219:3389/talk"
        vc.navtitle = "连接网红须知"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 170 {
            self.navBarBgAlpha = 1.0
        } else {
            self.navBarBgAlpha = 0.0
            
        }
    }
    
    override func send(_ message: NIMMessage!) {

        if let phone = UserDefaults.standard.object(forKey: "phone") as? String {
            let requestModel = ReduceTimeModel()
            requestModel.starcode = starcode
            requestModel.phone = phone
            requestModel.deduct_amount = 1
            AppAPIHelper.user().reduceTime(requestModel: requestModel, complete: { (response) in
                super.send(message)
            }, error:errorBlockFunc())
        }
    }
    
    

}

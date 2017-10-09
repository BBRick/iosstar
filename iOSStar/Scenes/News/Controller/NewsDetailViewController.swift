//
//  NewsDetailViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/4/25.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher
class NewsDetailViewController: UIViewController {

    
    @IBOutlet var shareActionTitlt: UIBarButtonItem!
    var newsModel:NewsModel?
    var urlString:String?
    var shareImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomTitle(title: "资讯详情")
//        shareActionTitlt.tintColor = UIColor.init(hexString: AppConst.Color.main)
        let webView = WKWebView(frame: CGRect(x: 0, y: 44, width: kScreenWidth, height: kScreenHeight - 44))
        UIApplication.shared.statusBarStyle = .default;

        let url = URL(string:ShareDataModel.share().qiniuHeader + newsModel!.link_url)
        let request = URLRequest(url: url!)
        webView.load(request)
        view.addSubview(webView)

    }


    @IBAction func shareAction(_ sender: Any) {
//        
//        let view : ShareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?.last as! ShareView
//        view.title = "你好网红"
//        view.thumbImage = "QQ"
//        view.descr = "关于你好网红"
//        view.webpageUrl = "http://www.baidu.com"
//        view.shareViewController(viewController: self)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

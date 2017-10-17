//
//  DiscoverViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/6.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, MenuViewDelegate{

    @IBOutlet weak var searchButton: UIBarButtonItem!
    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: kScreenHeight - 40 - 44 - 64))
        
        scrollView.contentSize = CGSize(width: kScreenWidth * 2, height: 0)
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    var menuView:YD_VMenuView?
    
    //MARK: - LiftCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.tintColor = UIColor(hexString: AppConst.Color.main)
        UIApplication.shared.isStatusBarHidden = false
        initMenuView()
        NotificationCenter.default.addObserver(self, selector: #selector(showUpdateInfo), name: NSNotification.Name(rawValue: AppConst.NoticeKey.checkUpdte.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func initMenuView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kScreenWidth / 2, height: 40)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        menuView = YD_VMenuView(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40), layout: layout)
        view.addSubview(menuView!)
        menuView?.isScreenWidth = true
        let titles = ["获取", "互动"]
        menuView?.itemData = titles as [AnyObject]?
        menuView?.reloadData()
        menuView?.delegate = self  
        view.addSubview(scrollView)
        addChildViewControllers()
    }

    func addChildViewControllers() {
        let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Discover.rawValue, bundle: nil)
        let identifiers = [BuyStarTimeViewController.className(), StarInteractiveViewController.className()]
        for (index, identifier) in identifiers.enumerated() {
            let vc = storyBoard.instantiateViewController(withIdentifier: identifier!)
            addChildViewController(vc)
            vc.view.frame = CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight - 40 - 44 - 64 )
            scrollView.addSubview(vc.view)
        }
    }
    func menuViewDidSelect(indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) { 
            self.scrollView.contentOffset = CGPoint(x: CGFloat(indexPath.row) * kScreenWidth, y: 0)
        }
       
        if indexPath.row == 1{
            if let _ = UserDefaults.standard.value(forKey: AppConst.guideKey.upDown.rawValue) as? String {
                
            }else{
                showGuideVC(.upDown, handle: { (vc)in
                    if let guideVC = vc as? GuideVC{
                        if guideVC.guideType == AppConst.guideKey.upDown{
                            guideVC.setGuideContent(.starsNews)
                            return
                        }
                        if guideVC.guideType == AppConst.guideKey.starsNews{
                            guideVC.setGuideContent(.starSearch)
                            return
                        }
                        if guideVC.guideType == AppConst.guideKey.starSearch{
                            guideVC.dismiss(animated: true, completion:nil)
                            UserDefaults.standard.set("ok", forKey: AppConst.guideKey.upDown.rawValue)
                            return
                        }
                    }
                })
            }
        }
    }
    @IBAction func searchAction(_ sender: Any) {
        if checkLogin(){
        let stroyBoard = UIStoryboard(name: AppConst.StoryBoardName.Markt.rawValue, bundle: nil)
        let vc =  stroyBoard.instantiateViewController(withIdentifier: MarketSearchViewController.className())
        navigationController?.pushViewController(vc, animated: true)
    }
    }

  
}

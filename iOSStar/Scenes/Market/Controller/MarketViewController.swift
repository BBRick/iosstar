//
//  MarketViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/4/20.
//  Copyright © 2017年 sum. All rights reserved.
//

import UIKit

class MarketViewController: UIViewController, SubViewItemSelectDelegate{

    var menuView:MarketMenuView?
    override func viewDidLoad() {
        super.viewDidLoad()
        YD_CountDownHelper.shared.start()
        setCustomTitle(title: "明星热度")
        translucent(clear: true)
        let color = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(color.imageWithColor(), for: .default)
        automaticallyAdjustsScrollViewInsets = false
        menuView = MarketMenuView(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight))
        menuView?.items = ["明星"]
        menuView?.menuView?.isScreenWidth = true
        menuView?.delegate = self
        view.addSubview(menuView!)
        perform(#selector(setTypes), with: nil, afterDelay: 0.5)

    }
    

    func selectItem(starModel: MarketListModel) {
        
        if checkLogin() {
            let storyBoard = UIStoryboard(name: "Market", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "MarketDetail") as! MarketDetailViewController
            vc.starModel = starModel
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    func setTypes() {
        menuView?.types = [MarketClassifyModel]()
    }
    
    func requestTypeList() {
        AppAPIHelper.marketAPI().requestTypeList(complete: { (response) in
            if let models = response as? [MarketClassifyModel] {
                var titles = [String]()
              //  let customModel = MarketClassifyModel()
                //customModel.name = "自选"
                //models.insert(customModel, at: 0)
                for model in models {
                    titles.append(model.name)
                }
                self.menuView?.items = titles
                self.menuView?.types = models
            }
        }, error: errorBlockFunc())
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func searchAction() {
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YD_CountDownHelper.shared.marketListRefresh = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        YD_CountDownHelper.shared.marketListRefresh = { [weak self] (result)in
            self?.menuView?.requestDataWithIndexPath()
            
        }
    }
}

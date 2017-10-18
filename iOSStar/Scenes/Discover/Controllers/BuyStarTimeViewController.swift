//
//  BuyStarTimeViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/6.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import RealmSwift

class BuyStarTimeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    lazy var backView: UIView = {
        let view = UIView(frame: self.collectionView.frame)
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: view.frame.size.height)
        view.addSubview(effectView)
        return view
    }()
    
    lazy var backImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "blank"))
        imageView.frame = CGRect(x: 50, y: 50
            , width: kScreenWidth - 100, height: kScreenHeight - 240)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var dataSouce:[StarSortListModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestStarList()
        backView.addSubview(backImageView)
        backView.sendSubview(toBack: backImageView)
        collectionView.backgroundView = backView
        collectionView.register(StarCardView.self, forCellWithReuseIdentifier: StarCardView.className())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.dataSouce?.count ?? 0 == 0 {
            requestStarList()
        }
        
        if let _ = UserDefaults.standard.value(forKey: AppConst.guideKey.feedBack.rawValue) as? String {
            
        }else{
            showGuideVC(.leftRight, handle: { (vc)in
                if let guideVC = vc as? GuideVC{
//                    if guideVC.guideType == AppConst.guideKey.feedBack{
//                        guideVC.setGuideContent(.leftRight)
//                        return
//                    }
                    guideVC.dismiss(animated: true, completion: nil)
                    UserDefaults.standard.set("ok", forKey: AppConst.guideKey.feedBack.rawValue)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func requestStarList() {
        let requestModel = StarSortListRequestModel()
        AppAPIHelper.discoverAPI().requestScrollStarList(requestModel: requestModel, complete: { (response) in
            if let model = response as? DiscoverListModel{
                self.dataSouce?.removeAll()
                self.dataSouce = model.symbol_info
                let starModel = StarSortListModel()
                starModel.home_pic_tail = model.home_last_pic_tail
                starModel.pushlish_type = -1
                self.dataSouce?.append(starModel)
                self.collectionView.reloadData()
                self.perform(#selector(self.replaceBackImage(index:)), with: nil, afterDelay: 0.5)
            }
        }, error: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            let model = dataSouce![indexPath.item]
            let vc = segue.destination
            if segue.identifier == "ToSelling" {
                if let sellingVC = vc as? SellingViewController {
                    sellingVC.starModel = model
                }
            } else {
                if let introVC = vc as? StarIntroduceViewController {
                    introVC.starModel = model
                }
            }
        }
    }
}

extension BuyStarTimeViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    
    func replaceBackImage(index:Int = 0) {
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? StarCardView
        backImageView.image = cell?.backImage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x - 6) / Int(kScreenWidth - 88)
        replaceBackImage(index: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSouce?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StarCardView.className(), for: indexPath)
        if let card = cell as? StarCardView {
            card.setStarModel(starModel: dataSouce![indexPath.row])
        }
         return cell
    }

    func toDealPage() {
    
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if checkLogin(){
            let starModel = dataSouce![indexPath.row]
            var segueString = "StarNewsVC"
            switch starModel.pushlish_type {
            case 0:
                
                segueString = "ToSelling"
            case 1:
                
                 segueString = "ToSelling"
            case 2:
                if checkLogin(){
                    let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Deal.rawValue, bundle: nil)
                    if let vc = storyBoard.instantiateViewController(withIdentifier: "DealViewController") as? DealViewController {
                        let starListModel = dataSouce![indexPath.row]
                        vc.starListModel = starListModel
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    return
                }
//                if let dealVC = UIStoryboard.init(name: "Heat", bundle: nil).instantiateViewController(withIdentifier: HeatDetailViewController.className()) as? HeatDetailViewController{
//                    let model = dataSouce?[indexPath.row]
//                    dealVC.starListModel = model
//                    _ = navigationController?.pushViewController(dealVC, animated: true)
//                    return
//                }
            default:
                ShareDataModel.share().selectStarCode = ""
                segueString = StarNewsVC.className()
                break
            }
            performSegue(withIdentifier: segueString, sender: indexPath)
        }
    }
}

//
//  HeatListViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import MJRefresh
class HeatListViewController: UITableViewController {
    var imageNames:[String]?
    var dataSource:[StarSortListModel]?
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshAutoNormalFooter()
    var Index = 1
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        rightButton.tintColor = UIColor(hexString: AppConst.Color.main)
        tableView.register(NoDataCell.self, forCellReuseIdentifier: "NoDataCell")
        tableView.reloadData()
        configImageNames()
        setupNav()
        inittableview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = UserDefaults.standard.value(forKey: AppConst.guideKey.joinToBuy.rawValue) as? String {
            
        }else{
            showGuideVC(.joinToBuy, handle: { (vc)in
                if let guideVC = vc as? GuideVC{
                    guideVC.dismiss(animated: true, completion:nil)
                    UserDefaults.standard.set("ok", forKey: AppConst.guideKey.joinToBuy.rawValue)
                }
            })
        }
    }
    
    func setupNav() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named:"white_back"), for: .normal)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let item = UIBarButtonItem(customView: button)
        navigationItem.backBarButtonItem = item
    }
    
    func inittableview(){
        Index = 1
        header.setRefreshingTarget(self, refreshingAction: #selector(didRequest(_:)))
        self.tableView!.mj_header = header
        self.tableView.mj_header.beginRefreshing()
        footer.setRefreshingTarget(self, refreshingAction: #selector(didRequestMore(_:)))
        self.tableView!.mj_footer = footer
    }

    override func didRequest(_ pageIndex: Int) {
        let requestModel = StarSortListRequestModel()

        Index = 0
        requestModel.pos = Int64((Index - 1) * 10)
        requestModel.count = 10
        AppAPIHelper.discoverAPI().requestStarList(requestModel: requestModel, complete: { (response) in
            if let models = response as? [StarSortListModel] {
                var publishModels: [StarSortListModel] = []
                for model in models{
                    if model.pushlish_type == 2{
                        publishModels.append(model)
                    }
                }
                if models.count < 10 {
                    self.footer.isHidden = true
                }
                self.tableView.mj_header.endRefreshing()
                self.dataSource = publishModels
                self.tableView.reloadData()
            }
        }) { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func didRequestMore(_ pageIndex: Int) {
        Index = Index + 1
        let requestModel = StarSortListRequestModel()
        requestModel.pos = Int64((Index - 1) * 10)
        requestModel.count = 10
        AppAPIHelper.discoverAPI().requestStarList(requestModel: requestModel, complete: { (response) in
            if let models = response as? [StarSortListModel] {
                var publishModels: [StarSortListModel] = []
                for model in models{
                    if model.pushlish_type == 2{
                        publishModels.append(model)
                    }
                }
                self.tableView.mj_footer.endRefreshing()
                self.dataSource?.append(contentsOf: publishModels)
                self.tableView.reloadData()
            }
        }) { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        let stroyBoard = UIStoryboard(name: AppConst.StoryBoardName.Markt.rawValue, bundle: nil)
        let vc =  stroyBoard.instantiateViewController(withIdentifier: MarketSearchViewController.className())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configImageNames()  {
        imageNames = []
        for index in 0...10 {
            imageNames?.append("starList_back\(index)")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.dataSource == nil ? UIScreen.main.bounds.size.height - 150 : 130
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataSource == nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataCell.className(), for: indexPath) as! NoDataCell
            cell.imageView?.image = UIImage.init(named: "nodata")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: HeatListCell.className(), for: indexPath) as! HeatListCell
        cell.update(dataSource![indexPath.row])
        cell.setBackImage(imageName: (imageNames?[indexPath.row % 10])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource?.count ?? 0 != 0 {
            if checkLogin(){
                let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Deal.rawValue, bundle: nil)
                if let vc = storyBoard.instantiateViewController(withIdentifier: "DealViewController") as? DealViewController {
                    let starListModel = dataSource![indexPath.row]
                    vc.starListModel = starListModel
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            //            performSegue(withIdentifier: "ToDeal", sender: indexPath)

        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if dataSource == nil || dataSource!.count == 0{
            return
        }
        if segue.identifier == "ToDeal" {
            let indexPath = sender as! IndexPath
            if let vc = segue.destination as? HeatDetailViewController {
                vc.imageName = imageNames![indexPath.row % 10]
                vc.starListModel = dataSource![indexPath.row]
            }
        }
    }
}

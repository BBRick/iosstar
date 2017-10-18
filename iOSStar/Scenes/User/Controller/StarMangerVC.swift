//
//  StarMangerVC.swift
//  iOSStar
//
//  Created by sum on 2017/9/12.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class StarMangerVC: UIViewController {
    
     var scrollView: UIScrollView!
    
    @IBOutlet var segment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 60 , width: self.view.frame.size.width, height: self.view.frame.size.height - 60))
        self.scrollView?.isScrollEnabled = false
        scrollView?.isPagingEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView?.contentSize = CGSize.init(width: self.view.frame.size.width*2, height: 0)
        view.addSubview(scrollView!)
        scrollView?.isPagingEnabled = true
        scrollView.contentSize = CGSize.init(width: kScreenWidth*4, height: 0)
        configView()
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        title = "持有明细"
        segment.tintColor = UIColor.init(hexString: AppConst.Color.main)
        
    }
    func  configView(){
//        for index in 0 ... 3 {
        for index in 0 ... 1 {
            
            if index == 0 {
                if let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "GetOrderStarsVC") as? GetOrderStarsVC{
                    scrollView.addSubview(vc.view)
                    
                    self.addChildViewController(vc)
                    vc.view.frame = CGRect.init(x: (CGFloat(index) * CGFloat(kScreenWidth)), y: 0, width: kScreenWidth, height: scrollView.frame.size.height)

                }
                
            }
            if index == 1{
                if let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "GetOrderStarsVC") as? GetOrderStarsVC{
                    scrollView.addSubview(vc.view)
                    vc.domeet = false
                    vc.view.frame = CGRect.init(x: (CGFloat(index) * CGFloat(kScreenWidth)), y: 0, width: kScreenWidth, height: scrollView.frame.size.height)
                    self.addChildViewController(vc)
                }
            }
            if index == 3{
                
                if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: VoiceHistoryVC.className()) as? VoiceHistoryVC{
                    scrollView.addSubview(vc.view)
                    let model = StarSortListModel()
                    model.symbol = ""
                    vc.starModel = model
                    vc.view.frame = CGRect.init(x: (CGFloat(index) * CGFloat(kScreenWidth)), y: 0, width: kScreenWidth, height: scrollView.frame.size.height)
                    self.addChildViewController(vc)
                }
            }
            
            if index == 2{
                if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: VideoHistoryVC.className()) as? VideoHistoryVC{
                    scrollView.addSubview(vc.view)
                    let model = StarSortListModel()
                    vc.starModel = model
                    vc.view.frame = CGRect.init(x: (CGFloat(index) * CGFloat(kScreenWidth)), y: 0, width: kScreenWidth, height: scrollView.frame.size.height)
                    self.addChildViewController(vc)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.selectedSegmentIndex) * kScreenWidth, y: 0), animated: true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

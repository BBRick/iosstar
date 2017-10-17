
//
//  TakeMovieVC.swift
//  iOSStar
//
//  Created by sum on 2017/8/15.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import PLShortVideoKit
import Qiniu
import SVProgressHUD
class TakeMovieVC: UIViewController ,PLShortVideoRecorderDelegate ,PLShortVideoUploaderDelegate ,PLPlayerDelegate{
    
    
    @IBOutlet var content: UILabel!
    @IBOutlet var header: UIImageView!
    @IBOutlet var name: UILabel!
    
    var didTap = false
    var q_content = ""
    var index  = 1
    var shortVideoRecorder : PLShortVideoRecorder?
    var resultBlock: CompleteBlock?
    var filePath : URL?
    var player : PLPlayer?
    var totalTime  = 0
    var canle : Bool = false
    var stopTake = false
    //设置按住松开的view
    @IBOutlet var width: NSLayoutConstraint!
    lazy var ProgressView  :  OProgressView = {
        let  Progress = OProgressView.init(frame: CGRect.init(x: self.view.center.x - 50, y: kScreenHeight - 120, width: 100, height: 100))
        return Progress
    }()
    @IBOutlet var showStartImg: UIImageView!
    

    @IBOutlet var timeProgress: UIView!
    var timer : Timer!
    @IBOutlet var bgView: UIView!
    @IBOutlet var tipView: UIView!
    //切换摄像头
    @IBOutlet var switchBtn: UIButton!

    
    //退出按钮
    @IBOutlet var closeBtn: UIButton!
    //重置按钮
    @IBOutlet var resetBtn: UIButton!
    
    //确定按钮
    @IBOutlet var sureBtn: UIButton!
    
    // 录制视频的video
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInfo()
        configViedeo()
        
        width.constant = 0
        SVProgressHUD.showWainningMessage(WainningMessage: "长按录制视频", ForDuration: 3, completion: nil)
        self.view.bringSubview(toFront: self.tipView)
        self.view.bringSubview(toFront: self.switchBtn)
        self.view.addSubview(ProgressView)

        tap()
        timeProgress.isHidden = true
        self.view.bringSubview(toFront: timeProgress)
        self.view.bringSubview(toFront: self.closeBtn)
    }
    func updateGrogress(){
        if player?.totalDuration.value  == 0{
            return
        }
        
        let current = CGFloat((player?.currentTime.value)!)/CGFloat((player?.currentTime.timescale)!)
        let total = CGFloat((player?.totalDuration.value)!)/CGFloat((player?.totalDuration.timescale)!)
        
        if current == total{
        
        }
        width.constant = (kScreenWidth -  20 ) * current/total
    }
    
    //MARK: -配置段视频链接
    func configViedeo(){
        let videoConfiguration = PLSVideoConfiguration.default()
        let audioConfiguration = PLSAudioConfiguration.default()
        self.shortVideoRecorder = PLShortVideoRecorder.init(videoConfiguration: videoConfiguration!, audioConfiguration: audioConfiguration!)
        self.view.addSubview((self.shortVideoRecorder?.previewView)!)
//        self.shortVideoRecorder?.toggleCamera()
        self.shortVideoRecorder?.maxDuration = 15.0
        self.shortVideoRecorder?.minDuration = 1.0
        self.shortVideoRecorder?.delegate = self
        self.shortVideoRecorder?.setBeautify(1)
        self.shortVideoRecorder?.setBeautifyModeOn(true)
        self.shortVideoRecorder?.isTouchToFocusEnable = false
        self.shortVideoRecorder?.startCaptureSession()
    }
    //MARK: -添加手势
    func tap(){
        ProgressView.backgroundColor = UIColor.clear
        let longpressGesutre = UILongPressGestureRecognizer.init(target: self, action: #selector(start(_ :)))
        //所需触摸1次
        longpressGesutre.numberOfTouchesRequired = 1
        ProgressView.addGestureRecognizer(longpressGesutre)
    }

    //确定按钮
    @IBAction func didsure(_ sender: Any) {
        
        SVProgressHUD.show(withStatus: "上传中")
        
        uploadthumbnail()
        
        QiniuTool.qiniuUploadImage(image: showStartImg.image!, imageName: "thumbnail", complete: { (result) in
            if self.resultBlock != nil{
                if let thumbnail = result as? String{
                    QiniuTool.qiniuUploadVideo(filePath: (self.filePath?.path)!, videoName: "short_video", complete: { (result) in
                        if self.resultBlock != nil{
                            if let response = result as? String{
                                SVProgressHUD.showSuccessMessage(SuccessMessage: "录制成功", ForDuration: 1.5, completion: {
                                    let outputSettings = ["movieUrl" : response as AnyObject,"totalTime":self.totalTime as AnyObject,"thumbnail" : thumbnail as AnyObject,"thumbnailImg" : self.showStartImg.image as AnyObject,] as [String : AnyObject]
                                    self.resultBlock!(outputSettings as AnyObject)
                                    self.navigationController?.popViewController(animated: true)
                                })
                                
                            }
                        }
                    }) { (error) in
                    }
                }
            }
        }) { (erro) in
            
        }
        
    }
    @IBAction func switchbtn(_ sender: Any) {
        self.shortVideoRecorder?.toggleCamera()
    }
    @IBAction func exit(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer != nil{
             timer.invalidate()
        }
       
        if (player?.isPlaying == true){
            canle = true
            player?.stop()
        }
    }
    //重置按钮
    @IBAction func didreset(_ sender: Any) {
        
        //播放器停止
        
        if (player?.isPlaying == true){
            canle = true
            player?.stop()
        }
        stopTake = false
        timer.invalidate()
        canle = true
        width.constant = 0
        self.bgView.isHidden = true
        ProgressView.isHidden = false
        self.switchBtn.isHidden = false
        self.closeBtn.isHidden = false
        self.showStartImg.isHidden = true
        timeProgress.isHidden = true
        self.shortVideoRecorder?.previewView?.isHidden = false
        self.view.bringSubview(toFront: (self.shortVideoRecorder?.previewView)!)
        self.view.bringSubview(toFront: ProgressView)
        self.view.bringSubview(toFront: switchBtn)
        self.view.bringSubview(toFront: closeBtn)
        self.view.bringSubview(toFront: self.tipView)
        
        self.shortVideoRecorder?.cancelRecording()
        self.shortVideoRecorder?.stopRecording()
        ProgressView.setProgress(0, animated: true)
    }
    
    func start( _ sender: UIRotationGestureRecognizer){
        if sender.state == .began {
            canle = false
            self.shortVideoRecorder?.startRecording()
        }
        if sender.state == .ended {
            self.shortVideoRecorder?.stopRecording()
        }
    }
}
extension TakeMovieVC  {
    
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        if state == .statusStopped{
            if !canle && stopTake == true {
                self.perform(#selector(didplay), with: self , afterDelay: 1)
                self.view.bringSubview(toFront: self.tipView)
                self.view.bringSubview(toFront: self.timeProgress)
            }else{
                self.view.bringSubview(toFront: self.tipView)
            }
        }
       else if state == .statusPlaying {
         stopTake = true
        }
       else if state == .statusPaused{
            
        }
    }
    func didplay(){
        player?.play(with: self.filePath)
    }
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didRecordingToOutputFileAt fileURL: URL, fileDuration: CGFloat, totalDuration: CGFloat) {
        ProgressView.setProgress(ProgressView.progress + 0.4, animated: true)
    }
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didFinishRecordingMaxDuration maxDuration: CGFloat) {
        ProgressView.isHidden = true
        totalTime =  Int(maxDuration)
        self.shortVideoRecorder?.stopRecording()
        //        sureBtn.isHidden = false
        timeProgress.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGrogress), userInfo: nil, repeats: true)
        self.view.bringSubview(toFront: (player?.playerView)!)
        self.view.bringSubview(toFront: self.tipView)
        self.view.bringSubview(toFront: self.bgView)
        self.view.bringSubview(toFront: self.timeProgress)
        self.bgView.isHidden = false
        ProgressView.setProgress(0, animated: true)
    }
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didFinishRecordingToOutputFileAt fileURL: URL, fileDuration: CGFloat, totalDuration: CGFloat) {
        ProgressView.isHidden = true
        stopTake = false
        self.shortVideoRecorder?.stopRecording()
        UIView.animate(withDuration: 0.23) {
            self.sureBtn.isHidden = false
            self.resetBtn.isHidden = false
            self.bgView.isHidden = false
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGrogress), userInfo: nil, repeats: true)
        self.filePath = fileURL
        totalTime =  Int(totalDuration)
        self.shortVideoRecorder?.previewView?.isHidden = true
        getScreenImg()
        
        ProgressView.setProgress(0, animated: true)
        if (player == nil){
            
            let option = PLPlayerOption.default()
            player = PLPlayer.init(url: fileURL, option: option)
            self.view.addSubview((player?.playerView)!)
            self.showStartImg.isHidden = false
            self.view.bringSubview(toFront: (player?.playerView)!)
            self.view.bringSubview(toFront: self.tipView)
            self.switchBtn.isHidden = true
            self.closeBtn.isHidden = true
            self.view.bringSubview(toFront: self.bgView)
            timeProgress.isHidden = false
            self.view.bringSubview(toFront: self.timeProgress)
            player?.delegate = self
            player?.play()
            self.view.bringSubview(toFront: resetBtn)
            
            
        }else{
            player?.play(with: fileURL)
            self.showStartImg.isHidden = false
            self.switchBtn.isHidden = true
            self.closeBtn.isHidden = true
            self.bgView.isHidden = false
           
            self.view.bringSubview(toFront: (player?.playerView)!)
            self.view.bringSubview(toFront: self.tipView)
            self.view.bringSubview(toFront: self.bgView)
            self.view.bringSubview(toFront: sureBtn)
            timeProgress.isHidden = false
            self.view.bringSubview(toFront: self.timeProgress)
            self.view.bringSubview(toFront: resetBtn)
        }
    }
    //    //获取屏幕截图
    func getScreenImg(){
        let avAsset = AVAsset(url : self.filePath!)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0,600)
        var actualTime:CMTime = CMTimeMake(0,0)
        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        let frameImg = UIImage(cgImage:imageRef )
        showStartImg.image = frameImg
    }
    func updateUserInfo() {
        getUserInfo { (result) in
            if let response = result{
                let model =   response as! UserInfoModel
                if model.nick_name == "" {
                    let nameUid = StarUserModel.getCurrentUser()?.userinfo?.id
                    let stringUid = String.init(format: "%d", nameUid!)
                    self.name.text = "易时光用户" + stringUid
                } else  {
                    self.name.text = model.nick_name
                }
                self.content.text = self.q_content
                self.header.kf.setImage(with: URL(string: model.head_url), placeholder: UIImage(named:"avatar_team"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }
    func uploadthumbnail(){
    }
    
}

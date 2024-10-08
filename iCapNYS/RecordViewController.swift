//
//  RecordViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2020/09/22.
//

import UIKit
import AVFoundation
import GLKit
import Photos
import CoreMotion
import VideoToolbox

import AssetsLibrary

extension UIColor {
    func image(size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill() // 色を指定
            rendererContext.fill(.init(origin: .zero, size: size)) // 塗りつぶす
        }
    }
}

class RecordViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let camera = myFunctions()
    var cameraType:Int = 0
    
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var urlInputField: UITextField!
    var tempURL:String=""
    @IBAction func onEnterButton(_ sender: Any) {
        urlInputField.endEditing(true)
        UserDefaults.standard.set(urlInputField.text,forKey: "urlAdress")
        print(urlInputField.text)
    }
    
    @IBOutlet weak var enterButton: UIButton!
    @IBAction func onDefaultButton(_ sender: Any) {
        if urlInputField.text=="http://192.168.82.1"{
            urlInputField.text=tempURL
        }else{
            tempURL=urlInputField.text!
            urlInputField.text="http://192.168.82.1"
        }
        UserDefaults.standard.set(urlInputField.text,forKey: "urlAdress")
    }
    @IBOutlet weak var playButton: UIButton!
    func requestAVAsset(asset: PHAsset)-> AVAsset? {
        guard asset.mediaType == .video else { return nil }
        let phVideoOptions = PHVideoRequestOptions()
        phVideoOptions.version = .original
        let group = DispatchGroup()
        let imageManager = PHImageManager.default()
        var avAsset: AVAsset?
        group.enter()
        imageManager.requestAVAsset(forVideo: asset, options: phVideoOptions) { (asset, _, _) in
            avAsset = asset
            group.leave()
            
        }
        group.wait()
        
        return avAsset
    }
 //   func thumnailImageForFileUrl(fileUrl: URL) -> UIImage? {
 //       let asset = AVAsset(url: fileUrl)
    func thumnailImageForAvasset(asset:AVAsset) -> UIImage{
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 60), actualTime: nil)
            print("サムネイルの切り取り成功！")
            return UIImage(cgImage: thumnailCGImage, scale: 0, orientation: .up)
        }catch let err{
            print("エラー\(err)")
        }
        return UIImage(named:"nul")!
    }
  
    func setPlayButtonImage(){
        if someFunctions.videoPHAsset.count<1{
            return
        }
        let phasset = someFunctions.videoPHAsset[0]
        let avasset = requestAVAsset(asset: phasset)
        let but=thumnailImageForAvasset(asset: avasset!)
         playButton.setImage(but, for: .normal)
    }
    @IBAction func onPlayButton(_ sender: UIButton) {
        if someFunctions.videoPHAsset.count<1{
            return
        }
        let phasset = someFunctions.videoPHAsset[0]
        let avasset = requestAVAsset(asset: phasset)
//        let but=thumnailImageForAvasset(asset: avasset!)
//        playButton.setImage(but, for: .normal)
 
        if avasset == nil {//なぜ？icloudから落ちてきていないのか？
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "playView") as! PlayViewController
      
//        nextView.videoURL = someFunctions.videoURL[indexPath.row]
        nextView.phasset = someFunctions.videoPHAsset[0]// indexPath.row]
        nextView.avasset = avasset
        nextView.calcDate = someFunctions.videoDate[0]
        self.present(nextView, animated: true, completion: nil)
    }
    var soundIdstart:SystemSoundID = 1117
    var soundIdstop:SystemSoundID = 1118
    var soundIdpint:SystemSoundID = 1109//1009//7
    var soundIdx:SystemSoundID = 0
    let albumName:String = "iCapNYS"
    var recordingFlag:Bool = false
    var saved2album:Bool = false
    var setteiMode:Int = 0//0:camera, 1:setteimanual, 2:setteiauto
    var autoRecordMode:Bool = false
    let motionManager = CMMotionManager()
    var explanationLabeltextColor:UIColor=UIColor.systemGreen
    
    @IBOutlet weak var previewSwitch: UISwitch!
    
    @IBAction func onPreviewSwitch(_ sender: Any) {
        if previewSwitch.isOn==true{
            UserDefaults.standard.set(1, forKey: "previewOn")
        }else{
            UserDefaults.standard.set(0, forKey: "previewOn")
        }
        setButtonsDisplay()
    }
    
    @IBOutlet weak var previewLabel: UILabel!
    //for video input
    var captureSession: AVCaptureSession!
    var videoDevice: AVCaptureDevice?

    //for video output
    var fileWriter: AVAssetWriter!
    var fileWriterInput: AVAssetWriterInput!
    var fileWriterAdapter: AVAssetWriterInputPixelBufferAdaptor!
    var startTimeStamp:Int64 = 0
    
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    var newFilePath: String = ""
    var iCapNYSWidth: Int32 = 0
    var iCapNYSHeight: Int32 = 0
    var iCapNYSWidthF: CGFloat = 0
    var iCapNYSHeightF: CGFloat = 0
    var iCapNYSWidthF120: CGFloat = 0
    var iCapNYSHeightF5: CGFloat = 0
    var iCapNYSFPS: Float64 = 0
    //for gyro and face drawing
    var gyro = Array<Double>()
    let someFunctions = myFunctions()
    override var shouldAutorotate: Bool {
        return false
    }
    @IBAction func unwindAction(segue: UIStoryboardSegue) {
        print("segueWhatRecord:",segue)
     /*   if let vc = segue.source as? RecordViewController{
            let Controller:RecordViewController = vc
            if Controller.stopButton.isHidden==true{//Exit
                print("Exit / not recorded")
            }else{
                print("Exit / recorded")
                if someFunctions.videoPHAsset.count<5{
                    someFunctions.getAlbumAssets()
                    print("count<5")
                }else{
                    someFunctions.getAlbumAssets_last()
                    print("count>4")
                }
//                UserDefaults.standard.set(0,forKey: "contentOffsetY")
//                DispatchQueue.main.async { [self] in
//                    self.tableView.contentOffset.y=0
//                }
            }
            onCameraChangeButton(stopButton)

            print("segue:","\(segue.identifier!)")
            Controller.motionManager.stopDeviceMotionUpdates()
            Controller.captureSession.stopRunning()
        }else*/
        if let vc1 = segue.source as? WifiViewController{
            let Controller:WifiViewController = vc1
            if Controller.stopButton.isHidden==true{//Exit
                print("Exit / not recorded")
            }else{
                print("Exit / recorded")
            }
   
            print("segue:","\(segue.identifier!)")
  //          Controller.motionManager.stopDeviceMotionUpdates()
            cameraChangeButton.isHidden=false
            currentTime.isHidden=true
            onCameraChangeButton(stopButton)//cameratypeを変更せず
            recordingFlag=false
         //   setPlayButtonImage()
         //   setButtonsDisplay()
        }else if let vc = segue.source as? AutoRecordViewController{
            let Controller:AutoRecordViewController = vc
            Controller.killTimer()//念の為
       //     if (Controller.isPositional==false && Controller.movieTimerCnt>25) ||
       //         (Controller.isPositional==true && Controller.movieTimerCnt>112){
       //         print("Exit / Auto recorded")
       //         if someFunctions.videoPHAsset.count<5{
       //             someFunctions.getAlbumAssets()
       //             print("count<5")
       //         }else{
        //            someFunctions.getAlbumAssets_last()
       //             print("count>4")
       //         }
//                UserDefaults.standard.set(0,forKey: "contentOffsetY")
//                DispatchQueue.main.async { [self] in
//                    self.tableView.contentOffset.y=0
//                    self.tableView.reloadData()//こちらだけこれが必要なのはどうして
//                }
//            }
             Controller.motionManager.stopDeviceMotionUpdates()
            Controller.captureSession.stopRunning()
            print("segue:","\(segue.identifier!)")
         //   Controller.killTimer()
         //   Controller.soundPlayer?.stop()
         //   Controller.videoPlayer.pause()
        //    Controller.motionManager.stopDeviceMotionUpdates()
         //   Controller.captureSession.stopRunning()
         //   recordingFlag=false
            
   //     }else if let vc = segue.source as? AutoRecordViewController{
   //     }else if let vc = segue.source as? MainViewController{
            
     //   }else if let vc = segue.source as? BLEViewController{
     //       let Controller:BLEViewController = vc
     //       Controller.motionManager.stopDeviceMotionUpdates()
        }
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.double(forKey: "brightness"))
        UIApplication.shared.isIdleTimerDisabled = false//スリープする.監視する
        recordingFlag=false
        print("unwind")
        someFunctions.getAlbumAssets()
        someFunctions.getAlbumAssets_last()
        setPlayButtonImage()
        setButtonsDisplay()
        onCameraChangeButton(stopButton)
//        setButtonsDisplay()
//        isStarted=false
//        startMotion()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let landscapeSide=someFunctions.getUserDefaultInt(str: "landscapeSide", ret: 0)
        if landscapeSide==0{
            return UIInterfaceOrientationMask.landscapeRight
        }else{
            return UIInterfaceOrientationMask.landscapeLeft
        }
    }
    var quater0:Double=0
    var quater1:Double=0
    var quater2:Double=0
    var quater3:Double=0
    var readingFlag = false
    var timer:Timer?
    var tapFlag:Bool=false//??
    var flashFlag=false
    
    var rpk1 = Array(repeating: CGFloat(0), count:500)
    var ppk1 = Array(repeating: CGFloat(0), count:500)//144*3
    var facePoints:[Int] = [//x1,y1,0, x2,y2,0, x3,y3,1, x4,y4,0  の並びは   MoveTo(x1,y1)  LineTo(x2,y2)  LineTo(x3,y3)  MoveTo(x4,y4) と描画される
        0,0,0, 15,0,0, 30,0,0, 45,0,0, 60,0,0, 75,0,0, 90,0,0, 105,0,0, 120,0,0, 135,0,0, 150,0,0, 165,0,0,//horizon 12
        180,0,0, 195,0,0, 210,0,0, 225,0,0, 240,0,0, 255,0,0, 270,0,0, 285,0,0, 300,0,0, 315,0,0, 330,0,0, 345,0,0, 360,0,1,//horizon 12+13=25
        0,0,0, 0,15,0, 0,30,0, 0,45,0, 0,60,0, 0,75,0, 0,90,0, 0,105,0, 0,120,0, 0,135,0, 0,150,0, 0,165,0,//vertical 25+12
        0,180,0, 0,195,0, 0,210,0, 0,225,0, 0,240,0, 0,255,0, 0,270,0, 0,285,0, 0,300,0, 0,315,0, 0,330,0, 0,345,0, 0,360,1,//virtical 37+13=50
        0,90,0, 15,90,0, 30,90,0, 45,90,0, 60,90,0, 75,90,0, 90,90,0, 105,90,0, 120,90,0, 135,90,0, 150,90,0, 165,90,0,//coronal 50+12=62
        180,90,0, 195,90,0, 210,90,0, 225,90,0, 240,90,0, 255,90,0, 270,90,0, 285,90,0, 300,90,0, 315,90,0, 330,90,0, 345,90,90, 360,90,1,//coronal 62+13=75
        20,-90,0, 20,-105,0, 20,-120,0, 20,-135,0, 20,-150,0, 20,-165,0, 20,-180,1,
        //hair 75+7=82
        -20,-90,0, -20,-105,0, -20,-120,0, -20,-135,0, -20,-150,0, -20,-165,0, -20,-180,1,//hair 82+7=89
        40,-90,0, 40,-105,0, 40,-120,0, 40,-135,0, 40,-150,0, 40,-165,0, 40,-180,1,
        //hair 89+7=96
        -40,-90,0, -40,-105,0, -40,-120,0, -40,-135,0, -40,-150,0, -40,-165,0, -40,-180,1,//hair 96+7=103
        23,-9,0, 31,-12,0, 38,-20,0, 40,-31,0, 38,-41,0, 31,-46,0, 23,-45,0, 15,-39,0, 10,-32,0, 8,-23,0, 10,-16,0, 15,-10,0, 23,-9,1,//eye +13
        -23,-9,0, -31,-12,0, -38,-20,0, -40,-31,0, -38,-41,0, -31,-46,0, -23,-45,0, -15,-39,0, -10,-32,0, -8,-23,0, -10,-16,0, -15,-10,0, -23,-9,1,//eye +13
        22,-26,0, 23,-25,0, 24,-24,1,//eye dots 3
        -22,-26,0, -23,-25,0, -24,-24,1,//eye dots 3
        -19,32,0, -14,31,0, -9,31,0, -4,31,0, 0,30,0, 4,31,0, 9,31,0, 14,31,0, 19,32,1]//mouse 9
    
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var focusBar: UISlider!
    @IBOutlet weak var focusValueLabel: UILabel!

    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var zoomValueLabel: UILabel!
    @IBOutlet weak var zoomBar: UISlider!
    
    @IBOutlet weak var exposeValueLabel: UILabel!
    @IBOutlet weak var exposeLabel: UILabel!
    @IBOutlet weak var exposeBar: UISlider!

    @IBOutlet weak var LEDBar: UISlider!
    @IBOutlet weak var LEDLabel: UILabel!
    @IBOutlet weak var LEDValueLabel: UILabel!
   
    @IBOutlet weak var bleButton: UIButton!
   
    @IBAction func onAuto90sButton(_ sender: Any) {
        frontCameraMode=2
        setButtonsFrontCameraMode()
    }
    @IBAction func onAuto20sButton(_ sender: Any) {
        frontCameraMode=1
        setButtonsFrontCameraMode()

    }
    @IBAction func onManualButton(_ sender: Any) {
        frontCameraMode=0
        setButtonsFrontCameraMode()

    }
    @IBOutlet weak var auto90sButton: UIButton!
    @IBOutlet weak var auto20sButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    var frontCameraMode:Int = 0//0:manual 1:20s 2:90s
 
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var quaternionView: UIImageView!
    @IBOutlet weak var cameraView:UIImageView!
    
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var whiteView: UIImageView!
    
//    @IBOutlet weak var arrowUpDown: UIImageView!
   
    @IBOutlet weak var cameraChangeButton: UIButton!
   
    func setBars(){
//        if setteiMode==2{
//            zoomBar.value=camera.getUserDefaultFloat(str: "AutoZoomValue", ret: 0)
//            setZoom(level: zoomBar.value)
//            
//        }else{
            zoomBar.value=camera.getUserDefaultFloat(str: "zoomValue", ret: 0)
            focusBar.value=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
            setFocus(focus: focusBar.value)
            setZoom(level: zoomBar.value)
//            LEDBar.value=camera.getUserDefaultFloat(str: "ledValue", ret: 0)
//            setFlashlevel(level: LEDBar.value)
//        }
    }
    func setZoom(level:Float){//0.0-0.1
//        var zoom=0.017//level*level/4
//        if cameraType==1{
//            zoom=0.007
//        }
        print("setZoom*****:",level)
        if let device = videoDevice {
            zoomValueLabel.text=(Int(level*1000)).description

        do {
            try device.lockForConfiguration()
                device.ramp(
                    toVideoZoomFactor: (device.minAvailableVideoZoomFactor) + CGFloat(level) * ((device.maxAvailableVideoZoomFactor) - (device.minAvailableVideoZoomFactor)),
                    withRate: 30.0)
            device.unlockForConfiguration()
            } catch {
                print("Failed to change zoom.")
            }
        }
    }
    
    func setFlashlevel(level:Float){
        if cameraType != 0 && cameraType != 4{
            if let device = videoDevice{
                do {
                    if device.hasTorch {
                        do {
                            // torch device lock on
                            try device.lockForConfiguration()
                            
                            if (level > 0.0){
                                do {
                                    try device.setTorchModeOn(level: level)
                                } catch {
                                    print("error")
                                }
                                
                            } else {
                                // flash LED OFF
                                // 注意しないといけないのは、0.0はエラーになるのでLEDをoffさせます。
                                device.torchMode = AVCaptureDevice.TorchMode.off
                            }
                            // torch device unlock
                            device.unlockForConfiguration()
                            
                        } catch {
                            print("Torch could not be used")
                        }
                    }
                }
            }
        }else{//front camera
            
        }
    }
    
    func killTimer(){
        if timer?.isValid == true {
            timer!.invalidate()
        }
    }
    
    
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    var leftPadding:CGFloat=0
    var rightPadding:CGFloat=0
    var topPadding:CGFloat=0
    var bottomPadding:CGFloat=0
    var realWinWidth:CGFloat=0
    var realWinHeight:CGFloat=0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews*******")
        //        if #available(iOS 11.0, *) {iPhone6以前は無視する。
        // viewDidLayoutSubviewsではSafeAreaの取得ができている
        let topPadding = self.view.safeAreaInsets.top
        let bottomPadding = self.view.safeAreaInsets.bottom
        let leftPadding = self.view.safeAreaInsets.left
        let rightPadding = self.view.safeAreaInsets.right
        UserDefaults.standard.set(topPadding,forKey: "topPadding")
        UserDefaults.standard.set(bottomPadding,forKey: "bottomPadding")
        UserDefaults.standard.set(leftPadding,forKey: "leftPadding")
        UserDefaults.standard.set(rightPadding,forKey: "rightPadding")
    }
    func getPaddings(){
        viewDidLayoutSubviews()
        leftPadding=CGFloat(UserDefaults.standard.integer(forKey:"leftPadding"))
        rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        realWinWidth=view.bounds.width-leftPadding-rightPadding
        realWinHeight=view.bounds.height-topPadding-bottomPadding/2
    }
     //setteiMode 0:Camera 1:manual_settei(green) 2:auto_settei(orange)
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        stopButton.alpha=0.025
        getPaddings()
        setteiMode=1
        autoRecordMode=false
        if someFunctions.videoPHAsset.count<5{
            someFunctions.getAlbumAssets()
            print("count<5")
        }else{
            someFunctions.getAlbumAssets_last()
            print("count>4")
        }
        setPlayButtonImage()
        explanationLabel.textColor=explanationLabeltextColor
        print("setteiMode,autoRecordMode",setteiMode,autoRecordMode)
        urlInputField.text=camera.getUserDefaultString(str: "urlAdress", ret: "http://192.168.82.1")
        frontCameraMode=someFunctions.getUserDefaultInt(str: "frontCameraMode", ret: 0)
        getCameras()
        camera.makeAlbum()
        cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
//        if setteiMode==2{
//             cameraType=0
//        }
        if getUserDefault(str: "previewOn", ret: 0) == 0{
            previewSwitch.isOn=false
        }else{
            previewSwitch.isOn=true
        }
        setPreviewLabel()

//print("camara:",cameraType)
        set_rpk_ppk()
        setMotion()
        initSession(fps: 60)//遅ければ30fpsにせざるを得ないかも、30fpsだ！
        //露出はオートの方が良さそう
    
        LEDBar.minimumValue = 0
        LEDBar.maximumValue = 1
        LEDBar.addTarget(self, action: #selector(onLEDValueChange), for: UIControl.Event.valueChanged)
        LEDBar.value=UserDefaults.standard.float(forKey: "")
        if cameraType != 0 && cameraType != 4{
            LEDBar.value=UserDefaults.standard.float(forKey: "ledValue")
        }
        onLEDValueChange()
        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
        onFocusValueChange()
        if focusChangeable==false{
            focusLabel.isHidden=true
            focusBar.isHidden=true
            focusValueLabel.isHidden=true
        }else{
            focusLabel.isHidden=false
            focusBar.isHidden=false
            focusValueLabel.isHidden=false
        }
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
//        if setteiMode==2{
//            zoomBar.value = camera.getUserDefaultFloat(str: "autoZoomValue", ret: 0.002)
//        }else{
            zoomBar.value = camera.getUserDefaultFloat(str: "zoomValue", ret: 0.0)
//        }
        setZoom(level: zoomBar.value)
        exposeBar.minimumValue = Float(videoDevice!.minExposureTargetBias)
        exposeBar.maximumValue = Float(videoDevice!.maxExposureTargetBias)
        exposeBar.addTarget(self, action: #selector(onExposeValueChange), for: UIControl.Event.valueChanged)
//        if setteiMode==2{
//            exposeBar.value=camera.getUserDefaultFloat(str:"autoExposeValue",ret:1.6)
//        }else{
            exposeBar.value=camera.getUserDefaultFloat(str:"exposeValue",ret:1.6)
//        }
        onExposeValueChange()
        currentTime.isHidden=true
     //   startButton.alpha=0.25
        startButton.isHidden=false
        stopButton.isHidden=true
        stopButton.isEnabled=false
        urlInputField.keyboardType = UIKeyboardType.numbersAndPunctuation//phonePad//asciiCapableNumberPad
        setButtonsDisplay()
        if cameraType == 5{
            captureSession.stopRunning()
        }
        var timer = Timer
            .scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { _ in
                //       print("実行しました")
              //  if self.recordingFlag{
                    self.timerCnt += 1
              //  }else{
              //      self.timerCnt=0
              //  }
                if self.recordingFlag{//} && timerCnt>3{//trueになった時 0にリセットされる
                    self.currentTime.text=String(format:"%01d",(self.timerCnt)/60) + ":" + String(format: "%02d",(self.timerCnt)%60)
                    if self.timerCnt%2==0{
                        self.stopButton.tintColor=UIColor.cyan
                    }else{
                        self.stopButton.tintColor=UIColor.yellow// red
                    }
                }
                if self.timerCnt == 5*60{//sleep
                    if self.recordingFlag{
                        self.onClickStopButton(0)
                    }
                }
                if self.timerCnt == 1 && !self.recordingFlag{//こんなところでズーム処理、どうにかしたいが分からない
                    self.setZoom(level: self.zoomBar.value)
  //                  self.setBars()
                }
   //             self.doTimer()//
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      UIApplication.shared.isIdleTimerDisabled = false  // この行
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 //       setButtonsDisplay()
        UIApplication.shared.isIdleTimerDisabled = true  // この行
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    /*  @objc func onExposeValueChange(){
     setExpose(expose:exposeBar.value)
     if setteiMode==2{
         UserDefaults.standard.set(exposeBar.value, forKey: "autoExposeValue")
     }else{
         UserDefaults.standard.set(exposeBar.value, forKey: "exposeValue")
     }
 }*/
    
    
    @objc func onZoomValueChange(){
//        if setteiMode==2{
//            UserDefaults.standard.set(zoomBar.value, forKey: "autoZoomValue")
//            UserDefaults.standard.set(zoomBar.value, forKey: "zoomValue")
//       }else{
            UserDefaults.standard.set(zoomBar.value, forKey: "zoomValue")
           UserDefaults.standard.set(zoomBar.value, forKey: "autoZoomValue")
//       }
        setZoom(level: zoomBar.value)
    }
    @objc func onLEDValueChange(){
        if cameraType != 0 && cameraType != 4{
            setFlashlevel(level: LEDBar.value)
            UserDefaults.standard.set(LEDBar.value, forKey: "ledValue")
            LEDValueLabel.text=(Int(LEDBar.value*100)).description
        }
    }
    
    func startRecord(){
        stopButton.isEnabled=true
        if let soundUrl = URL(string:
                                "/System/Library/Audio/UISounds/begin_record.caf"/*photoShutter.caf*/){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
        fileWriter!.startWriting()
        fileWriter!.startSession(atSourceTime: CMTime.zero)
        setMotion()
    }
    var timerCnt:Int=0
 /*   func doTimer(){
        self.timerCnt += 1
        if recordingFlag==true{//} && timerCnt>3{//trueになった時 0にリセットされる
            currentTime.text=String(format:"%01d",(self.timerCnt)/60) + ":" + String(format: "%02d",(self.timerCnt)%60)
            if self.timerCnt%2==0{
                stopButton.tintColor=UIColor.cyan
            }else{
                stopButton.tintColor=UIColor.yellow// red
            }
        }
        if self.timerCnt == 5*60{//sleep
            onClickStopButton(0)
        }
    }*/
    
/*    @objc func updateTimer(tm: Timer) {
        self.timerCnt += 1
        if self.timerCnt == 10000{
            stopButton.isEnabled=true
//            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
           //        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

           if let soundUrl = URL(string:
                                   "/System/Library/Audio/UISounds/begin_record.caf"/*photoShutter.caf*/){
               AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
               AudioServicesPlaySystemSound(soundIdx)
           }

           fileWriter!.startWriting()
           fileWriter!.startSession(atSourceTime: CMTime.zero)
   //        print(fileWriter?.error)
           setMotion()
        }
        if recordingFlag==true{//} && timerCnt>3{//trueになった時 0にリセットされる
            currentTime.text=String(format:"%01d",(self.timerCnt)/60) + ":" + String(format: "%02d",(self.timerCnt)%60)
            if self.timerCnt%2==0{
                stopButton.tintColor=UIColor.cyan
            }else{
                stopButton.tintColor=UIColor.yellow// red
            }
        }
        //     var maxTimeLimit:Bool=true
        if self.timerCnt == 5*60{//sleep
            //            if maxTimeLimit==false{
            //                //将来このflagを設定すると、永遠に録画できる。その時はiphoneのロック機能もオフにしないと使いづらい。
            //                UIApplication.shared.isIdleTimerDisabled = false  // この行
            //            }else{
            motionManager.stopDeviceMotionUpdates()//tuika
            if self.recordingFlag==true{
                self.killTimer()
                self.onClickStopButton(0)
            }else{
                self.killTimer()
              //  self.performSegue(withIdentifier: "fromRecord", sender: self)
            }
            //            }
        }
    }*/
    var autholizedFlag:Bool=false
    func setMotion(){
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1 / 100//が最速の模様
        //time0=CFAbsoluteTimeGetCurrent()
        //        var initf:Bool=false
        degreeAtResetHead = -1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            //            self.gyro.append(CFAbsoluteTimeGetCurrent())
            //            self.gyro.append(motion.rotationRate.y)//
            while self.readingFlag==true{
//                sleep(UInt32(0.1))
                usleep(1000)//0.001sec
            }
            let quat = motion.attitude.quaternion
            if autholizedFlag==false && PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized{
                autholizedFlag=true
                print("authorized!!!")
                captureSession.stopRunning()
                set_rpk_ppk()
                initSession(fps: 60)
                self.setButtonsDisplay()
            }
            let landscapeSide=someFunctions.getUserDefaultInt(str: "landscapeSide", ret: 0)

            if landscapeSide==0{
            self.quater0 = quat.w
            self.quater1 = -quat.y
            self.quater2 = -quat.z
            self.quater3 = quat.x
            }else{
                self.quater0 = quat.w
                self.quater1 = quat.y
                self.quater2 = -quat.z
                self.quater3 = -quat.x

            }
            //degreeAtResetHead:モーションセンサーをリセットするときに-1とする。リセット時に-1なら,角度から０か１をセット
            //drawHeadで顔を描くとき利用する。
            if degreeAtResetHead == -1{
                if motion.gravity.z > 0{
                    degreeAtResetHead = (cameraType != 0 && cameraType != 4) ? 1:0
                }else{
                    degreeAtResetHead = (cameraType != 0 && cameraType != 4) ? 0:1
                }
            }
        })
    }
  
    func set_rpk_ppk() {
        let faceR:CGFloat = 40//hankei
        var frontBack:Int = 0
//        let camera = Int(camera.getUserDefaultInt(str: "cameraType", ret: 0))
//        i
        if cameraType == 0 || cameraType == 4{//front camera
            frontBack = 180
        }
        // convert draw data to radian
        print("frontBack",frontBack)
        for i in 0..<facePoints.count/3 {
            rpk1[i*2] = CGFloat(facePoints[3 * i + 0]) * 0.01745329//pi/180
            rpk1[i*2+1] = CGFloat(facePoints[3 * i + 1]+frontBack) * 0.01745329//pi/180
        }
        // move (1,0,0) to each draw point
        for i in 0..<facePoints.count/3{
            ppk1[i*3] = 0
            ppk1[i*3+1] = faceR
            ppk1[i*3+2] = 0
        }
        // rotate all draw point based on draw data
        var dx,dy,dz:CGFloat
        for i in  0..<facePoints.count/3 {
            //rotateX
            dy = ppk1[i*3+1]*cos(rpk1[i*2]) - ppk1[i*3+2]*sin(rpk1[i*2])
            dz = ppk1[i*3+1]*sin(rpk1[i*2]) + ppk1[i*3+2]*cos(rpk1[i*2])
            ppk1[i*3+1] = dy;
            ppk1[i*3+2] = dz;
          //rotateZ
            dx = ppk1[i*3]*cos(rpk1[i*2+1])-ppk1[i*3+1]*sin(rpk1[i*2+1])
            dy = ppk1[i*3]*sin(rpk1[i*2+1]) + ppk1[i*3+1]*cos(rpk1[i*2+1])
            ppk1[i*3] = dx
            ppk1[i*3+1] = dy
            //rotateY
            dx =  ppk1[i*3] * cos(1.5707963) + ppk1[i*3+2] * sin(1.5707963)
            dz = -ppk1[i*3] * sin(1.5707963) + ppk1[i*3+2] * cos(1.5707963)
            ppk1[i*3]=dx
            ppk1[i*3+2]=dz
        }
    }
    //モーションセンサーをリセットするときに-1とする。リセット時に-1なら,角度から０か１をセット
    var degreeAtResetHead:Int=0//0:-90<&&<90 1:<-90||>90 -1:flag for get degree
    func drawHead(width w:CGFloat, height h:CGFloat, radius r:CGFloat, qOld0:CGFloat, qOld1:CGFloat, qOld2:CGFloat, qOld3:CGFloat)->UIImage{
//        print(String(format:"%.3f,%.3f,%.3f,%.3f",qOld0,qOld1,qOld2,qOld3))
        var ppk = Array(repeating: CGFloat(0), count:500)
        let faceX0:CGFloat = w/2;
        let faceY0:CGFloat = h/2;//center
        let faceR:CGFloat = r;//hankei
        let defaultRadius:CGFloat = 40.0
        let size = CGSize(width:w, height:h)
    
//        print("quat:",String(format: "%.2f %.2f %.2f %.2f",qOld0,qOld0,qOld2,qOld3))

//        // イメージ処理の開始
        for i in 0..<facePoints.count/3 {
            let x0:CGFloat = ppk1[i*3]
            let y0:CGFloat = ppk1[i*3+1]
            let z0:CGFloat = cameraType == 0 || cameraType == 4 ? -ppk1[i*3+2]:ppk1[i*3+2]
            var q0=qOld0
            var q1=qOld1
            var q2=qOld2
            var q3=qOld3
            //<--ここから　-->までなくても良さそう
            var norm,mag:CGFloat!
            mag = CGFloat(sqrt(q0*q0 + q1*q1 + q2*q2 + q3*q3))
            if mag>CGFloat(Float.ulpOfOne){
                norm = 1 / mag
                q0 *= norm
                q1 *= norm
                q2 *= norm
                q3 *= norm
            }
            //-->
            ppk[i*3] = x0 * (q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3) + y0 * (2 * (q1 * q2 - q0 * q3)) + z0 * (2 * (q1 * q3 + q0 * q2))
            ppk[i*3+1] = x0 * (2 * (q1 * q2 + q0 * q3)) + y0 * (q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3) + z0 * (2 * (q2 * q3 - q0 * q1))
            ppk[i*3+2] = x0 * (2 * (q1 * q3 - q0 * q2)) + y0 * (2 * (q2 * q3 + q0 * q1)) + z0 * (q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3)
        }
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)

        let drawPath = UIBezierPath(arcCenter: CGPoint(x: faceX0, y:faceY0), radius: faceR, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
        // 内側の色
        UIColor.white.setFill()
//        // 内側を塗りつぶす
        drawPath.fill()

        let uraPoint=faceR/40.0//この値の意味がよくわからなかった

        var endpointF=true//終点でtrueとする
        if degreeAtResetHead == 1{//iPhoneが >90||<-90 垂直以上に傾いた時
            for i in 0..<facePoints.count/3-1{
                if endpointF==true{//始点に移動する
                    
                    if ppk[i*3+1] < uraPoint{
                        endpointF=true
                    }else{
                        endpointF=false
                    }
                    drawPath.move(to: CGPoint(x:faceX0+ppk[i*3]*faceR/defaultRadius,y:faceY0-ppk[i*3+2]*faceR/defaultRadius))
                }else{
                    if ppk[i*3+1] > uraPoint{
                        drawPath.addLine(to: CGPoint(x:faceX0+ppk[i*3]*faceR/defaultRadius,y:faceY0-ppk[i*3+2]*faceR/defaultRadius))
                    }else{
                        drawPath.move(to: CGPoint(x:faceX0+ppk[i*3]*faceR/defaultRadius,y:faceY0-ppk[i*3+2]*faceR/defaultRadius))
                    }
                    if facePoints[3*i+2] == 1{
                        endpointF=true
                    }
                }
            }
        }else{//iPhoneが-90~+90の時
            for i in 0..<facePoints.count/3-1{
                if endpointF==true{//始点に移動する
                    
                    if ppk[i*3+1] < uraPoint{
                        endpointF=true
                    }else{
                        endpointF=false
                    }
                    drawPath.move(to: CGPoint(x:faceX0-ppk[i*3]*faceR/defaultRadius,y:faceY0+ppk[i*3+2]*faceR/defaultRadius))
                }else{
                    if ppk[i*3+1] > uraPoint{
                        drawPath.addLine(to: CGPoint(x:faceX0-ppk[i*3]*faceR/defaultRadius,y:faceY0+ppk[i*3+2]*faceR/defaultRadius))
                    }else{
                        drawPath.move(to: CGPoint(x:faceX0-ppk[i*3]*faceR/defaultRadius,y:faceY0+ppk[i*3+2]*faceR/defaultRadius))
                    }
                    if facePoints[3*i+2] == 1{
                        endpointF=true
                    }
                }
            }
        }
        // 線の色
        UIColor.black.setStroke()
        drawPath.lineWidth = 2.0//1.0
        // 線を描く
        drawPath.stroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    
    func setVideoFormat(desiredFps: Double)->Bool {
        var retF:Bool=false
        //desiredFps 60
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        // フォーマットを探る
        for format in videoDevice!.formats {
            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let width = dimensions.width
//                print(dimensions.width,dimensions.height)
//                if range.maxFrameRate == desiredFps && width == 1280{
                if  width == 1280{
                    selectedFormat = format//最後のformat:一番高品質
//                    print(range.maxFrameRate,dimensions.width,dimensions.height)
                }
            }
        }
//ipod touch 1280x720 1440*1080
//SE 960x540 1280x720 1920x1080
//11 192x144 352x288 480x360 640x480 1024x768 1280x720 1440x1080 1920x1080 3840x2160
//1280に設定すると上手く行く。合成のところには1920x1080で飛んでくるようだ。？
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
//            print(selectedFormat.description)
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
//                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFps))
                videoDevice!.unlockForConfiguration()
                
                let description = selectedFormat.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                iCapNYSWidth = dimensions.width
                iCapNYSHeight = dimensions.height
                if cameraType == 0{//訳がわからないがこれで上手くいく、反則行為
                    iCapNYSHeight=720
                }
                iCapNYSFPS = desiredFps
                print("フォーマット・フレームレートを設定 : \(desiredFps) fps・\(iCapNYSWidth) px x \(iCapNYSHeight) px")
                iCapNYSWidthF=CGFloat(iCapNYSWidth)
                iCapNYSHeightF=CGFloat(iCapNYSHeight)
                iCapNYSWidthF120=iCapNYSWidthF/120//quaterの表示開始位置
                iCapNYSHeightF5=iCapNYSHeightF/5//quaterの表示サイズ
                retF=true
            }
            catch {
                print("フォーマット・フレームレートが指定できなかった")
                retF=false
            }
        }
        else {
            print("指定のフォーマットが取得できなかった")
            retF=false
        }
        return retF
    }
    var telephotoCamera:Bool=false
    var ultrawideCamera:Bool=false
    func getCameras(){//wideAngleCameraのみ使用
        if AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil{
            ultrawideCamera=true
        }
        if AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil{
            telephotoCamera=true
        }
    }
    func setButtonsFrontCameraMode(){
//        frontCameraMode=someFunctions.getUserDefaultInt(str: "frontCameraMode", ret: 0)

        if cameraType == 0 && setteiMode != 0{
            manualButton.isHidden=true
            auto20sButton.isHidden=true
            auto90sButton.isHidden=true
            manualButton.setTitleColor(UIColor.systemGray2,for: .normal)
            auto20sButton.setTitleColor(UIColor.systemGray2,for:.normal)
            auto90sButton.setTitleColor(UIColor.systemGray2,for:.normal)
            if frontCameraMode==0{
                manualButton.setTitleColor(UIColor.white,for:.normal)
            }else if frontCameraMode==1{
                auto20sButton.setTitleColor(UIColor.white,for:.normal)
            }else{
                auto90sButton.setTitleColor(UIColor.white,for:.normal)
            }
        }else{
            manualButton.isHidden=true
            auto20sButton.isHidden=true
            auto90sButton.isHidden=true
        }
        UserDefaults.standard.set(frontCameraMode, forKey: "frontCameraMode")
    }
    //"frontCamera:","wideAngleCamera:","ultraWideCamera:","telePhotoCamera:","none","wifiCamera"
    func cameraChange(_ cameraType:Int)->Int{
        var type = cameraType
        if type == 0{
            type = 4//auto90
        }else if type == 4{
            type = 1//wideAngle
        }else if type == 1{
            if telephotoCamera == true{
          //      type=2//ultraWide
          //  }else if ultrawideCamera == true{
                type = 3//telePhoto
            }else{
                type = 5
            }
     //   }else if type==2{
     //       if ultrawideCamera==true{
      //          type=3
     //       }else{
     //           type=5
     //     }
        }else if type == 3{
            type = 5//wifiCamera
        }else{
            type = 0//frontCamera
        }
        print("cameraType:",type)
        return type
    }
//    "frontCamera:","wideAngleCamera:","ultraWideCamera:","telePhotoCamera:","none","wifiCamera"
    let cameraTypeStrings : Array<String> = ["自撮り用\nカメラ","背面\nカメラ1","ultraWideCam","背面\nカメラ2","解説動画付\n自動90秒","WiFi\nカメラ"]
    let cameraTypeStringsE : Array<String> = ["Selfie\nCamera","Back\nCamera1","ultraWideCam","Back\nCamera2","withVideo\nAuto90s","WiFi\nCamera"]

    func setButtonsDisplay(){
        getPaddings()
        setButtonsLocation()
 //       var explanationText = cameraTypeStrings[cameraType]
//        if explanationLabeltextColor==UIColor.systemOrange{
//            explanationText=""
//        }
        if someFunctions.firstLang().contains("ja"){
            explanationLabel.text = cameraTypeStrings[cameraType]
        }else{
            explanationLabel.text = cameraTypeStringsE[cameraType]
        }
        setButtonsFrontCameraMode()
        defaultButton.isHidden=true
        enterButton.isHidden=true
        urlLabel.isHidden=true
        urlInputField.isHidden=true
        setPreviewLabel()
        zoomBar.isHidden=false
        zoomLabel.isHidden=false
        zoomValueLabel.isHidden=false
        exposeBar.isHidden=false
        exposeLabel.isHidden=false
        exposeValueLabel.isHidden=false
        LEDBar.isHidden=false
        LEDLabel.isHidden=false
        LEDValueLabel.isHidden=false
        cameraView.isHidden=false
        quaternionView.isHidden=false
        bleButton.isHidden=true

//print("setteimode:******:",setteiMode)
        if cameraType == 0 || cameraType == 4{
            LEDBar.isHidden=true
            LEDLabel.isHidden=true
            LEDValueLabel.isHidden=true
 //           previewLabel.isHidden=false
 //           previewSwitch.isHidden=false
 //           setPreviewLabel()
//            if previewSwitch.isOn{
//                previewLabel.isHidden=false
//            }else{
//                previewLabel.isHidden=true
//            }
//            if setteiMode==2{
//                previewLabel.isHidden=true
//                previewSwitch.isHidden=true
//            }
        }else if cameraType == 1{
            
        }else if cameraType == 2{
            
        }else if cameraType == 3{
            
        }else{//cameraType:5
            hideButtonsSlides()
            cameraChangeButton.isHidden=false
            currentTime.isHidden=true

            defaultButton.isHidden=true
            enterButton.isHidden=true
            urlLabel.isHidden=false
            urlInputField.isHidden=true
            bleButton.isHidden=true//使わない

            cameraView.isHidden=true
//            quaternionView.isHidden=true
        }
//        if setteiMode==0{
//            zoomBar.isHidden=true
//            zoomLabel.isHidden=true
//            zoomValueLabel.isHidden=true
//            exposeBar.isHidden=true
//            exposeLabel.isHidden=true
//            exposeValueLabel.isHidden=true
//            LEDBar.isHidden=true
//            LEDLabel.isHidden=true
//            LEDValueLabel.isHidden=true
//        }
      //  if setteiMode==2{
      //      startButton.isEnabled=false
      //  }else{
      //      startButton.isEnabled=true
      //  }
        if recordingFlag==true {
            hideButtonsSlides()
            explanationLabel.isHidden=true
            stopButton.isHidden=false
            startButton.isHidden=true
            currentTime.isHidden=false
            previewLabel.isHidden=true
            previewSwitch.isHidden=true
            playButton.isHidden=true
            cameraChangeButton.isHidden=true
            listButton.isHidden=true
            if cameraType == 0{
                quaternionView.alpha=0.1
                cameraView.alpha=0.3
                currentTime.alpha=0.1
            }else{
                currentTime.alpha=1
                cameraView.alpha=1
                quaternionView.alpha=1
            }
        }else{
            explanationLabel.isHidden=false
            stopButton.isHidden=true
            startButton.isHidden=false
            currentTime.isHidden=true
            playButton.isHidden=false
            cameraChangeButton.isHidden=false
            listButton.isHidden=false
            currentTime.alpha=1
            cameraView.alpha=1
            quaternionView.alpha=1
        }
        
    }
//    func wifiCam(){
////        cameraView.isHidden=true
//
//    }
    @IBAction func onCameraChangeButton(_ sender: UIButton) {
        
        print(sender.frame.minX)
//        let kkk=sender
//        print(kkk)
        if sender.frame.minX>view.bounds.width/2{//camerachangebutton
            cameraType = cameraChange(cameraType)
        }
        UserDefaults.standard.set(cameraType, forKey: "cameraType")
        setButtonsDisplay()
        if cameraType == 5{
            defaultButton.isHidden=true
            enterButton.isHidden=true
            urlInputField.isHidden=true
            focusBar.isHidden=true
            focusLabel.isHidden=true
            focusValueLabel.isHidden=true
            captureSession.stopRunning()
//            wifiCam()
            //ここからwifiCapnys
            return
        }
        captureSession.stopRunning()
        set_rpk_ppk()
        initSession(fps: 60)
        onLEDValueChange()
        onFocusValueChange()
        zoomBar.value=UserDefaults.standard.float(forKey: "zoomValue")
        setZoom(level: zoomBar.value)
//        if cameraType==0{
//            LEDBar.isHidden=true
//            LEDLabel.isHidden=true
//            LEDValueLabel.isHidden=true
//        }else{
//            LEDBar.isHidden=false
//            LEDLabel.isHidden=false
//            LEDValueLabel.isHidden=false
//        }
        if focusChangeable==false{
            focusBar.isHidden=true
            focusLabel.isHidden=true
            focusValueLabel.isHidden=true
        }else{
            focusBar.isHidden=false
            focusLabel.isHidden=false
            focusValueLabel.isHidden=false
        }

        onExposeValueChange()
//        setButtons()
//        cameraType=UserDefaults.standard.integer(forKey:"cameraType")
//        var explanationText = cameraTypeStrings[cameraType]
//        if explanationLabeltextColor==UIColor.systemOrange{
//            explanationText=""
//        }
//        if someFunctions.firstLang().contains("ja"){
//            explanationLabel.text=explanationText + "録画設定"
//        }else{
//            explanationLabel.text=explanationText + "Record Settings"
//        }
    }
    
    func initSession(fps:Double) {
        // カメラ入力 : 背面カメラ
//        cameraType=UserDefaults.standard.integer(forKey:"cameraType")

        if cameraType == 0 || cameraType == 4 || cameraType == 5{//wifiCamera : 5
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)//.back)
        }else if cameraType == 1{
            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }else if cameraType == 2{
            videoDevice = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back)
        }else if cameraType == 3{
            videoDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
        }
        
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)

        if setVideoFormat(desiredFps: fps)==false{
            print("error******")
        }else{
            print("no error****")
        }
        // AVCaptureSession生成
        captureSession = AVCaptureSession()
        captureSession.addInput(videoInput)
        
//        // 音声のインプット設定
//        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)
//        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
//        captureSession.addInput(audioInput)
//以上のようなことは出来そうにない
        // プレビュー出力設定
        whiteView.layer.frame=CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        cameraView.layer.frame=CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        cameraView.layer.addSublayer(   whiteView.layer)
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        if cameraType == 0{
            let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
            let width=view.bounds.width
            let height=view.bounds.height
            videoLayer.frame = CGRect(x:leftPadding+10,y:height*2.5/6,width:width/6,height:height/6)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }else{
            videoLayer.frame=self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
        }
        //info right home button
        let landscapeSide=someFunctions.getUserDefaultInt(str: "landscapeSide", ret: 0)
        if landscapeSide==0{
            videoLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }else{
            videoLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        }
        cameraView.layer.addSublayer(videoLayer)

        // VideoDataOutputを作成、startRunningするとそれ以降delegateが呼ばれるようになる。
        let videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
        //         videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        //         videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoDataOutput)
        captureSession.startRunning()
        
        // ファイル出力設定
        startTimeStamp = 0
        //一時ファイルはこの時点で必ず消去
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        setMotion()//作動中ならそのまま戻る
        fileWriter = try? AVAssetWriter(outputURL: fileURL as URL, fileType: AVFileType.mov)
        
        let videoOutputSettings: Dictionary<String, AnyObject> = [
            AVVideoCodecKey: AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey: iCapNYSWidth as AnyObject,
            AVVideoHeightKey: iCapNYSHeight as AnyObject
        ]
        fileWriterInput = AVAssetWriterInput(mediaType:AVMediaType.video, outputSettings: videoOutputSettings)
        fileWriterInput.expectsMediaDataInRealTime = true
        fileWriter.add(fileWriterInput)
        
        fileWriterAdapter = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: fileWriterInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String:Int(kCVPixelFormatType_32BGRA),
                kCVPixelBufferHeightKey as String: iCapNYSWidth,
                kCVPixelBufferWidthKey as String: iCapNYSHeight,
            ]
        )
    }

    override func viewDidAppear(_ animated: Bool) {

    }
    func setProperty(label:UILabel,radius:CGFloat){
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = radius
    }
    var startButtonsHeight:CGFloat=0
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
/*        let move:CGPoint = sender.translation(in: self.view)
//        let pos = sender.location(in: self.view)
        print("panGesture")
        if recordingFlag==true{
            return
        }
        if sender.state == .began {
            startButtonsHeight=CGFloat(camera.getUserDefaultFloat(str: "buttonsHeight", ret: 0))
        } else if sender.state == .changed {
            var changedButtonHeight=startButtonsHeight - move.y
            if changedButtonHeight>view.bounds.height/5{
                changedButtonHeight=view.bounds.height/5
            }else if changedButtonHeight<0{
                changedButtonHeight = 0
            }
            UserDefaults.standard.set(changedButtonHeight,forKey: "buttonsHeight")
        }else if sender.state == .ended{
        }*/
    }
    func setPreviewLabel(){
        if cameraType == 0 && setteiMode != 2{
            previewLabel.isHidden=false
            previewSwitch.isHidden=false
            if previewSwitch.isOn{
                if someFunctions.firstLang().contains("ja"){
                    previewLabel.text="プレビュー有"
                }else{
                    previewLabel.text="Preview ON"
                }
            }else{
                if someFunctions.firstLang().contains("ja"){
                    previewLabel.text="プレビュー無"
                }else{
                    previewLabel.text="Preview OFF"
                }
            }
        }else{
            previewLabel.isHidden=true
            previewSwitch.isHidden=true
        }
    }
    func setButtonsLocation(){
//        let height=CGFloat(camera.getUserDefaultFloat(str: "buttonsHeight", ret: 0))
//pangestureによるボタンの高さ調整は不能とした。
        let sp=realWinWidth/120//間隙
        let bw=(realWinWidth-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by1 = realWinHeight - bh - sp// - bh*2/3//-height
        let by = realWinHeight - (bh+sp)*2// - bh*2/3//-height
        let x0=leftPadding+sp*2
        let y0=topPadding+sp*3
        previewSwitch.frame = CGRect(x:leftPadding+10,y:view.bounds.height*3.5/6+sp,width: bw,height: bh)
        let switchHeight=previewSwitch.frame.height
        previewLabel.frame=CGRect(x:x0,y:view.bounds.height*2.5/6-bh,width: bw*5,height: bh)
        myFunctions().setButtonProperty(defaultButton, x: x0, y: y0, w: bw, h: bh, UIColor.darkGray,0)
        myFunctions().setButtonProperty(enterButton,x:x0+bw*6+sp*6,y:y0,w:bw,h:bh,UIColor.darkGray,0)
        urlLabel.frame=CGRect(x:x0,y:sp*2+bh,width:realWinWidth-sp*4,height: bh)
        urlInputField.frame=CGRect(x:x0+bw+sp,y:y0,width:bw*5+sp*4,height: bh)
        urlInputField.layer.borderWidth = 1.0
        urlInputField.layer.cornerRadius=5
        urlInputField.layer.masksToBounds = true
        focusBar.frame = CGRect(x:x0+bw+sp, y: by, width:bw*2+sp, height: bh)
        LEDBar.frame = CGRect(x:x0+bw+sp,y:by1,width:bw*2+sp,height:bh)
        
        zoomBar.frame = CGRect(x:x0+bw*4+sp*4,y:by,width:bw*2+sp,height: bh)
        exposeBar.frame = CGRect(x:x0+bw*4+sp*4,y:by1,width:bw*2+sp,height: bh)
        camera.setLabelProperty(exposeLabel, x: x0+bw*3+sp*3, y: by1, w: bw, h: bh, UIColor.white)
        camera.setLabelProperty(exposeValueLabel,x:x0+bw*3.5+sp*3, y: by1, w: bw/2-2, h: bh/2, UIColor.white,0)
        camera.setLabelProperty(zoomLabel,x:x0+bw*3+sp*3,y:by,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(zoomValueLabel, x: x0+bw*3.5+sp*3, y: by, w: bw/2-2, h: bh/2, UIColor.white,0)
        camera.setLabelProperty(focusLabel,x:x0,y:by,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(focusValueLabel, x: x0+bw/2, y: by, w: bw/2-2, h: bh/2, UIColor.white,0)
        camera.setLabelProperty(LEDLabel,x:x0,y:by1,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(LEDValueLabel, x: x0+bw/2, y: by1, w: bw/2-2, h: bh/2, UIColor.white,0)
        camera.setButtonProperty(listButton,x:x0+bw*6+sp*6,y:by1,w:bw,h:bh,UIColor.darkGray,0)
        camera.setButtonProperty(cameraChangeButton,x:x0+bw*6+sp*6,y:by,w:bw,h:bh,UIColor.systemGreen,0)
        camera.setButtonProperty(manualButton,x:x0+bw*6+sp*6,y:by-bh-sp*2,w:bw,h:bh,UIColor.darkGray,0)
        camera.setButtonProperty(auto20sButton,x:x0+bw*6+sp*6,y:by-bh*2-sp*3,w:bw,h:bh,UIColor.darkGray,0)
        camera.setButtonProperty(auto90sButton,x:x0+bw*6+sp*6,y:by-bh*3-sp*4,w:bw,h:bh,UIColor.darkGray,0)
        setProperty(label: currentTime, radius: 4)
        camera.setButtonProperty(playButton,x:x0+bw*6+sp*6,y:topPadding+sp,w:bw,h:bw*realWinHeight/realWinWidth,UIColor.darkGray,0)

        currentTime.font = UIFont.monospacedDigitSystemFont(ofSize: view.bounds.width/30, weight: .medium)
        currentTime.frame = CGRect(x:x0+sp*6+bw*6, y: topPadding+sp, width: bw, height: bw*240/440)
        currentTime.alpha=0.5
        quaternionView.frame=CGRect(x:leftPadding+sp,y:sp,width:realWinHeight/5,height:realWinHeight/5)
       // if setteiMode != 0{//setteiMode==0 record, 1:manual 2:auto
            startButton.frame=CGRect(x:leftPadding+realWinWidth/2-realWinHeight/4,y:realWinHeight/4+topPadding,width: realWinHeight/2,height: realWinHeight/2)
        
        
        
        startButton.frame=CGRect(x:x0+bw*6+sp*6-sp,y:(realWinHeight-bw)/2-sp,width: bw+2*sp,height:bw+2*sp)

       // }else{
       //     explanationLabel.isHidden=true
       //     startButton.frame=CGRect(x:leftPadding+realWinWidth/2-realWinHeight/2,y:sp+topPadding,width: realWinHeight,height: realWinHeight)
       // }
        stopButton.frame=CGRect(x:leftPadding+realWinWidth/2-realWinHeight/2,y:sp+topPadding,width: realWinHeight,height: realWinHeight)
//        let ex1=realWinWidth/3
//        let ey1=sp
//        urlInputField.frame=CGRect(x:x0+bw+sp,y:y0,width:bw*5+sp*4,height: bh)
//       camera.setButtonProperty(cameraChangeButton,x:x0+bw*6+sp*6,y:by,w:bw,h:bh,UIColor.systemGreen,0)
        
        explanationLabel.frame=CGRect(x:x0+bw*6+sp*6-sp*2,y:by-1.5*bh,width:bw+sp*4,height:bh*1.5)
        var explanationText = cameraTypeStrings[cameraType]
        if explanationLabeltextColor==UIColor.systemOrange{
           explanationText=""
        }
        if someFunctions.firstLang().contains("ja"){
            explanationLabel.text=explanationText// + "録画設定"
        }else{
            explanationLabel.text=explanationText// + "Record Settings"
        }
    //    if setteiMode == 0{//slider labelを隠す 0:record
    //            hideButtonsSlides()
    //    }
//        if setteiMode==2{
//            cameraChangeButton.isEnabled=false
//            //previewSwitch.isHidden=true
//          //  previewLabel.isHidden=true
//            focusBar.isHidden=true
//            focusLabel.isHidden=true
//            focusValueLabel.isHidden=true
//            LEDLabel.isHidden=true
//            LEDBar.isHidden=true
//            LEDValueLabel.isHidden=true
//            urlLabel.isHidden=true
//            urlInputField.isHidden=true
//            enterButton.isHidden=true
//            defaultButton.isHidden=true
////            manualButton.isHidden=true
////            auto20sButton.isHidden=true
////            auto90sButton.isHidden=true
//        }
    }
  
    @IBAction func onClickStopButton(_ sender: Any) {
        recordingFlag=false
        setButtonsDisplay()
//        stopButton.isHidden=true
//        startButton.isHidden=false
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.double(forKey: "brightness"))

        if let soundUrl = URL(string:
                                "/System/Library/Audio/UISounds/begin_record.caf"){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
        
     //   motionManager.stopDeviceMotionUpdates()

        if fileWriter!.status == .writing {
            fileWriter!.finishWriting {
                debugPrint("trying to finish")
                return
            }
            while fileWriter!.status == .writing {
                sleep(UInt32(0.1))
            }
            debugPrint("done!!")
        }
        
        if FileManager.default.fileExists(atPath: TempFilePath){
            print("tempFileExists")
        }
        let fileURL = URL(fileURLWithPath: TempFilePath)
        if camera.albumExists()==true{
            PHPhotoLibrary.shared().performChanges({ [self] in
                //let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: avAsset)
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for:camera.getPHAssetcollection())
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
                //imageID = assetRequest.placeholderForCreatedAsset?.localIdentifier
                print("file add to album")
            }) { [self] (isSuccess, error) in
                if isSuccess {
                    // 保存した画像にアクセスする為のimageIDを返却
                    //completionBlock(imageID)
                    print("success")
                    self.saved2album=true
                } else {
                    //failureBlock(error)
                    print("fail")
                    //                print(error)
                    self.saved2album=true
                }
            }
        }else{
            //アプリ起動中にアルバムを削除して録画するとここを通る。
            stopButton.isHidden=true
            //と変更することで、Exitボタンで帰った状態にする。
        }
   //     motionManager.stopDeviceMotionUpdates()
        captureSession.stopRunning()
//        onCameraChangeButton(stopButton)
    //    killTimer()
        while saved2album==false{
            sleep(UInt32(0.1))
        }
        
        
       // if someFunctions.videoPHAsset.count<5{
            someFunctions.getAlbumAssets()
       //     print("count<5")
       // }else{
            someFunctions.getAlbumAssets_last()
      //      print("count>4")
      //  }
        //    cameraChangeButton.isHidden=false
        //    currentTime.isHidden=true
        setButtonsDisplay()
        onCameraChangeButton(stopButton)
        setPlayButtonImage()
        //  print("segue:","\(segue.identifier!)")
        //   Controller.motionManager.stopDeviceMotionUpdates()
        //   Controller.captureSession.stopRunning()
        //     performSegue(withIdentifier: "fromRecord", sender: self)
    }
    
    func hideButtonsSlides() {
        zoomLabel.isHidden=true
        zoomValueLabel.isHidden=true
        zoomBar.isHidden=true
        focusLabel.isHidden=true
        focusValueLabel.isHidden=true
        focusBar.isHidden=true
        LEDLabel.isHidden=true
        LEDBar.isHidden=true
        LEDValueLabel.isHidden=true
        exposeLabel.isHidden=true
        exposeValueLabel.isHidden=true
        exposeBar.isHidden=true
        cameraChangeButton.isHidden=true
        currentTime.isHidden=false
        manualButton.isHidden=true
        auto20sButton.isHidden=true
        auto90sButton.isHidden=true
    }

    @IBAction func onClickStartButton(_ sender: Any) {
        //hideButtonsSlides()
      //  setButtonsDisplay()
        timerCnt=0
        currentTime.text="0:00"
        recordingFlag=true
        setButtonsDisplay()
        UIApplication.shared.isIdleTimerDisabled = true  //スリープさせない
//***************説明ビデオの後半部分の削除
        if cameraType == 4{
            captureSession.stopRunning()
            let nextView = storyboard?.instantiateViewController(withIdentifier: "AUTORECORD") as! AutoRecordViewController
            nextView.isPositional=true
            UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")//cgfloat-double?
            self.present(nextView, animated: false, completion: nil)
            return
        }
//***************
        if cameraType == 5{
            let nextView = storyboard?.instantiateViewController(withIdentifier: "WIFI") as! WifiViewController
//            nextView.recordingFlag=true
            self.present(nextView, animated: false, completion: nil)
            return
        }
        if cameraType == 0{
            UIScreen.main.brightness = 1
        }
        stopButton.isEnabled=false//timerで３秒後にtrue
        listButton.isHidden=true
        if cameraType == 0 && previewSwitch.isOn==false{
            quaternionView.isHidden=true
            cameraView.isHidden=true
            currentTime.alpha=0.1
        }
        try? FileManager.default.removeItem(atPath: TempFilePath)
  //      startRecord()
        stopButton.isEnabled=true
        if let soundUrl = URL(string:
                                "/System/Library/Audio/UISounds/begin_record.caf"/*photoShutter.caf*/){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
        fileWriter!.startWriting()
        fileWriter!.startSession(atSourceTime: CMTime.zero)
        setMotion()
 //       timerCnt=0
    }

    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBAction func tapGest(_ sender: UITapGestureRecognizer) {
//        if recordingFlag==true{
//            return
//        }
//        if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
//            print("doubleTapPlay")
//            if setteiMode != 0{
//                zoomBar.isHidden=false
//                zoomLabel.isHidden=false
//                focusBar.isHidden=false
//                focusLabel.isHidden=false
//                focusValueLabel.isHidden=false
//            }
//        }
//        tapInterval=CFAbsoluteTimeGetCurrent()
        setMotion()
//        let screenSize=cameraView.bounds.size
//        let x0 = sender.location(in: self.view).x
//        let y0 = sender.location(in: self.view).y
//
//        if y0>view.bounds.height*0.43{//screenSize.height/2{
//            return
//        }
//        let x = y0/screenSize.height
//        let y = 1.0 - x0/screenSize.width
//        let focusPoint = CGPoint(x:x,y:y)
//        if cameraType==1 || cameraType==2{
//            if let device = videoDevice{
//                do {
//                    try device.lockForConfiguration()
//                    device.focusPointOfInterest = focusPoint
//                    device.focusMode = .autoFocus
//                    device.unlockForConfiguration()
//                }
//                catch {
//                    // just ignore
//                }
//            }
//        }
    }
    @objc func onFocusValueChange(){
            setFocus(focus:focusBar.value)
            UserDefaults.standard.set(focusBar.value, forKey: "focusValue")
    }
    var focusChangeable:Bool=true
    func setFocus(focus:Float) {//focus 0:最接近　0-1.0
        focusChangeable=false
        if let device = videoDevice{
            if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
                print("focus_supported")
                focusValueLabel.text=(Int(focus*100)).description

                do {
                    try device.lockForConfiguration()
                    device.focusMode = .locked
                    device.setFocusModeLocked(lensPosition: focus, completionHandler: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                            device.unlockForConfiguration()
                        })
                    })
                    device.unlockForConfiguration()
                    focusChangeable=true
                }
                catch {
                    // just ignore
                    print("focuserror")
                }
            }else{
                print("focus_not_supported")
            }
        }
    }
//    @IBOutlet weak var isoBar: UISlider!
    
    @objc func onExposeValueChange(){//setteiMode==0 record, 1:manual 2:auto
        setExpose(expose:exposeBar.value)
        
        UserDefaults.standard.set(exposeBar.value, forKey: "exposeValue")
        UserDefaults.standard.set(exposeBar.value, forKey: "autoExposeValue")//add
        
    }

    func setExpose(expose:Float) {
        
        if let currentDevice=videoDevice{
            exposeValueLabel.text=Int(expose*1000/80).description

            do {
                try currentDevice.lockForConfiguration()
                defer { currentDevice.unlockForConfiguration() }
                
                // 露出を設定
                
                    currentDevice.exposureMode = .autoExpose
                    currentDevice.setExposureTargetBias(expose, completionHandler: nil)
                              
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }
    func setIso(iso: Float) {
        if let currentDevice=videoDevice{
            do {
                try currentDevice.lockForConfiguration()
                defer { currentDevice.unlockForConfiguration() }
                // ISO感度を設定
                currentDevice.exposureMode = .custom
                currentDevice.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration,
                                                    iso: iso,
                                                    completionHandler: nil)
                
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }
 
    //debug用、AVAssetWriterの状態を見るため、そのうち消去
    func printWriterStatus(writer: AVAssetWriter) {
        print("recordingFlag=", recordingFlag)
        switch writer.status {
        case .unknown :
            print("unknown")
        case .writing :
            print("writing")
        case .completed :
            print("completed")
        case .failed :
            print("failed")
        case .cancelled :
            print("cancelled")
        default :
            print("default")
        }
    }
    func monoChromeFilter(_ input: CIImage, intensity: Double) -> CIImage? {
        let ciFilter:CIFilter = CIFilter(name: "CIColorMonochrome")!
        ciFilter.setValue(input, forKey: kCIInputImageKey)
        ciFilter.setValue(CIColor(red: intensity, green: intensity, blue: intensity), forKey: "inputColor")
        ciFilter.setValue(1.0, forKey: "inputIntensity")
        return ciFilter.outputImage
      }
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage? {
          let sepiaFilter = CIFilter(name: "CISepiaTone")
          sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
          sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
          return sepiaFilter?.outputImage
       }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
     
        if fileWriter.status == .writing && startTimeStamp == 0 {
            startTimeStamp = sampleBuffer.outputPresentationTimeStamp.value
        }

        //全部UIImageで処理してるが、これでは遅いので全てCIImageで処理するように書き換えたほうがよさそう
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            //フレームが取得できなかった場合にすぐ返る
            print("unable to get image from sample buffer")
            return
        }
        //backCamera->.right  frontCamera->.left
        let frameCIImage = cameraType == 0 ? CIImage(cvImageBuffer: frame).oriented(CGImagePropertyOrientation.right):CIImage(cvImageBuffer: frame).oriented(CGImagePropertyOrientation.left)
        let matrix1 = CGAffineTransform(rotationAngle: -1*CGFloat.pi/2)
        //width:1280と設定しているが？
        //width:1920で飛んで来ている
          let matrix2 = CGAffineTransform(translationX: 0, y: CGFloat(1080))
        //2つのアフィンを組み合わせ
        let matrix = matrix1.concatenating(matrix2);
        
        let rotatedCIImage = monoChromeFilter(frameCIImage.transformed(by: matrix),intensity: 0.9)

        readingFlag=true
        let qCG0=CGFloat(quater0)
        let qCG1=CGFloat(quater1)
        let qCG2=CGFloat(quater2)
        let qCG3=CGFloat(quater3)
//        print(quater0,quater1,quater2,quater3)

        readingFlag=false
        
//        let quaterImage = drawHead(width: 130, height: 130, radius: 50+10,qOld0:qCG0, qOld1: qCG1, qOld2:qCG2,qOld3:qCG3)
        let quaterImage = drawHead(width: realWinHeight/2.5, height: realWinHeight/2.5, radius: realWinHeight/5-1,qOld0:qCG0, qOld1: qCG1, qOld2:qCG2,qOld3:qCG3)
        DispatchQueue.main.async {
          self.quaternionView.image = quaterImage
          self.quaternionView.setNeedsLayout()
        }
        //frameの時間計算, sampleBufferの時刻から算出
        let frameTime:CMTime = CMTimeMake(value: sampleBuffer.outputPresentationTimeStamp.value - startTimeStamp, timescale: sampleBuffer.outputPresentationTimeStamp.timescale)
        let frameUIImage = UIImage(ciImage: rotatedCIImage!)
//        print(frameUIImage.size.width,frameUIImage.size.height)
//        let iCapNYSH=CGFloat(iCapNYSHeight)
//        let iCapNYSW=CGFloat(iCapNYSWidth)
        UIGraphicsBeginImageContext(CGSize(width: iCapNYSWidthF, height: iCapNYSHeightF))
        frameUIImage.draw(in: CGRect(x:0, y:0, width:iCapNYSWidthF, height: iCapNYSHeightF))
        //let r=view.bounds.height/view.bounds.width
//        let r=iCapNYSH/iCapNYSW
        quaterImage.draw(in: CGRect(x:iCapNYSWidthF120, y:iCapNYSWidthF120, width:iCapNYSHeightF5,height: iCapNYSHeightF5))
        //写真で再生すると左上の頭位アニメが隠れてしまうので、中央右にも表示。
//        quaterImage.draw(in: CGRect(x:0/*CGFloat(iCapNYSHeight)-quaterImage.size.width*/, y:CGFloat(iCapNYSWidth)*3/4, width:quaterImage.size.width, height:quaterImage.size.height))
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let renderedBuffer = (renderedImage?.toCVPixelBuffer())!
//        print(String(format:"%.5f,%.5f,%.5f,%.5f",quater0,quater1,quater2,quater3))
//        printWriterStatus(writer: fileWriter)
        if (recordingFlag == true && startTimeStamp != 0 && fileWriter!.status == .writing) {
            if fileWriterInput?.isReadyForMoreMediaData != nil{
                //for speed check
                fileWriterAdapter.append(renderedBuffer, withPresentationTime: frameTime)
            }
        } else {
            //print("not writing")
        }
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }
}

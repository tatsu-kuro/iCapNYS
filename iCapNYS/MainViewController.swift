//
//  ViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2020/09/21.
//
// landscape_new:から動けない、conflictして、解消出来ない。
//
//  ViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2020/09/20.
//  これをdefaultにした。

import UIKit
import Photos
import AssetsLibrary
import CoreMotion

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var steelLabel: UILabel!
    @IBOutlet weak var postualLabel: UILabel!
    @IBOutlet weak var autoRecordButton: UIButton!
    let someFunctions = myFunctions()
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    let albumName:String = "iCapNYS"
    var videoCurrentCount:Int = 0
    var videoDate = Array<String>()
    @IBOutlet weak var how2Button: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topLabel: UILabel!
    private var videoCnt: [Int] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
/*
    //motion sensor*************************

    var tapInterval=CFAbsoluteTimeGetCurrent()
    var lastTapLeft:Bool=false
    var tapLeft:Bool=false
    let motionManager = CMMotionManager()
    var isStarted = false

    var deltay = Array<Int>()

    var kalmandata = Array<CGFloat>()
    var kalVs:[CGFloat]=[0.0001 ,0.001 ,0,0,0]
    func KalmanS(Q:CGFloat,R:CGFloat){
        kalVs[4] = (kalVs[3] + Q) / (kalVs[3] + Q + R)
        kalVs[3] = R * (kalVs[3] + Q) / (R + kalVs[3] + Q)
    }
    func Kalman(value:CGFloat)->CGFloat{
        KalmanS(Q:kalVs[0],R:kalVs[1])
        let result = kalVs[2] + (value - kalVs[2]) * kalVs[4]
        kalVs[2] = result
        return result
    }
    func KalmanInit(){
            kalVs[2]=0
            kalVs[3]=0
            kalVs[4]=0
    }
 
    func checkDelta(cnt:Int)->Int{//
        var ret:Int=0
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]>0{
            ret=deltay[cnt+2]-deltay[cnt+3]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]<0 && deltay[cnt+4]>0{
            ret=deltay[cnt+2]+deltay[cnt+3]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]==0 && deltay[cnt+4]>0{
            ret=deltay[cnt+2]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]<0{
            ret=deltay[cnt+2]-deltay[cnt+3]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]>0 && deltay[cnt+4]<0{
            ret=deltay[cnt+2]+deltay[cnt+3]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]==0 && deltay[cnt+4]<0{
            ret=deltay[cnt+2]-deltay[cnt+4]
        }
        return ret
    }
  
    
    func checkTap(cnt:Int)->Bool{
        let ave=checkDelta(cnt: cnt)
        if ave>3{
            tapLeft=false
            return true
        }else if ave < -3{
            tapLeft=true
            return true
        }
        return false
    }
  
    var cnt:Int=0
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        let ay=deviceMotion.userAcceleration.y
        kalmandata.append(Kalman(value: ay*25))
        let arrayCnt=kalmandata.count
        if arrayCnt>5{
            deltay.append(Int(kalmandata[arrayCnt-2]-kalmandata[arrayCnt-1]))
        }else{
            deltay.append(0)
        }
        if deltay.count>10{
            cnt += 1
            deltay.remove(at: 0)
            kalmandata.remove(at: 0)
            
            if checkTap(cnt: 0){
                if (CFAbsoluteTimeGetCurrent()-tapInterval)>0.3 && (CFAbsoluteTimeGetCurrent()-tapInterval)<0.5{
                    if tapLeft && lastTapLeft{
                        onAutoRecordButton(0)
                    }else if !tapLeft && !lastTapLeft{
                        onPositioningRecordButton(0)
                    }
                   
                }
                lastTapLeft=tapLeft
                tapInterval=CFAbsoluteTimeGetCurrent()
            }
        }
    }
    
    func stopMotion() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
    func startMotion(){
        KalmanInit()
        deltay.removeAll()
        kalmandata.removeAll()
        cnt=0
        // start monitoring sensor data
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        isStarted = true
    }
*/
    //motion sensor*****************
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews*******")

//        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            let topPadding = self.view.safeAreaInsets.top
            let bottomPadding = self.view.safeAreaInsets.bottom
            let leftPadding = self.view.safeAreaInsets.left
            let rightPadding = self.view.safeAreaInsets.right
            UserDefaults.standard.set(topPadding,forKey: "topPadding")
            UserDefaults.standard.set(bottomPadding,forKey: "bottomPadding")
            UserDefaults.standard.set(leftPadding,forKey: "leftPadding")
            UserDefaults.standard.set(rightPadding,forKey: "rightPadding")
            setButtons()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    //これは.isHiddenとする
    @IBOutlet weak var setteiButtonAuto: UIButton!
    @IBOutlet weak var setteiButtonManual: UIButton!
    @IBOutlet weak var positioningAutoRecordButton: UIButton!
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        let landscapeSide=someFunctions.getUserDefaultInt(str: "landscapeSide", ret: 0)
//        if landscapeSide==0{
//            return UIInterfaceOrientationMask.landscapeRight
//        }else{
//            return UIInterfaceOrientationMask.landscapeLeft
//        }
//    }
    //setteiMode 0:Camera 1:manual_settei(green) 2:auto_settei(orange)
    @IBAction func onCameraButton(_ sender: Any) {
        checkLibraryAuthorized()
        if authorizedFlag != 2{
            print("not authorized!!!")
            alertNotAuthorized()
            return
        }
 //       stopMotion()
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        let cameraType=someFunctions.getUserDefaultInt(str: "cameraType", ret: 0)
        let frontCameraMode=someFunctions.getUserDefaultInt(str:"frontCameraMode",ret: 0)
        if cameraType==0 && frontCameraMode==1{
            onAutoRecordButton(0)
            return
        }else if cameraType==0 && frontCameraMode==2{
            onPositioningRecordButton(0)
            return
        }
        if cameraType==5{
            let nextView1 = storyboard?.instantiateViewController(withIdentifier: "WIFI") as! WifiViewController
            self.present(nextView1, animated: true, completion: nil)
        }else{
            let nextView = storyboard?.instantiateViewController(withIdentifier: "RECORD") as! RecordViewController
            nextView.setteiMode=0
            nextView.autoRecordMode=false
            self.present(nextView, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSetteiButtonAuto(_ sender: Any) {
  //      stopMotion()
        checkLibraryAuthorized()
        if authorizedFlag != 2{
            print("not authorized!!!",authorizedFlag)
            alertNotAuthorized()
            return
        }
        let nextView = storyboard?.instantiateViewController(withIdentifier: "RECORD") as! RecordViewController
        nextView.setteiMode=2
        nextView.autoRecordMode=false
        nextView.explanationLabeltextColor=UIColor.systemOrange
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func onSetteiButtonManual(_ sender: Any) {
        checkLibraryAuthorized()
        if authorizedFlag != 2{
            print("not authorized!!!",authorizedFlag)
            alertNotAuthorized()
            return
        }
 //       stopMotion()
        let nextView = storyboard?.instantiateViewController(withIdentifier: "RECORD") as! RecordViewController
        nextView.setteiMode=1
        nextView.autoRecordMode=false
        nextView.explanationLabeltextColor=UIColor.systemGreen
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func onPositioningRecordButton(_ sender: Any) {
//        stopMotion()
        let nextView = storyboard?.instantiateViewController(withIdentifier: "AUTORECORD") as! AutoRecordViewController
        nextView.isPositional=true
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")//cgfloat-double?
        self.present(nextView, animated: true, completion: nil)
    }
    @IBAction func onAutoRecordButton(_ sender: Any) {
 //       stopMotion()
        let nextView = storyboard?.instantiateViewController(withIdentifier: "AUTORECORD") as! AutoRecordViewController
        nextView.isPositional=false
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        self.present(nextView, animated: true, completion: nil)
    }
//    @IBAction func onChangeLandscapeSide(_ sender: Any) {
//        var landscapeSide=someFunctions.getUserDefaultInt(str: "landscapeSide", ret: 0)
//        if landscapeSide==0{
//            landscapeSide=1
//        }else{
//            landscapeSide=0
//        }
//        UserDefaults.standard.set(landscapeSide,forKey: "landscapeSide")
//        let nextView = storyboard?.instantiateViewController(withIdentifier: "HOW2") as! How2ViewController
//        self.present(nextView, animated: true, completion: nil)
//    }
    
    @IBAction func unwindAction(segue: UIStoryboardSegue) {
        print("segueWhat:",segue)
        if let vc = segue.source as? RecordViewController{
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
                UserDefaults.standard.set(0,forKey: "contentOffsetY")
                DispatchQueue.main.async { [self] in
                    self.tableView.contentOffset.y=0
                }
            }
 
            print("segue:","\(segue.identifier!)")
            Controller.motionManager.stopDeviceMotionUpdates()
            Controller.captureSession.stopRunning()
        }else if let vc1 = segue.source as? WifiViewController{
            let Controller:WifiViewController = vc1
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
                UserDefaults.standard.set(0,forKey: "contentOffsetY")
                DispatchQueue.main.async { [self] in
                    self.tableView.contentOffset.y=0
                    self.tableView.reloadData()//こちらだけこれが必要なのはどうして

                }
            }
   
            print("segue:","\(segue.identifier!)")
            Controller.motionManager.stopDeviceMotionUpdates()
//            Controller.captureSession.stopRunning()
            
        }else if let vc = segue.source as? AutoRecordViewController{
            let Controller:AutoRecordViewController = vc
            Controller.killTimer()//念の為
            if (Controller.isPositional==false && Controller.movieTimerCnt>25) ||
                (Controller.isPositional==true && Controller.movieTimerCnt>112){
                print("Exit / Auto recorded")
                if someFunctions.videoPHAsset.count<5{
                    someFunctions.getAlbumAssets()
                    print("count<5")
                }else{
                    someFunctions.getAlbumAssets_last()
                    print("count>4")
                }
                UserDefaults.standard.set(0,forKey: "contentOffsetY")
                DispatchQueue.main.async { [self] in
                    self.tableView.contentOffset.y=0
                    self.tableView.reloadData()//こちらだけこれが必要なのはどうして
                }
            }
  
            print("segue:","\(segue.identifier!)")
            Controller.motionManager.stopDeviceMotionUpdates()
            Controller.captureSession.stopRunning()
        }else if let vc = segue.source as? AutoRecordViewController{
        }else if let vc = segue.source as? BLEViewController{
            let Controller:BLEViewController = vc
            Controller.motionManager.stopDeviceMotionUpdates()
        }
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.double(forKey: "brightness"))
        UIApplication.shared.isIdleTimerDisabled = false//スリープする.監視する
        print("unwind")
//        isStarted=false
//        startMotion()
    }
    
//    func camera_alert(){
//        if PHPhotoLibrary.authorizationStatus() != .authorized {
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == .authorized {
//                    // フォトライブラリに写真を保存するなど、実施したいことをここに書く
//                } else if status == .denied {
//                }
//            }
//        } else {
//            // フォトライブラリに写真を保存するなど、実施したいことをここに書く
//        }
//        
//    }
    func alertNotAuthorized(){
        if someFunctions.firstLang().contains("ja"){
            let alert = UIAlertController(title: "写真アクセスエラー", message: "写真へのアクセスが制限されています。設定アプリを起動して、iCapNYSをタップし、写真をフルアクセスに設定して下さい。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Photos access error", message: "You do not have permission to access your photos.\nLaunch the Settings app,Tap the iCapNYS app,\nSet Photos to Full Access.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad*******")
  //      isStarted=false
 //       startMotion()
//        if PHPhotoLibrary.authorizationStatus() != .authorized {
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == .authorized {
//                    self.checkLibraryAuthrizedFlag=1
//                    print("authorized")
//                } else if status == .denied {
//                    self.checkLibraryAuthrizedFlag = -1
//                    print("denied")
//                }else{
//                    self.checkLibraryAuthrizedFlag = -1
//                }
//            }
//        }else{
        
//    checkLibraryAuthorized()
//        while(authorizedFlag == 0 || authorizedFlag == 4){
//            checkLibraryAuthorized()
//            print("authorizedFlag:",authorizedFlag)
//            sleep(UInt32(0.1))
//        }
            someFunctions.getAlbumAssets()//完了したら戻ってくるようにしたつもり
//        }
        //初回起動時にdefaultを設定
        let cameraType=someFunctions.getUserDefaultInt(str: "cameraType", ret: 0)
//        let topEndBlank=0//someFunctions.getUserDefaultInt(str: "topEndBlank", ret: 0)
            
//        UIApplication.shared.isIdleTimerDisabled = false//スリープする
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(foreground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil
        )
        print("authorizedFlag:",authorizedFlag)

     }
    @objc func foreground(notification: Notification) {
        print("フォアグラウンド")
//        startMotion()
    }
    override func viewDidAppear(_ animated: Bool) {
//        if UIApplication.shared.isIdleTimerDisabled == true{//スリープさせない
//            UIApplication.shared.isIdleTimerDisabled = false//監視する
//        }
        print("viewDidAppear*********")
        tableView.reloadData()
        let contentOffsetY = CGFloat(someFunctions.getUserDefaultFloat(str:"contentOffsetY",ret:0))
        DispatchQueue.main.async { [self] in
            self.tableView.contentOffset.y=contentOffsetY
        }
    }
    var authorizedFlag:Int=0
    func checkLibraryAuthorized(){
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .limited:
            self.authorizedFlag = 1
            print("limited")
            break
        case .authorized:
            self.authorizedFlag = 2
            print("authorized")
            break
        case .denied:
            self.authorizedFlag = 3
            print("denied")
            break
        default:
            self.authorizedFlag = 4
            break
        }
    }
    func setButtons(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))/2
        let ww:CGFloat=view.bounds.width-leftPadding-rightPadding
        let wh:CGFloat=view.bounds.height-topPadding-bottomPadding
        let sp=ww/120//間隙
//        let bw=(ww-sp*10)/7//ボタン幅
//         let x0=leftPadding+sp*2
        let x0but=view.bounds.width-rightPadding-wh*3/4
        let x1but=x0but+wh/2-wh/40
        let bw=view.bounds.width-x1but-rightPadding-2*sp
        let bh=bw*170/440
        let by=wh-bh-sp
        let by0=topPadding+sp
        someFunctions.setButtonProperty(setteiButtonManual, x:x1but, y: by, w: bw, h: bh, UIColor.darkGray,0)

        let cx=leftPadding+ww-wh*3/4+wh*5/13//-(x1but+sp/2-bw-sp))-cr
        let a=2*cx-x1but-bw
 //             sendButton.frame=CGRect(x:a/*x1but+sp/2-bw-sp*/, y:topPadding+sp, width: cr, height:cr )
        someFunctions.setButtonProperty(how2Button, x:/*a*/x1but+sp/2-bw-sp, y: by, w: bw, h: bh, UIColor.darkGray,0)
        someFunctions.setButtonProperty(sendButton, x:x1but, y:by0, w: bw, h: bh, UIColor.darkGray,0)
//        sendButton.isHidden=true
//        someFunctions.setButtonProperty(how2Button, x:x1but, y:by0, w: bw, h: bh, UIColor.darkGray,0)
        autoRecordButton.frame=CGRect(x:x0but,y:sp,width: wh/2,height: wh/2)
        positioningAutoRecordButton.frame=CGRect(x:x0but,y:wh/2-sp,width: wh/2,height: wh/2)
        let upCircleX0=sp+wh/4
        let downCircleX0=wh/2-sp+wh/4
        steelLabel.frame=CGRect(x:x0but,y:upCircleX0-wh/9-bh/2,width: wh/2,height: bh*3.5)
        postualLabel.frame=CGRect(x:x0but,y:downCircleX0-wh/9-bh/2,width: wh/2,height: bh*3.5)
       //下ボタンを有効にするとLandscapeLeft,Rightを変更可能となる。infoに(left home button),(right home button)両方指定
//        changeLandscapeSideButton.isHidden=true
        //以下2行ではRightに設定。leftに変更するときは、infoにもlandscape(left home button)を設定
        let landscapeSide=0//0:right 1:left
        UserDefaults.standard.set(landscapeSide,forKey: "landscapeSide")
        tableView.frame = CGRect(x:leftPadding,y:topPadding+sp,width: ww-wh*3/4,height: wh-sp*2)
   
        cameraButton.frame=CGRect( x: tableView.frame.maxX, y:topPadding+wh*3/26,width:wh*10/13, height: wh*10/13)
//        cameraButton.frame=CGRect( x: view.bounds.width-rightPadding-wh*3/4, y:topPadding+wh*3/26,width:wh*10/13, height: wh*10/13)
        //高さ/20を上下に開ける
  
        if someFunctions.firstLang().contains("ja"){
            how2Button.setTitle("使い方", for: .normal)
            setteiButtonAuto.setTitle("録画設定", for: .normal)
            setteiButtonManual.setTitle("録画設定", for: .normal)
            steelLabel.text="座って記録\n20秒"
            postualLabel.text="横になって記録\n90秒"
        }
        postualLabel.isHidden=true
        steelLabel.isHidden=true
        autoRecordButton.isHidden=true
        positioningAutoRecordButton.isHidden=true
        setteiButtonAuto.isHidden=true
    //    sendButton.isHidden=true
    }
  
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("viewWillAppear********")
//        UIApplication.shared.isIdleTimerDisabled = false//スリープさせる
//    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //            // 画面非表示直後の処理を書く
        //            print("画面非表示直後")
        //        UserDefaults.standard.set(0,forKey: "contentOffsetY")
        //
        let contentOffsetY = tableView.contentOffset.y
        print("offset:",contentOffsetY)
        UserDefaults.standard.set(contentOffsetY,forKey: "contentOffsetY")
    }
    //nuber of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let topEndBlank=0//UserDefaults.standard.integer(forKey:"topEndBlank")
        if topEndBlank==0{
            return someFunctions.videoDate.count
        }else{
            return someFunctions.videoDate.count+2
        }
    }
    
    //set data on cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"cell",for :indexPath)
        let topEndBlank=0//UserDefaults.standard.integer(forKey:"topEndBlank")
       /* if topEndBlank==0{
            let number = (indexPath.row+1).description + ") "
            cell.textLabel!.text = number + someFunctions.videoDate[indexPath.row]
        }else{
            let number = (indexPath.row).description + ") "
            if indexPath.row==0 || indexPath.row==someFunctions.videoDate.count+1{
                cell.textLabel!.text = " "
            }else{
                cell.textLabel!.text = number + someFunctions.videoDate[indexPath.row-1]
            }
        }*/
        var cellText:String=""
        if topEndBlank==0{
            let number = (indexPath.row+1).description + ")"
           // cell.textLabel!.text = number + someFunctions.videoDate[indexPath.row]
            cellText = number + someFunctions.videoDate[indexPath.row]
        }else{
            let number = (indexPath.row).description + ")"
            if indexPath.row==0 || indexPath.row==someFunctions.videoDate.count+1{
                cellText = " "
            }else{
                cellText = number + someFunctions.videoDate[indexPath.row-1]
            }
        }
        cell.textLabel?.font=UIFont(name:"Courier",size: 18)
    //    let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
           let attributedString = NSMutableAttributedString(string: cellText)
        attributedString.addAttribute(.kern, value: 0, range: NSRange(location: 0, length: attributedString.length)) // 文字間隔を1.5に設定
           cell.textLabel?.attributedText = attributedString
        return cell
    }
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
    //play item
//    var contentOffsetY:CGFloat=0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topEndBlank=0//UserDefaults.standard.integer(forKey:"topEndBlank")
        var indexPathRow = indexPath.row
        if topEndBlank==1{
            if indexPath.row==0 || indexPath.row==someFunctions.videoDate.count+1{
                return
            }else{
             indexPathRow -= 1
            }
        }
//        let str=someFunctions.videoAlbumAssets[indexPath.row]?.a absoluteString
//        print(str as Any)
//        if str!.contains("temp.mp4"){
//            return
//        }
//        return
//        print("asset:",someFunctions.videoAlbumAssets[indexPath.row])
//        if someFunctions.videoURL[indexPath.row]==nil{
//            return
//        }
//        print(someFunctions.videoAlbumAssets[indexPath.row])
        videoCurrentCount=indexPathRow// indexPath.row
        print("video:",videoCurrentCount)
        let contentOffsetY = tableView.contentOffset.y
        print("offset:",contentOffsetY)
        UserDefaults.standard.set(contentOffsetY,forKey: "contentOffsetY")
        let phasset = someFunctions.videoPHAsset[indexPathRow]//indexPath.row]
        let avasset = requestAVAsset(asset: phasset)
        if avasset == nil {//なぜ？icloudから落ちてきていないのか？
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "playView") as! PlayViewController
      
//        nextView.videoURL = someFunctions.videoURL[indexPath.row]
        nextView.phasset = someFunctions.videoPHAsset[indexPathRow]// indexPath.row]
        nextView.avasset = avasset
        nextView.calcDate = someFunctions.videoDate[indexPathRow]
        
        self.present(nextView, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        print("set canMoveRowAt")
        return false
    }//not sort
    
    //セルの削除ボタンが押された時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let topEndBlank=0//UserDefaults.standard.integer(forKey:"topEndBlank")
        var indexPathRow:Int=indexPath.row
        if topEndBlank==1{
            if indexPath.row==0 || indexPath.row==someFunctions.videoDate.count+1{
                return
            }else{
                indexPathRow -= 1
            }
        }
        //削除するだけなのでindexPath_row = indexPath.rowをする必要はない。
        if editingStyle == UITableViewCell.EditingStyle.delete {
            someFunctions.eraseVideo(number: indexPathRow)
            print("erasevideo:",indexPathRow)
            while someFunctions.dialogStatus==0{
                sleep(UInt32(0.1))
            }
            if someFunctions.dialogStatus==1{
                someFunctions.videoPHAsset.remove(at: indexPathRow)
                someFunctions.videoDate.remove(at: indexPathRow)
                tableView.reloadData()
                if indexPath.row>4 && indexPath.row<someFunctions.videoDate.count{
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else if indexPath.row == someFunctions.videoDate.count && indexPath.row != 0{
                    let indexPath1 = IndexPath(row:indexPath.row-1,section:0)
                    tableView.reloadRows(at: [indexPath1], with: .fade)
                }
            }
        }
    }
   
}

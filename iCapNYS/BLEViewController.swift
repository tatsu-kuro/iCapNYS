//
//  BLEViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2023/06/25.
//

import UIKit
//import CoreBluetooth
import CoreMotion
import Network
//import NetworkExtension

class BLEViewController: UIViewController, UITextFieldDelegate {
    var pitchA = Array<Float>()
    var rollA = Array<Float>()
    var yawA = Array<Float>()
    let motionManager = CMMotionManager()
    var timer:Timer?
    var IPAddress:String?
    var pitchLimit:Int?
    var rollLimit:Int?
    var yawLimit:Int?
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var pitchText1: UITextField!
    @IBOutlet weak var pitchText2: UITextField!
    @IBOutlet weak var pitchText3: UITextField!
    @IBOutlet weak var pitchStepper: UIStepper!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var rollText1: UITextField!
    @IBOutlet weak var rollText2: UITextField!
    @IBOutlet weak var rollText3: UITextField!
    @IBOutlet weak var rollStepper: UIStepper!
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var yawText1: UITextField!
    @IBOutlet weak var yawText2: UITextField!
    @IBOutlet weak var yawText3: UITextField!
    @IBOutlet weak var yawStepper: UIStepper!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var ip1: UITextField!
    @IBOutlet weak var ip2: UITextField!
    @IBOutlet weak var ip3: UITextField!
    @IBOutlet weak var ip4: UITextField!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var exitButton: UIButton!
 //   var pLimit:Float=0
 //   var rLimit:Float=0
 //   var yLimit:Float=0
    func incPitchOK(){
        var t=Int(pitchText2.text!)
        t! += 1
        pitchText2.text=t?.description
    }
    func incRollOK(){
        var t=Int(rollText2.text!)
        t! += 1
        rollText2.text=t?.description
    }
    func incYawOK(){
        var t=Int(yawText2.text!)
        t! += 1
        yawText2.text=t?.description
    }
    func changeLimits(){
        pitchText3.text=Int(pitchStepper.value).description
        rollText3.text=Int(rollStepper.value).description
        yawText3.text=Int(yawStepper.value).description
        UserDefaults.standard.set(pitchStepper.value, forKey: "pitchLimit")
        UserDefaults.standard.set(rollStepper.value, forKey: "rollLimit")
        UserDefaults.standard.set(yawStepper.value, forKey: "yawLimit")
    }
    var kalVs:[[Float]]=[[0.0001 ,0.001 ,0,0,0],[0.0001 ,0.001 ,0,0,0],
                               [0.0001 ,0.001 ,0,0,0],[0.0001 ,0.001 ,0,0,0],
                               [0.0001 ,0.001 ,0,0,0],[0.0001 ,0.001 ,0,0,0],
                               [0.0001 ,0.001 ,0,0,0],[0.0001 ,0.001 ,0,0,0]]
    func KalmanS(Q:Float,R:Float,num:Int){
        kalVs[num][4] = (kalVs[num][3] + Q) / (kalVs[num][3] + Q + R);
        kalVs[num][3] = R * (kalVs[num][3] + Q) / (R + kalVs[num][3] + Q);
    }
    func Kalman(value:Float,num:Int)->Float{
        KalmanS(Q:kalVs[num][0],R:kalVs[num][1],num:num);
        let result = kalVs[num][2] + (value - kalVs[num][2]) * kalVs[num][4];
        kalVs[num][2] = result;
        return result;
    }
    func KalmanInit(){
        for i in 0...6{
            kalVs[i][2]=0
            kalVs[i][3]=0
            kalVs[i][4]=0
        }
    }
    func KalmanInit(num:Int){
        kalVs[num][2]=0
        kalVs[num][3]=0
        kalVs[num][4]=0
    }
    @IBAction func onPitchStepper(_ sender: UIStepper) {
        changeLimits()
    }
    
    @IBAction func onRollStepper(_ sender: UIStepper) {
        changeLimits()
    }
    @IBAction func onYawStepper(_ sender: UIStepper) {
        changeLimits()
    }
    @IBAction func onExitButton(_ sender: Any) {
        if UDPf {
            disconnect(connection: connection!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClickSetButton(_ sender: Any) {
        ip1.resignFirstResponder()
        ip2.resignFirstResponder()
        ip3.resignFirstResponder()
        ip4.resignFirstResponder()
        port.resignFirstResponder()
        let ips1 = ip1.text ?? "0"
        let ips2 = ip2.text ?? "0"
        let ips3 = ip3.text ?? "0"
        let ips4 = ip4.text ?? "0"
        IPAddress = ips1 + "." + ips2 + "." + ips3 + "." + ips4
        UserDefaults.standard.set(IPAddress, forKey: "IPAddress")
        connect(hostname: IPAddress!)
        setMotion()
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        ip1.resignFirstResponder()
        ip2.resignFirstResponder()
        ip3.resignFirstResponder()
        ip4.resignFirstResponder()
        port.resignFirstResponder()
        let ips1 = ip1.text ?? "0"
        let ips2 = ip2.text ?? "0"
        let ips3 = ip3.text ?? "0"
        let ips4 = ip4.text ?? "0"
        IPAddress = ips1 + "." + ips2 + "." + ips3 + "." + ips4
        UserDefaults.standard.set(IPAddress, forKey: "IPAddress")
        connect(hostname: IPAddress!)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        KalmanInit()
        IPAddress=myFunctions().getUserDefaultString(str: "IPAddress", ret: "192.168.1.1")
        pitchStepper.value=myFunctions().getUserDefaultDouble(str: "pitchLimit", ret:30)
        rollStepper.value=myFunctions().getUserDefaultDouble(str: "rollLimit", ret:30)
        yawStepper.value=myFunctions().getUserDefaultDouble(str: "yawLimit", ret:30)
        pitchText3.text=Int(pitchStepper.value).description
        rollText3.text=Int(rollStepper.value).description
        yawText3.text=Int(yawStepper.value).description
        pitchText2.text="0"
        rollText2.text="0"
        yawText2.text="0"
        pitchStepper.maximumValue=120
        pitchStepper.minimumValue=20
        rollStepper.maximumValue=120
        rollStepper.minimumValue=20
        yawStepper.maximumValue=120
        yawStepper.minimumValue=20
        let arr = IPAddress?.components(separatedBy: ".")
        ip1.text=arr?[0]
        ip2.text=arr?[1]
        ip3.text=arr?[2]
        ip4.text=arr?[3]
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        var top=CGFloat(UserDefaults.standard.float(forKey: "topPadding"))
        let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottomPadding"))
        let left=CGFloat(UserDefaults.standard.float(forKey: "leftPadding"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "rightPadding"))
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)
        let sp=ww/120//間隙
        var bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        bw=(ww-sp*11)/8
        myFunctions().setButtonProperty(exitButton,x:left+bw*7+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        logTextView.frame=CGRect(x:left+sp,y:top+bh*2+4*sp,width: ww-2*sp,height:bh);// by-3*sp-top-2*bh)
        topLabel.frame=CGRect(x:left+sp,y:top+sp,width:ww,height:bh)
        // Do any additional setup after loading the view.
    
        ipLabel.frame=CGRect(x:left+sp,y:top+bh+2*sp,width: bw,height: bh)
        ip1.frame=CGRect(x:left+bw*1+sp*2,y:top+bh+2*sp,width: bw,height: bh)
        ip2.frame=CGRect(x:left+bw*2+sp*3,y:top+bh+2*sp,width: bw,height: bh)
        ip3.frame=CGRect(x:left+bw*3+sp*4,y:top+bh+2*sp,width: bw,height: bh)
        ip4.frame=CGRect(x:left+bw*4+sp*5,y:top+bh+2*sp,width: bw,height: bh)
        portLabel.frame=CGRect(x:left+bw*5+sp*6,y:top+bh+2*sp,width: bw,height: bh)
        port.frame=CGRect(x:left+bw*6+sp*7,y:top+bh+2*sp,width: bw,height: bh)
        myFunctions().setButtonProperty(setButton,x:left+bw*7+sp*8,y:top+bh+2*sp,w:bw,h:bh,UIColor.darkGray)
        top=top+bh*2+3*sp
        bw=ww/5
        //bh=(by-top-bh-2*20-3*sp)/3
        pitchLabel.frame=CGRect(x:left+sp,y:top+bh+2*sp,width: bw,height: bh)
        pitchText1.frame=CGRect(x:left+bw*1+sp*2,y:top+bh+2*sp,width: bw,height: bh)
        pitchText2.frame=CGRect(x:left+bw*2+sp*3,y:top+bh+2*sp,width: bw,height: bh)
        pitchText3.frame=CGRect(x:left+bw*3+sp*4,y:top+bh+2*sp,width: bw,height: bh)
        pitchStepper.frame=CGRect(x:left+bw*4+sp*5,y:top+bh+2*sp,width: bw,height: bh)
        top=top+bh+sp
        rollLabel.frame=CGRect(x:left+sp,y:top+bh+2*sp,width: bw,height: bh)
        rollText1.frame=CGRect(x:left+bw*1+sp*2,y:top+bh+2*sp,width: bw,height: bh)
        rollText2.frame=CGRect(x:left+bw*2+sp*3,y:top+bh+2*sp,width: bw,height: bh)
        rollText3.frame=CGRect(x:left+bw*3+sp*4,y:top+bh+2*sp,width: bw,height: bh)
        rollStepper.frame=CGRect(x:left+bw*4+sp*5,y:top+bh+2*sp,width: bw,height: bh)
        top=top+bh+sp
        yawLabel.frame=CGRect(x:left+sp,y:top+bh+2*sp,width: bw,height: bh)
        yawText1.frame=CGRect(x:left+bw*1+sp*2,y:top+bh+2*sp,width: bw,height: bh)
        yawText2.frame=CGRect(x:left+bw*2+sp*3,y:top+bh+2*sp,width: bw,height: bh)
        yawText3.frame=CGRect(x:left+bw*3+sp*4,y:top+bh+2*sp,width: bw,height: bh)
        yawStepper.frame=CGRect(x:left+bw*4+sp*5,y:top+bh+2*sp,width: bw,height: bh)
        myFunctions().setButtonProperty(resetButton,x:left+bw*2+sp*3,y:top+bh*2+3*sp,w:bw,h:bh,UIColor.systemGray6)

        UIApplication.shared.isIdleTimerDisabled = true//スリープさせない
        timer = Timer.scheduledTimer(timeInterval: 5*60, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
 //       setMotion()
    }
    var host: NWEndpoint.Host = "192.168.0.209"
    var port1108: NWEndpoint.Port = 1108

    var connection: NWConnection?
    var UDPf:Bool=false
    func disconnect(connection: NWConnection)
    {
        /* コネクション切断 */
        connection.cancel()
    }
    var cnt:Int = 0
    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ sendError in
            if let error = sendError {
                print("Unable to process and send the data: \(error)")
            } else {
                self.cnt +=   1
//                print("Data has been sent:",self.cnt)
//                connection!.receiveMessage { (data, context, isComplete, error) in
//                    guard let myData = data else { return }
//                    print("Received message: " + String(decoding: myData, as: UTF8.self))
//                }
            }
        }))
    }
    
    func connect(hostname:String) {
  //      var host:NWEndpoint.Host = "192.168.0.209"//hostname
        let host:NWEndpoint.Host = NWEndpoint.Host(hostname)
        connection = NWConnection(host: host, port: port1108, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                print("Entered state: preparing")
            case .ready:
                print("Entered state: ready")
            case .setup:
                print("Entered state: setup")
            case .cancelled:
                print("Entered state: cancelled")
            case .waiting:
                print("Entered state: waiting")
            case .failed:
                print("Entered state: failed")
            default:
                print("Entered an unknown state")
            }
        }
        
        connection!.viabilityUpdateHandler = { [self] (isViable) in
            if (isViable) {
                print("Connection is viable")
                UDPf=true
            } else {
                UDPf=false
                print("Connection is not viable")
            }
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                print("A better path is availble")
            } else {
                print("No better path is available")
            }
        }
        
        connection!.start(queue: .global())
    }
 
    @objc func update(tm: Timer) {
        UIApplication.shared.isIdleTimerDisabled = false//スリープさせる
        print("isIdle false")
    }
    var yaw180cnt:Int = 0//180°or -180°を越えた回数
    var theLastYaw:Float = 0
    func getYaw(y:Float)->Float {
        if (yawA.count==0) {
            theLastYaw = y
            return y
        }
        else {
            if (theLastYaw > 100 && y < -100){
                yaw180cnt += 1
            }
            else if (theLastYaw < -100 && y>100){
                yaw180cnt -= 1
            }
            theLastYaw = y
            return y + Float(yaw180cnt * 360)
        }
    }

    func getDirection(a:Float, b:Float, c:Float, d:Float)->Int
    {
        if ((a+1 < b) && (b+1 < c) && (c+1 < d)){  return 1}
        else if ((a > b+1) && (b > c+1) && (c > d+1)){return -1}
        else {return 0}
    }

    let RAD_TO_DEG=Float(180/3.1415)
    func QuaternionToEuler(q0:Float, q1:Float,q2:Float, q3: Float) {
        var pitch:Float
        var roll:Float
        var yaw:Float
        pitch = asin(-2 * q1 * q3 + 2 * q0 * q2);    // pitch
        roll = atan2(2 * q2 * q3 + 2 * q0 * q1, -2 * q1 * q1 - 2 * q2 * q2 + 1);    // roll
        yaw = atan2(2 * (q1 * q2 + q0 * q3), q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3);    //yaw

        pitch *= RAD_TO_DEG;
        yaw *= RAD_TO_DEG;
        // Declination of SparkFun Electronics (40°05'26.6"N 105°11'05.9"W) is
        //     8° 30' E  ± 0° 21' (or 8.5°) on 2016-07-19
        // - http://www.ngdc.noaa.gov/geomag-web/#declination
    //    yawf -= 8.5;
        roll *= RAD_TO_DEG;
        pitchA.append(Kalman(value: pitch, num: 0))
        rollA.append(Kalman(value: roll, num: 1))
        let yawtmp=getYaw(y:yaw)
        yawA.append(Kalman(value: yawtmp, num: 2))
        self.pitchText1.text=Int(pitch).description
        self.rollText1.text=Int(roll).description
        self.yawText1.text=Int(yawtmp).description
      
//        pitch = int(pitchf);
//        roll = int(rollf);
//        yaw = int(yawf);
    }
    func checkOK( d0:Float,d1:Float,limit:Float,count:Int)->Int
    {
        var d = d0 - d1
        if (count < 5){return 0}//5*40ms
        if (d > limit || d < -limit)
        {
            if (count < 25){return 5} // 30度以上１秒以内 25*40ms
            else {
                return 0
            }
        }
        return 0
    }

    var pitchDirection:Int = 0
    var rollDirection:Int = 0
    var yawDirection:Int = 0
    var lastPitch:Float = 0
    var lastPitchCount:Int = 0
    var lastRoll:Float = 0
    var lastRollCount:Int = 0
    var lastYaw:Float = 0
    var lastYawCount:Int = 0
   
    @IBAction func onResetButton(_ sender: Any) {
        pitchText2.text="0"
        rollText2.text="0"
        yawText2.text="0"
    }
    @IBOutlet weak var resetButton: UIButton!
    func checkRotation()
    {
        var tempDirection:Int=0
        let cnt=pitchA.count-1
        if(cnt<5){return}
        // pitch
        tempDirection = getDirection(a:pitchA[cnt-3],b:pitchA[cnt-2],c:pitchA[cnt-1],d:pitchA[cnt])
        if((tempDirection == -1 && pitchDirection == 1)||(tempDirection == 1 && pitchDirection == -1))//向きが代わった時
        {
            pitchDirection = tempDirection  //向きを新しくする
            if(checkOK(d0:lastPitch,d1:pitchA[cnt-3],limit:Float(pitchStepper.value), count: cnt-3 - lastPitchCount) == 5)
            {
                incPitchOK()
  //              print("o:",lastPitch-pitchA[cnt-3],cnt-3-lastPitchCount)
            }
            lastPitch = pitchA[cnt-3]
            lastPitchCount = cnt-3
        }
        if (tempDirection != 0){pitchDirection = tempDirection}

      // roll
        tempDirection = getDirection(a:rollA[cnt - 3],b:rollA[cnt - 2],c:rollA[cnt - 1],d:rollA[cnt])
        if ((tempDirection == -1 && rollDirection == 1)||(tempDirection == 1 && rollDirection == -1))
        {
            rollDirection = tempDirection
            if (checkOK(d0:lastRoll,d1:rollA[cnt - 3],limit:Float(rollStepper.value),count: cnt - 3 - lastRollCount) == 5)
            {
                incRollOK()
            }
            lastRoll = rollA[cnt-3]
            lastRollCount = cnt-3
        }
        if (tempDirection != 0){rollDirection = tempDirection}

      // yaw
        tempDirection = getDirection(a:yawA[cnt-3], b:yawA[cnt - 2], c:yawA[cnt - 1], d:yawA[cnt]);
        if ((tempDirection == -1 && yawDirection == 1)||(tempDirection == 1 && yawDirection == -1))
        {
            yawDirection = tempDirection
            if (checkOK(d0:lastYaw, d1:yawA[cnt-3],limit:Float(yawStepper.value),count: cnt-3 - lastYawCount) == 5)
            {
                incYawOK()
            }
            lastYaw = yawA[cnt-3]
            lastYawCount = cnt-3
        }
        if (tempDirection != 0){yawDirection = tempDirection}
   
    }
    func setMotion(){
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1/25//1 / 100//が最速の模様
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            let quat = motion.attitude.quaternion
            let b0 = UInt8((quat.z+1.0)*128)
            let b1 = UInt8((quat.y+1.0)*128)
            let b2 = UInt8((quat.x+1.0)*128)
            let b3 = UInt8((quat.w+1.0)*128)
            let dataStr=String(format: "Q:%03d%03d%03d%03d\n",b0,b1,b2,b3)
            let dataUTF8=dataStr.data(using: .utf8)
            QuaternionToEuler(q0: Float(quat.z), q1: Float(quat.y), q2: Float(quat.x), q3: Float(quat.w))
            checkRotation()
            if UDPf==true{
                send(dataUTF8!)
            }
        })
    }
}


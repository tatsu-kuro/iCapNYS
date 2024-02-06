//
//  BLEViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2023/06/25.
//

import UIKit
import CoreBluetooth
import CoreMotion
import Network
//import NetworkExtension

class BLEViewController: UIViewController, UITextFieldDelegate {

    let motionManager = CMMotionManager()
    var timer:Timer?
    var IPAddress:String?
   //MARK: - 変数
    //BDA4CF17-7815-4963-AAB1-B7F4B5783680
    //628965CD-EB5E-49EA-9A97-79FB62FA5139
    //DFDD9104-5C78-4E67-9379-D2F7908680D2

   // BLEで用いるサービス用のUUID
   let BLEServiceUUID = CBUUID(string:"BDA4CF17-7815-4963-AAB1-B7F4B5783680")
   // BLEで用いるキャラクタリスティック用のUUID
//   let BLEWriteCharacteristicUUID = CBUUID(string:"AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB")
  // let BLEWriteWithoutResponseCharacteristicUUID = CBUUID(string:"AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB")
   let BLEReadCharacteristicUUID = CBUUID(string:"628965CD-EB5E-49EA-9A97-79FB62FA5139")
   let BLENotifyCharacteristicUUID = CBUUID(string:"DFDD9104-5C78-4E67-9379-D2F7908680D2")
 //  let BLEIndicateCharacteristicUUID = CBUUID(string:"AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB")

   //BLEで用いるサービス
   var service:CBMutableService?
   //BLEで用いるキャラクタリスティック：今回は全ての種類のCharacteristicを付与する
   //write属性のCharacteristic
   var writeCharacteristic:CBMutableCharacteristic?
   //writewithoutResponse属性のCharacteristic
   var writeWithoutResponseCharacteristic:CBMutableCharacteristic?
   //read属性のCharacteristic
   var readCharacteristic:CBMutableCharacteristic?
   //notify属性のCharacteristic
   var notifyCharacteristic:CBMutableCharacteristic?
   //indicate属性のCharacteristic
   var indicateCharacteristic:CBMutableCharacteristic?

   // BLEのペリフェラルマネージャー、ペリフェラルとしての挙動を制御する
   private var peripheralManager : CBPeripheralManager?

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
    @IBAction func onExitButton(_ sender: Any) {
        if UDPf {
            disconnect(connection: connection!)
        }
        stopAdvertising()
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
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
  //      print("IPAddress:",IPAddress)
   //     connect(host: IPAddress!,port: "1108")
        connect(hostname: IPAddress!)
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
        IPAddress=myFunctions().getUserDefaultString(str: "IPAddress", ret: "192.168.1.1")
        let arr = IPAddress?.components(separatedBy: ".")
        ip1.text=arr?[0]
        ip2.text=arr?[1]
        ip3.text=arr?[2]
        ip4.text=arr?[3]
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        let top=CGFloat(UserDefaults.standard.float(forKey: "topPadding"))
        let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottomPadding"))
        let left=CGFloat(UserDefaults.standard.float(forKey: "leftPadding"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "rightPadding"))
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)
        let sp=ww/120//間隙
        var bw=(ww-sp*10)/7//ボタン幅
        var bh=bw*170/440
        let by=wh-bh-sp
        bw=(ww-sp*11)/8
        myFunctions().setButtonProperty(exitButton,x:left+bw*7+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        logTextView.frame=CGRect(x:left+sp,y:top+bh*2+3*sp,width: ww-2*sp,height: by-3*sp-top-2*bh)
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

          //①BLEのペリフェラルを使用開始できる状態にセットアップ
        //インスタンス化
        self.peripheralManager = CBPeripheralManager(delegate:self, queue:nil)

        startAdvertising()
        setMotion()
//      if (@available(iOS 13.0, *)) {
//            textView.font = [UIFont monospacedSystemFontOfSize: 13 weight: UIFontWeightRegular];
//        } else {
//        logTextView.font = UIFont.monospacedDigitSystemFont(ofSize:13,weight:.regular)
//        logTextView.font = UIFont.monospacedDigitSystemFont(ofSize: view.bounds.width/60, weight: .medium)
        UIApplication.shared.isIdleTimerDisabled = true//スリープさせない
        timer = Timer.scheduledTimer(timeInterval: 5*60, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)

        logTextView.text="b0=UInt8((motion.attitude.quaternion.x+1)*128)\n"
        logTextView.text.append("b1=UInt8((motion.attitude.quaternion.y+1)*128)\n")
        logTextView.text.append("b2=UInt8((motion.attitude.quaternion.z+1)*128)\n")
        logTextView.text.append("b3=UInt8((motion.attitude.quaternion.w+1)*128)\n")
        logTextView.text.append("notifyData = String(format: \"Q:%03d%03d%03d%03d\\n\",b0,b1,b2,b3)\n")
 //       logTextView.text.append("notifyData = Data( [b0,b1,b2,b3])\n")
        logTextView.text.append("sending the notifyData on BLE\n")
        logTextView.text.append("ServiceUUID             :BDA4CF17-7815-4963-AAB1-B7F4B5783680\n")
        logTextView.text.append("ReadCharacteristicUUID  :628965CD-EB5E-49EA-9A97-79FB62FA5139\n")
        logTextView.text.append("NotifyCharacteristicUUID:DFDD9104-5C78-4E67-9379-D2F7908680D2\n")
   
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
    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ [self] sendError in
            if let error = sendError {
                print("Unable to process and send the data: \(error)")
            } else {
                print("Data has been sent")
//                connection!.receiveMessage { (data, context, isComplete, error) in
//                    guard let myData = data else { return }
//                    print("Received message: " + String(decoding: myData, as: UTF8.self))
//                }
            }
        }))
    }
    
    func connect(hostname:String) {
  //      var host:NWEndpoint.Host = "192.168.0.209"//hostname
        var host:NWEndpoint.Host = NWEndpoint.Host(hostname)
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
 
    
    //uuidgen 2024/2/4
    //BDA4CF17-7815-4963-AAB1-B7F4B5783680
    //628965CD-EB5E-49EA-9A97-79FB62FA5139
    //DFDD9104-5C78-4E67-9379-D2F7908680D2
    @objc func update(tm: Timer) {
        UIApplication.shared.isIdleTimerDisabled = false//スリープさせる
        print("isIdle false")
    }
    // アドバタイズを停止
    func stopAdvertising()
    {
        self.peripheralManager?.stopAdvertising()
        logTextView.text.append("Advertisingを停止しました\n")
        motionManager.stopDeviceMotionUpdates()
    }
  
    func setMotion(){
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1/30//1 / 100//が最速の模様
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            let quat = motion.attitude.quaternion
            //            let b0 = UInt8((quat.w+1.0)*128)
            //            let b1 = UInt8((-quat.y+1.0)*128)
            //            let b2 = UInt8((-quat.z+1.0)*128)
            //            let b3 = UInt8((quat.x+1.0)*128)
            let b0 = UInt8((quat.z+1.0)*128)
            let b1 = UInt8((quat.y+1.0)*128)
            let b2 = UInt8((quat.x+1.0)*128)
            let b3 = UInt8((quat.w+1.0)*128)
            let dataStr=String(format: "Q:%03d%03d%03d%03d\n",b0,b1,b2,b3)
            let dataUTF8=dataStr.data(using: .utf8)
            if UDPf==true{
                print(dataUTF8!)
                send(dataUTF8!)
            }
           // let notifyData = Data( [b0,b1,b2,b3])
            if notifyCharacteristic == nil{
                return
            }
            self.peripheralManager?.updateValue(dataUTF8!, for: notifyCharacteristic!, onSubscribedCentrals: nil)
        })
    }
    //③PeripheralにService及びCharacteristicを追加する
    func addService(){
        //サービスの設定
        service = CBMutableService(type: BLEServiceUUID, primary: true)

        //キャラクタリスティックの設定(properties:属性、permissions：読み出し書込みの可否を与える)
//        writeCharacteristic = CBMutableCharacteristic(type: BLEWriteCharacteristicUUID, properties: .write, value: nil, permissions: [.writeable,.readable])
//
//        writeWithoutResponseCharacteristic = CBMutableCharacteristic(type: BLEWriteCharacteristicUUID, properties: .writeWithoutResponse, value: nil, permissions: .writeable)
        
        //readCharacteristicは読み出した時の初期値を与えておく
        let readData = Data( [0x55])
        readCharacteristic = CBMutableCharacteristic(type: BLEReadCharacteristicUUID, properties: .read, value: readData, permissions: .readable)

        notifyCharacteristic = CBMutableCharacteristic(type: BLENotifyCharacteristicUUID, properties: .notify, value: nil, permissions: .readable)

        
//        indicateCharacteristic = CBMutableCharacteristic(type: BLEIndicateCharacteristicUUID, properties: .indicate, value: nil, permissions: .readable)

        //サービスにキャラクタリスティックの設定
        service?.characteristics = [/*writeCharacteristic!,writeWithoutResponseCharacteristic!,*/readCharacteristic!,notifyCharacteristic!]//,indicateCharacteristic!]
        //ペリフェラルにサービスを追加
        peripheralManager?.add(service!)
    }
    func startAdvertising()
    {
        //アドバタイズに乗せるService
        let serviceUUIDs = [BLEServiceUUID]
        //アドバタイズデータのセット（LocalName:BLEの設定画面で表示される名称）
        let advertisementData:[String:Any] = [CBAdvertisementDataLocalNameKey: "BLE_iCapNYS"
                                 ,CBAdvertisementDataServiceUUIDsKey:serviceUUIDs]
        //アドバタイズ開始
        self.peripheralManager?.startAdvertising(advertisementData)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension BLEViewController : CBPeripheralManagerDelegate
{
    //Notify or Indicateの許可が行われた（ディスクリプタへの書き込み）時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeToCharacteristic")//!!!!!!!!!!!!!!*******
        logTextView.text.append("didSubscribeToCharacteristic\n")
        if(characteristic.uuid == BLENotifyCharacteristicUUID){
//            notifyButton.isEnabled = true
 //           setMotion()
//            notify()
//        }else if (characteristic.uuid == BLEIndicateCharacteristicUUID){
    //        indicateButton.isEnabled = true
        }
        
    }
    
    //Notify or Indicateの禁止が行われた（ディスクリプタへの書き込み）時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
//        print("didUnsubscribeFromCharacteristic")//!!!!!!********
        logTextView.text.append("didUnsubscribeFromCharacteristic\n")
        if(characteristic.uuid == BLENotifyCharacteristicUUID){
       //     notifyButton.isEnabled = false
//        }else if (characteristic.uuid == BLEIndicateCharacteristicUUID){
         //   indicateButton.isEnabled = false
        }
    }

    //読み出し要求が行われた時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
//        print("didReceiveReadRequest")
        logTextView.text.append("didReceiveReadRequest\n")

        //読み出し許可の与えているキャラクタリスティックか確認
        if request.characteristic.uuid.isEqual(readCharacteristic?.uuid){
            //valueをセット
            request.value = self.readCharacteristic?.value
            //読み出し要求に応える
            peripheralManager?.respond(to: request, withResult: .success)
        }else{
            //許可されていない読み出しとして応える
            peripheralManager?.respond(to: request, withResult: .readNotPermitted)
        }
    }
    
    //書き込み要求が行われた時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

        logTextView.text.append("didReceiveWriteRequest\n")
        for request in requests {
            if request.characteristic.uuid.isEqual(writeCharacteristic?.uuid) {
                //valueをセット
                writeCharacteristic!.value = request.value
                //リクエストに応答
                peripheralManager?.respond(to: requests[0], withResult: .success)
            }else if request.characteristic.uuid.isEqual(writeWithoutResponseCharacteristic?.uuid){
                //何もしない
            }
        }
    }

    //アドバタイズを開始した時に呼ばれるDelegate//!!!!!!!!!!!***********
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("アドバタイズ開始")
        if error == nil {
 //           logTextView.text.append("PeripheralがAdvertisingを開始しました\n")
//            startAdvertiseButton.isEnabled = false
//            stopAdvertiseButton.isEnabled = true
        } else {
   //         logTextView.text.append("PeripheralがAdvertisingの開始に失敗しました\(error?.localizedDescription)\n")
        }
    }
    
    //②Peripheralの状態が変化すると呼ばれるDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        //PeripheralManagerのインスタンス化を実施するとすぐにPowerOnが呼ばれる。
        logTextView.text.append(/*"PeripheralのStateが変更されました。\n*/"CurrentState:\(peripheral.state.name)\n")

 
        if peripheral.state != .poweredOn {
   //         print("BlueTooth off")
   //         logTextView.text.append("異常なStateのため処理を終了します\n")
            return;
        }
        //③PeripheralにService及びCharacteristicを追加する
        addService()
    }

    //updateValueのキューがいっぱいの時に値を送信しようとすると呼ばれるDelegate
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        //この中で再送処理を入れるとよい
    }
    
    //PeripheralにServiceを追加した時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil {
      //     logTextView.text.append("サービスが正常に追加されました\n")//!!!!!!!***********
        } else {
       //     logTextView.text.append("サービスの追加に失敗しました\(error?.localizedDescription)\n")
        }
    }
}
//以下はCBManagerSteteに名称を付けているだけ
extension CBManagerState
{
    var name : String {
        get{
            let enumName = "CBManagerState"
            var valueName = ""

            switch self {
            case .poweredOff:
                valueName = enumName + "PoweredOff"
            case .poweredOn:
                valueName = enumName + "PoweredOn"
            case .resetting:
                valueName = enumName + "Resetting"
            case .unauthorized:
                valueName = enumName + "Unauthorized"
            case .unknown:
                valueName = enumName + "Unknown"
            case .unsupported:
                valueName = enumName + "Unsupported"
            @unknown default:
                valueName = enumName + "Unknown"
            }

            return valueName
        }
    }
}


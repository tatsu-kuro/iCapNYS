//
//  BLEViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2023/06/25.
//

import UIKit
import CoreBluetooth
import CoreMotion
class BLEViewController: UIViewController {

    let motionManager = CMMotionManager()
    var timer:Timer?
   //MARK: - 変数
   // BLEで用いるサービス用のUUID
   let BLEServiceUUID = CBUUID(string:"19501103-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
   // BLEで用いるキャラクタリスティック用のUUID
//   let BLEWriteCharacteristicUUID = CBUUID(string:"AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB")
  // let BLEWriteWithoutResponseCharacteristicUUID = CBUUID(string:"AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB")
   let BLEReadCharacteristicUUID = CBUUID(string:"19501108-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
   let BLENotifyCharacteristicUUID = CBUUID(string:"19501122-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
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

    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var exitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "brightness")
        let top=CGFloat(UserDefaults.standard.float(forKey: "topPadding"))
        let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottomPadding"))
        let left=CGFloat(UserDefaults.standard.float(forKey: "leftPadding"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "rightPadding"))
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        // Do any additional setup after loading the view.
        myFunctions().setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        logTextView.frame=CGRect(x:left+sp,y:top+sp,width: ww-2*sp,height: by-sp-top)
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
        logTextView.text.append("notifyData = Data( [b0,b1,b2,b3])\n")
        logTextView.text.append("sending the noyifyData on BLE\n")
        logTextView.text.append("ServiceUUID             :19501103-AAAA-AAAA-AAAA-AAAAAAAAAAAA\n")
        logTextView.text.append("ReadCharacteristicUUID  :19501108-AAAA-AAAA-AAAA-AAAAAAAAAAAA\n")
        logTextView.text.append("NotifyCharacteristicUUID:19501122-AAAA-AAAA-AAAA-AAAAAAAAAAAA\n")
    }
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
            let b0 = UInt8((quat.w+1.0)*128)
            let b1 = UInt8((quat.y+1.0)*128)
            let b2 = UInt8((quat.z+1.0)*128)
            let b3 = UInt8((quat.x+1.0)*128)

            let notifyData = Data( [b0,b1,b2,b3])
            if notifyCharacteristic == nil{
                return
            }
            self.peripheralManager?.updateValue(notifyData, for: notifyCharacteristic!, onSubscribedCentrals: nil)
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


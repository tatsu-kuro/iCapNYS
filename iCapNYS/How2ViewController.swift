//
//  How2ViewController.swift
//  iCapNYS
//
//  Created by 黒田建彰 on 2020/12/07.
//

import UIKit
extension UIImage {

    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

class How2ViewController: UIViewController {
    let someFunctions = myFunctions()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var imageViewOnScrollView: UIImageView!
    @IBOutlet weak var textViewOnScrollView: UITextView!
    
    /*override func viewDidLoad() {
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
        // 画面サイズ取得
        scrollView.frame = CGRect(x:left,y:top,width: ww,height: wh)
        someFunctions.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        var img = UIImage(named:"how2Eng")!
        if someFunctions.firstLang().contains("ja"){
            img = UIImage(named: "how2")!
        }
        // 画像のサイズ
        let imgW = img.size.width
        let imgH = img.size.height
        let image = img.resize(size: CGSize(width:ww, height:ww*imgH/imgW))
        // UIImageView 初期化
        let imageView = UIImageView(image: image)//jellyfish)
        // UIScrollViewに追加
        scrollView.addSubview(imageView)
        // UIScrollViewの大きさを画像サイズに設定
        scrollView.contentSize = CGSize(width: ww, height: ww*imgH/imgW)
        // スクロールの跳ね返り無し
        scrollView.bounces = true
    }*/
    @IBAction func onExitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        // 画面サイズ取得
        scrollView.frame = CGRect(x:left,y:top,width: ww,height: wh)
        someFunctions.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        let img = UIImage(named:"sougu")!
        // 画像のサイズ
        let imgW = img.size.width
        let imgH = img.size.height
        let imageHeight=ww*imgH/imgW
        let image = img.resize(size: CGSize(width:ww, height:imageHeight))
        imageViewOnScrollView.frame=CGRect(x:0,y:sp,width:ww,height: imageHeight)
        imageViewOnScrollView.image=image
        var textHeight=wh*4
        if someFunctions.firstLang().contains("ja"){
            addTextJa()
  //          textHeight=wh*2.6
        }else{
            addTextEn()
            textHeight=wh*5
         }
        textViewOnScrollView.frame=CGRect(x:0,y:imageHeight+2*sp,width: ww,height:textHeight)
        scrollView.contentSize = CGSize(width: ww, height: imageHeight+textHeight+2*sp)
        // スクロールの跳ね返り無し
        scrollView.bounces = true
  //      scrollView.bringSubviewToFront(textViewOnScrollView)
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    func addTextEn(){
        textViewOnScrollView.text="1: A device is necessary to secure the iPhone in front of the eyes for capturing nystagmus.\n"
        textViewOnScrollView.text.append("When using the back camera, you can use a transparent plastic case like the one shown in the top-left photo. The iPhone is fixed to the case with double-sided adhesive gel tape.\nFor the front camera, it is possible to manually secure it once you get used to it, but creating a simple fixture like the one shown in the top-right photo results in less shaky nystagmus footage.\n\n")
        textViewOnScrollView.text.append("2: Camera setting\n")
        textViewOnScrollView.text.append("Tap the second green button from the bottom on the right side of the Camera settings screen to select the camera to use, and set parameters such as zoom and exposure.\nIf the front camera is selected, further choose between manual, automatic 20 seconds, and 90 seconds. In the automatic mode, a video explaining the method of capturing nystagmus will play, allowing you to record while watching.\nThe default recording settings are front camera, manual, and preview: OFF.\nYou can also choose Unimec's WiFi camera, but when using it, you need to set your iPhone's WiFi to Unimec's SSID.\n\n(*)On the WiFi camera settings screen, there is a [Send Motion Data] button at the bottom left, which, when tapped, can send iPhone's GyroData via WiFi and Bluetooth. This feature is intended for the CapNYS app for Windows.\n\n")
        textViewOnScrollView.text.append("3: Nystagmus Recording\n")
        textViewOnScrollView.text.append("Recording is simple, following these 3 steps:\n* Tap the green camera button in the middle-right of the main screen.\n* Tap the start recording button in the center.\n* Tap the stop recording button in the center (thin and barely visible, located in the central area).\n\n")
        textViewOnScrollView.text.append("4: Playback of Recorded Videos\n")
        textViewOnScrollView.text.append("After recording is complete, return to the main screen, and the recorded video will be displayed at the top of the list. Videos are listed by recording date and time (duration). Tapping an item allows you to play it. Swiping left on an item allows you to delete it. You can also view the videos from the iPhone's Photos app, enabling management functions such as playback, deletion, and sharing. Nystagmus videos are stored in the iCapNYS album.")
    }
    func addTextJa(){
        textViewOnScrollView.text="1: 眼振を撮影するためのiPhoneを眼前に固定する装具が必要です。\n"
        textViewOnScrollView.text.append("バックカメラを利用するときは左上写真のような透明のプラスチックケースが使えます。両面粘着ゲルテープでiPhoneをケースに固定しています。フロントカメラの場合は、慣れれば手で固定することも可能ですが、右上写真のような固定具を厚紙で自作するとブレの少ない眼振が撮れます。\n\n")
        textViewOnScrollView.text.append("2: 録画設定\n")
        textViewOnScrollView.text.append("録画設定画面の右下の緑色ボタンで使用するカメラを選択し、ズーム、露出などを設定します。\nフロントカメラを選択した場合は、さらに手動、自動20秒、自動90秒のいずれかを選択します。自動では撮影方法の説明映像が流れ、それを見ながら録画できます。\n録画設定のデフォルトではフロントカメラ、手動、プレビュー：OFFが選択されています。\nUnimec社のWiFiカメラも選択できます。その場合は、iPhoneのWiFiをUnimec社のSSIDに設定する必要があります。\n\n")
        textViewOnScrollView.text.append("3: 眼振録画\n")
        textViewOnScrollView.text.append("撮影は簡単で、以下3ステップです。\n＊トップ画面の中央右の緑色のカメラボタンをタップ\n＊中央の録画スタートボタンをタップ\n＊中央の録画ストップボタン（色を薄くしており、見えにくいです。）\n\n")
        textViewOnScrollView.text.append("4: 撮影動画再生\n")
        textViewOnScrollView.text.append("録画終了するとトップ画面に戻り、録画された動画はリストの1番上に表示されます。動画は撮影日時（長さ）で一覧表示されます。項目をタップすると再生出来ます。項目を左にスワイプスすると削除できます。iPhoneの写真アプリからも見れますので、写真アプリでも再生、削除、送信などの管理ができます。眼振動画はiCapNYSアルバムの中に入っています。\n\n")
        textViewOnScrollView.text.append("5: Gyroボタン\n")
        textViewOnScrollView.text.append("Gyroボタンをタップすると、iPhoneのpitch, roll, yawの動きをチェックしてアラームを鳴らし、回数を表示します。前庭リハビリのための機能です。\nまた、WindowsアプリCapNYSが指定するIP-Address、Portを設定すると、GyroDataをWiFiでそのCapNYSに送信できます。Windows用CapNYSはkuroda33.com/jibikaからダウンロードできます。\n")
    }
}

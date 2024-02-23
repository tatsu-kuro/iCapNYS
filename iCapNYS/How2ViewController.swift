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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    /*
     1: A device is necessary to secure the iPhone in front of the eyes for capturing nystagmus.

     When using the back camera, you can use a transparent plastic case like the one shown in the top-left photo. The iPhone is fixed to the case with adhesive tape.

     For the front camera, it is possible to manually secure it once you get used to it, but creating a simple fixture like the one shown in the top-right photo results in less shaky nystagmus footage.

     2: Preparation

     Start by configuring the recording settings. Choose the camera to be used and set parameters such as zoom and exposure.

     If the front camera is selected, further choose between manual, automatic 20 seconds, and 90 seconds. In the automatic mode, a video explaining the method of capturing nystagmus will play, allowing you to record while watching.

     The default recording settings are front camera, manual, and preview: OFF.

     You can also choose Unimec's WiFi camera, but when using it, you need to set your iPhone's WiFi to Unimec's URL.

     On the WiFi camera settings screen, there is a [Send Motion Data] button at the bottom left, which, when tapped, can send iPhone's GyroData via WiFi and Bluetooth. This feature is intended for the CapNYS app for Windows.

     3: Nystagmus Recording

     Recording is simple, following these 3 steps:

     ⚫️ Tap the green camera button in the middle-right of the main screen.

     ⚫️ Tap the start recording button in the center.

     ⚫️ Tap the stop recording button in the center (thin and barely visible, located in the central area).

     4: Playback of Recorded Videos

     After recording is complete, return to the main screen, and the recorded video will be displayed at the top of the list. Videos are listed by recording date and time (duration). Tapping an item allows you to play it. Swiping left on an item allows you to delete it. You can also view the videos from the iPhone's Photos app, enabling management functions such as playback, deletion, and sharing. Nystagmus videos are stored in the iCapNYS album.
     */
    /*
     1：眼振を撮影するためにiPhoneを眼前に固定する装具が必要です。
     バックカメラを利用するときは左上写真のような透明のプラスチックケースが使えます。粘着テープでiPhoneをケースに固定しています。
     フロントカメラの場合は慣れれば手で固定することも可能ですが、右上写真のような簡単な固定具を自作するとブレの少ない眼振が撮れます。
     2：準備
     最初に録画設定を行います。使用するカメラを選択し、ズーム、露出などを設定します。
     フロントカメラを選択した場合は、さらに手動、自動20秒、90秒を選択します。自動では眼振撮影の方法の説明の映像が流れ、それを見ながら録画できます。
     デフォルトの録画設定ではフロントカメラ、手動、プレビュー：OFFが選択されています。
     Unimec社のWiFiカメラも選択できますが、WiFiカメラを利用する場合は、iPhoneのWiFiをUnimec社のURLに設定する必要があります。
     WiFiカメラ設定画面では左下に[Send Motion  Data]ボタンが表示され、それをタップするとiPhoneのGyroDataをWiFiおよびBluetoothで送信できます。この機能はWindows用のCapNYSアプリのためのものです。
     3：眼振撮影：
     撮影は簡単で、以下3ステップです。
     ⚫️トップ画面の中央右の緑色のカメラボタンをタップ
     ⚫️中央の録画スタートボタンをタップ
     ⚫️中央の録画ストップボタン（薄くてほとんど見得ませんが、中央部分にあります。）
     4：撮影動画再生：
     録画終了するとトップ画面に戻り、録画された動画はリストの1番上に表示されます。動画は撮影日時（長さ）で一覧表示されます。項目をタップすると再生出来ます。項目を左にスワイプスすると削除できます。iPhoneの写真アプリからも見れますので、写真アプリで再生、削除、送信などの管理ができます。眼振動画はiCapNYSアルバムの中に入っています。
     */
}

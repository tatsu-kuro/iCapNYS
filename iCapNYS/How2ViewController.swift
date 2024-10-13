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
        /*
         1: A device is needed to securely hold an iPhone in front of the eyes for capturing eye movements. When using the back camera, a transparent plastic case like the one in the top left photo can be utilized. The iPhone is secured to the case with double-sided adhesive gel tape. For the front camera, it’s possible to hold the iPhone by hand once you get used to it, but creating a fixture out of thick cardboard like the one in the top right photo will allow for less shaky eye movement recordings.
         2: Eye Movement Recording Select the camera you want to use with the green button in the bottom right, and adjust settings like zoom and exposure. An explanatory video will play if you choose “with Video Auto90s”,  showing how to record, allowing you to follow along. You can also choose the Unimec WiFi camera; in that case, you will need to set your iPhone's WiFi to the Unimec SSID. During recording, a large stop button (which is faint and hard to see) appears in the center of the screen, and tapping it will stop the recording.
         3: Eye Movement Playback You can play back the most recently recorded eye movement video by tapping the thumbnail in the top right. Use the button in the bottom right to navigate to the video list screen. The videos are displayed in a list sorted by recording date and duration. Tapping an item will play the video. You can delete an item by swiping left on it. The eye movement videos are stored in the iCapNYS album, so you can manage playback, deletion, and sharing through the Photos app as well. You can send the currently playing video via email from the playback screen.
         4: Gyro Button (List View Screen) The Gyro button on the list view screen takes you to the Gyro screen. Here, you can check the iPhone's pitch, roll, and yaw movements, trigger alarms, and display the count. This feature is intended for vestibular rehabilitation. Additionally, if you set the IP address and port specified by the Windows application CapNYS, you can send Gyro data to that CapNYS via WiFi. The Windows version of CapNYS can be downloaded from https://kuroda33.com/jibika.


         */
        textViewOnScrollView.text="1: A device is necessary to secure the iPhone in front of the eyes for capturing nystagmus.\n"
        textViewOnScrollView.text.append("A device is needed to securely hold an iPhone in front of the eyes for capturing eye movements. When using the back camera, a transparent plastic case like the one in the top left photo can be utilized. The iPhone is secured to the case with double-sided adhesive gel tape. For the front camera, it’s possible to hold the iPhone by hand once you get used to it, but creating a fixture out of thick cardboard like the one in the top right photo will allow for less shaky eye movement recordings.\n\n")
        textViewOnScrollView.text.append("2: Eye movement recording\n")
        textViewOnScrollView.text.append("Select the camera you want to use with the green button in the bottom right, and adjust settings like zoom and exposure. An explanatory video will play if you choose “with Video Auto90s”,  showing how to record, allowing you to follow along. You can also choose the Unimec WiFi camera; in that case, you will need to set your iPhone's WiFi to the Unimec SSID. During recording, a large stop button (which is faint and hard to see) appears in the center of the screen, and tapping it will stop the recording.\n\n")
        textViewOnScrollView.text.append("3: Eye movement playback\n")
        textViewOnScrollView.text.append("You can play back the most recently recorded eye movement video by tapping the thumbnail in the top right. Use the button in the bottom right to navigate to the video list screen. The videos are displayed in a list sorted by recording date and duration. Tapping an item will play the video. You can delete an item by swiping left on it. The eye movement videos are stored in the iCapNYS album, so you can manage playback, deletion, and sharing through the Photos app as well. You can send the currently playing video via email from the playback screen.\n\n")
        textViewOnScrollView.text.append("4: Gyro Button (List View Screen)\n")
        textViewOnScrollView.text.append("The Gyro button on the list view screen takes you to the Gyro screen. Here, you can check the iPhone's pitch, roll, and yaw movements, trigger alarms, and display the count. This feature is intended for vestibular rehabilitation. Additionally, if you set the IP address and port specified by the Windows application CapNYS, you can send Gyro data to that CapNYS via WiFi. The Windows version of CapNYS can be downloaded from https://kuroda33.com/jibika.\n\n")
    }
    func addTextJa(){
        textViewOnScrollView.text="1: 眼振を撮影するためのiPhoneを眼前に固定する装具が必要です。\n"
        textViewOnScrollView.text.append("バックカメラを利用するときは左上写真のような透明のプラスチックケースが使えます。両面粘着ゲルテープでiPhoneをケースに固定しています。フロントカメラの場合は、慣れれば手で固定することも可能ですが、右上写真のような固定具を厚紙で自作するとブレの少ない眼振が撮れます。\n\n")
        textViewOnScrollView.text.append("2: 眼振録画\n")
        textViewOnScrollView.text.append("右下の緑色ボタンで使用するカメラを選択し、ズーム、露出などを設定します。解説動画付自動90秒では撮影方法の説明映像が流れ、説明を聞きながら録画できます。録画中は画面中央に大きな半透明の薄い色のストップボタンがあり、それをタップすると録画終了します。Unimec社のWiFiカメラも選択できます。その場合は、iPhoneのWiFiをUnimec社のSSIDに設定する必要があります。\n\n")
        textViewOnScrollView.text.append("3: 眼振再生\n")
        textViewOnScrollView.text.append("最後に撮影した眼振動画は右上のサムネイルをタップすると再生出来ます。\n右下のボタンで動画一覧画面に移動します。動画は撮影日時（長さ）で一覧表示されます。項目をタップすると再生出来ます。項目を左にスワイプスすると削除できます。眼振動画はiCapNYSアルバムの中に入っていますので、写真アプリでも再生、削除、送信などの管理ができます。\n再生画面から再生中の動画をメールで送信できます。\n\n")
        textViewOnScrollView.text.append("4: Gyroボタン（一覧表示画面）\n")
        textViewOnScrollView.text.append("一覧表示画面にあるGyroボタンでGyro画面に移動します。iPhoneのpitch, roll, yawの動きをチェックしてアラームを鳴らし、回数を表示します。前庭リハビリのための機能です。\nまた、WindowsアプリCapNYSが指定するIP-Address、Portを設定すると、GyroDataをWiFiでそのCapNYSに送信できます。Windows用CapNYSはkuroda33.com/jibikaからダウンロードできます。\n\n")
    }
}

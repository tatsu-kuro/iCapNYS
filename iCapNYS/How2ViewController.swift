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
    
    @IBOutlet weak var imageViewOnScrollView: UIImageView!
    @IBOutlet weak var textViewOnScrollView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var gyroButtonOnScrollView: UIButton!
    @IBAction func onGyroButton(_ sender: Any) {
        print("gyroOn")
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
        var img = UIImage(named:"how2Eng")!
        if someFunctions.firstLang().contains("ja"){
            img = UIImage(named: "how2")!
        }
        // 画像のサイズ
        let imgW = img.size.width
        let imgH = img.size.height
        let image = img.resize(size: CGSize(width:ww, height:ww*imgH/imgW))
        // UIImageView 初期化
  //      let imageView = UIImageView(image: image)//jellyfish)
        // UIScrollViewに追加
       // scrollView.addSubview(imageView)
        // UIScrollViewの大きさを画像サイズに設定
        imageViewOnScrollView.frame=CGRect(x:0,y:0,width:ww,height: ww)
        imageViewOnScrollView.image=image
        scrollView.contentSize = CGSize(width: ww, height: ww*imgH/imgW)
        // スクロールの跳ね返り無し
        scrollView.bounces = true
        scrollView.bringSubviewToFront(gyroButtonOnScrollView)
        gyroButtonOnScrollView.frame=CGRect(x:sp,y:ww*imgH/imgW-bh-sp,width:bw,height: bh)
        gyroButtonOnScrollView.layer.borderWidth = 1.0
        gyroButtonOnScrollView.layer.cornerRadius = 5
        textViewOnScrollView.frame=CGRect(x:0,y:500,width: ww,height: ww)
        scrollView.bringSubviewToFront(textViewOnScrollView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}

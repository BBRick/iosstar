//
//  UIImage+Extension.swift
//  wp
//
//  Created by 木柳 on 2016/12/21.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import Foundation
//import Qiniu


extension UIImage{

    
    
    class func imageFromUIView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage!
    }
    
    
    //根据字符串生成二维码
    class func qrcodeImage(_ qrcodeStr: String) -> UIImage?{
        
        //        1.创建一个滤镜
        let filter = CIFilter(name:"CIQRCodeGenerator")
        //        2.将滤镜恢复到默认状态
        filter?.setDefaults()
        //        3.为滤镜添加属性    （"函冰"即为二维码扫描出来的内容，可以根据需求进行添加）
        filter?.setValue(qrcodeStr.data(using: String.Encoding.utf8), forKey: "InputMessage")
        //        判断是否有图片
        guard let ciimage = filter?.outputImage else {
            return nil
        }
        //        4。将二维码赋给imageview,此时调用网上找的代码片段，由于SWift3的变化，将其稍微改动，生成清晰的二维码
        return createNonInterpolatedUIImageFormCIImage(image: ciimage, size: 200)
    }
    
    /**
     生成高清二维码
     
     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private class func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // 1.创建bitmap;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale);
        //        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        bitmapRef.draw(bitmapImage, in: extent)
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }
    
    class func imageWith(_ iconName: String, fontSize: CGSize, fontColor:UIColor?) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(fontSize, false, UIScreen.main.scale)
        let label = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: fontSize))
        label.font = UIFont.init(name: "iconfont", size:fontSize.height)
        label.text = iconName
        if fontColor != nil{
            label.textColor = fontColor
        }
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
     func barrageImageScaleToSize(_ size: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size);
        // 绘制改变大小的图片
        self.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
//        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        // 从当前context中创建一个改变大小后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        // 返回新的改变大小后的图片
        return scaledImage!;
    }
   

}

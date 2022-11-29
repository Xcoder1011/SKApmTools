//
//  UIImageView+HookLoad.swift
//  SKApmTools
//
//  Created by KUN on 2022/11/28.
//

import Foundation
import UIKit
import Kingfisher

private var sk_urlKey: Void?

extension UIImageView {
    
    /// runtime 记录url信息
    private var sk_url: NSURL? {
        get { return sk_getAssociatedObject(self, &sk_urlKey) }
        set { sk_setRetainedAssociatedObject(self, &sk_urlKey, newValue)}
    }
    
    /// hook
    @objc public class func initializeOnceSwift() {
        let token = "UIImageView+HookLoad"
        DispatchQueue.sk_once(token) {
            let originSelector = #selector(setter: UIImageView.image)
            let swizzledSelector = #selector(self.swizzle_setImage(_:))
            sk_swizzleMethod(self, originSelector, swizzledSelector)
            
            let originSelector2 = #selector(setter: UIImageView.frame)
            let swizzledSelector2 = #selector(self.swizzle_setFrame(_:))
            sk_swizzleMethod(self, originSelector2, swizzledSelector2)
        }
    }
    
    /// 这里写一个公共的加载图片的方法，用于获取图片url相关信息，只是为了演示...
    /// 真正不同的项目，可以通过hook每个项目中封装好的加载图片的方法，获取图片url相关信息
    ///
    @objc public func loadImage(with url: NSURL?) {
        if let url = url {
            sk_url = url
            if url.isFileURL {
                self.image = UIImage(data: try! Data(contentsOf: url as URL))
            } else {
                // 这里用了Kingfisher也是为了演示网络图片
                KF.url(url as URL).set(to: self)
            }
        }
    }
    
    @objc dynamic func swizzle_setFrame(_ frame: CGRect) {
        self.swizzle_setFrame(frame)
        checkSize()
    }
    
    @objc dynamic func swizzle_setImage(_ image: UIImage?) {
        self.swizzle_setImage(image)
        checkSize()
    }
    
    private func checkSize() {
        guard self.frame.size.height > 0 else { return }
        guard let image = self.image , let cgimage = image.cgImage else { return }
        
        /// 1. 检查宽高比差异
        let viewRatio = self.frame.size.width / self.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let delta = fabs(viewRatio - imageRatio)
        if delta > 0.1 {
            print("-----⚠️⚠️⚠️ warnin: ----- 图片容器的宽高的比和实际图片的宽高比差异超过0.1, \(debugUrlInfo)")
        }
        
        /// 2. 检查图片大小和UI大小
        if image.size.height / self.frame.size.height >= 2 && image.size.width / self.frame.size.width >= 2 {
            print("-----⚠️⚠️⚠️ warnin: ----- 图片的大小是实际显示UI大小的2倍或以上,\(debugUrlInfo)")
        }
        
        /// 3. 检查图片size
        /// 这里判断图片在内存中的大小阈值 还是 判断 图片原始 尺寸大小，都能通过url信息拿到原始尺寸大小
        /// 比如本地图片可以通过FileManager.default.attributesOfItem(atPath:)获取size信息
        ///
        let size = cgimage.bytesPerRow * cgimage.height / 1000
        if size > 1024 * 2 {
            print("-----⚠️⚠️⚠️ warnin: ----- >>>> image memory size = \(size)kb, \(debugUrlInfo)")
        }
        
        if let data = UIImagePNGRepresentation(image) {
            let kBytes = data.count / 1000
            if kBytes > 512 {
                print("-----⚠️⚠️⚠️ warnin: ----- 尺寸大于512kb，\(debugUrlInfo)")
            }
        }
        
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            let kBytes = data.count / 1000
            if kBytes > 512 {
                print("-----⚠️⚠️⚠️ warnin: ----- 尺寸大于512kb，\(debugUrlInfo)")
            }
        }
    }
    
    var debugUrlInfo: String {
        get {
            if let url = sk_url {
                if url.isFileURL {
                    return "图片文件名：\(url.path ?? "")"
                } else {
                    return "图片链接：\(url.absoluteString ?? "")"
                }
            }
            return String(describing: self)
        }
    }
}

// MARK: runtime associated
func sk_getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

func sk_setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

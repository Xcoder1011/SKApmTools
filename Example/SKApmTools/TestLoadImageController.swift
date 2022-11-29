//
//  TestLoadImageController.swift
//  SKApmTools_Example
//
//  Created by KUN on 2022/11/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class TestLoadImageController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // l. local url
        
        if let path = Bundle.main.path(forResource: "test_nav", ofType: "jpg") {
            let imageView1 = UIImageView(frame: CGRectMake(20, 100, 300, 60))
            let fileURL = NSURL(fileURLWithPath: path)
            imageView1.loadImage(with: fileURL)
            view.addSubview(imageView1)
        }

        if let path = Bundle.main.path(forResource: "test_bg", ofType: "jpg") {
            let image = UIImage(contentsOfFile: path)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(20, 200, 200, 200)
            view.addSubview(imageView)
        }
        
        // 2. remote url
        
        let imageView = UIImageView(frame: CGRectMake(20, 500, 100, 140))
        imageView.loadImage(with: NSURL(string: "https://avatars.githubusercontent.com/u/11609643?s=400&u=c35f421cfcd3d6caeb200acfcb64f3f7a54764f5&v=4"))
        view.addSubview(imageView)
    }
    
}

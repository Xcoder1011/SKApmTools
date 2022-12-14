//
//  ViewController.swift
//  SKApmTools
//
//  Created by Xcoder1011 on 10/24/2022.
//  Copyright (c) 2022 Xcoder1011. All rights reserved.
//

import UIKit
import SKApmTools

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let titles = ["模拟卡顿","网络监控","日志查询","模拟Crash", "图片检测"]
        for i in 0 ..< titles.count {
            let width = 120
            let height = 45
            let frame = CGRect(x: Int(view.frame.width)/2 - width/2, y:  90 + i * 70, width: width, height: height)
            let btn = UIButton(frame: frame)
            btn.backgroundColor = .red
            btn.setTitle(titles[i], for: .normal)
            btn.addTarget(self, action: #selector(btnClicked(_:)) , for: .touchUpInside)
            view.addSubview(btn)
        }
        // 1.开启卡顿监测
        SKANRMonitor.start()
        let datas = SKANRMonitor.getPendingEntities()
        print("待处理的卡顿数据数目: \(datas.count)")
        SKANRMonitor.monitorCallback { curEntity, allEntities in
            print("监测到卡顿: \(curEntity.validFunction)")
            print(curEntity.threadId)
            print(curEntity.occurenceTime)
            print(curEntity.validAddress)
            print(curEntity.traceContent)
        }
    }
    
    @objc func btnClicked(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            if (title.elementsEqual("图片检测")) {
                // 2.开启图片尺寸检查
                SKImageMonitor.start()
                let ctl = TestLoadImageController()
                self.navigationController?.pushViewController(ctl, animated: true)
            } else {
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


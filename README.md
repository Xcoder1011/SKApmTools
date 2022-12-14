# SKApmTools

APM性能优化相关（swift版本 ）：ANR卡顿监测、网络优化、内存监控、启动优化、常见crash防护、crash监控上报

## Usage

### 1.卡顿监测

开启卡顿监测

```swift
// 1.开启卡顿监测
SKANRMonitor.start()
SKANRMonitor.monitorCallback { curEntity, allEntities in
    print("监测到卡顿: \(curEntity.validFunction)")
    print(curEntity.threadId)
    print(curEntity.occurenceTime)
    print(curEntity.validAddress)
    print(curEntity.traceContent)
}
```

控制台打印卡顿信息

```swift

监测到卡顿: SKApmTools_Example.ViewController.btnClicked(__C.UIButton) -> ()
259
692678740.80218
0x000000010621ccce
0   Foundation                          0x00007ff800c7db5d  +[NSThread sleepForTimeInterval:] + 163 
1   SKApmTools_Example                  0x000000010621ccce  SKApmTools_Example.ViewController.btnClicked(__C.UIButton) -> () + 654 
2   SKApmTools_Example                  0x000000010621cd55  @objc SKApmTools_Example.ViewController.btnClicked(__C.UIButton) -> () + 53 
3   UIKitCore                           0x0000000107b9cd05  -[UIApplication sendAction:to:from:forEvent:] + 95 
4   UIKitCore                           0x00000001072fec74  -[UIControl sendAction:to:forEvent:] + 110 
5   UIKitCore                           0x00000001072ff078  -[UIControl _sendActionsForEvents:withEvent:] + 345 
6   UIKitCore                           0x00000001072fb203  -[UIButton _sendActionsForEvents:withEvent:] + 148 
7   UIKitCore                           0x00000001072fd8cf  -[UIControl touchesEnded:withEvent:] + 485 
8   UIKitCore                           0x0000000107be1e95  -[UIWindow _sendTouchesForEvent:] + 1292 
9   UIKitCore                           0x0000000107be3ef1  -[UIWindow sendEvent:] + 5304 
10  UIKitCore                           0x0000000107bb77f2  -[UIApplication sendEvent:] + 898 
11  UIKitCore                           0x0000000107c5ee61  __dispatchPreprocessedEventFromEventQueue + 9381 
12  UIKitCore                           0x0000000107c61569  __processEventQueue + 8334 
13  UIKitCore                           0x0000000107c578a1  __eventFetcherSourceCallback + 272 
14  CoreFoundation                      0x00007ff800387035  __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17 
15  CoreFoundation                      0x00007ff800386f74  __CFRunLoopDoSource0 + 157 
16  CoreFoundation                      0x00007ff800386771  __CFRunLoopDoSources0 + 212 
17  CoreFoundation                      0x00007ff800380e73  __CFRunLoopRun + 927 
18  CoreFoundation                      0x00007ff8003806f7  CFRunLoopRunSpecific + 560 
19  GraphicsServices                    0x00007ff809c5c28a  GSEventRunModal + 139 
20  UIKitCore                           0x0000000107b9662b  -[UIApplication _run] + 994 
21  UIKitCore                           0x0000000107b9b547  UIApplicationMain + 123 
22  SKApmTools_Example                  0x000000010621e2df  main + 63 
23  dyld                                0x00000001063e32bf  start_sim + 10 
24  ???                                 0x0000000112c83310  0x0 + 4610077456 
```

### 2.图片尺寸检测

开启图片尺寸检测

```swift
 SKImageMonitor.start()
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SKApmTools is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SKApmTools'
```

## Author

Xcoder1011, shangkunwu@msn.com

## License

SKApmTools is available under the MIT license. See the LICENSE file for more info.

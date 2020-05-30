//
//  AppDelegate.swift
//  Live2DMetal
//
//  Created by Ian Wang on 2020/5/30.
//  Copyright © 2020 Ian Wang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewController: L2DMouseTrackingViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        L2DCubism.initialize()
        
        if let path = Bundle.main.path(
            forResource: "hiyori_pro/hiyori_pro.model3",
            ofType: "json"
        ) {
            self.viewController.load(model: path)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        L2DCubism.dispose()
    }
}


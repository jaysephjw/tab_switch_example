//
//  CustomUITabBar.swift
//  Runner
//
//  Created by Jay Warrick on 9/5/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter

class CustomUITabBar : UITabBarController, UITabBarControllerDelegate {
    
    private var flutterEngine: FlutterEngine?
    private var platformVC: UIViewController?
    private var flutterVC1: FlutterViewController?
    private var flutterVC2: FlutterViewController?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Initialize flutter the engine
        self.flutterEngine = FlutterEngine(name: "io.flutter", project: nil)
        flutterEngine?.run(withEntrypoint: nil)
        
        // Initialize VCs
        platformVC = UIViewController(nibName: nil, bundle: nil)
        flutterVC1 = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterVC2 = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        // Clear engine's attached VC for now; we start on a platform tab
        flutterEngine!.viewController = nil

        // Setup tab bar items.
        platformVC!.view.backgroundColor = UIColor.yellow
        platformVC!.tabBarItem = UITabBarItem(title: "Simple", image: nil, selectedImage: nil)
        flutterVC1!.tabBarItem = UITabBarItem(title: "Flutter 1", image: nil, selectedImage: nil)
        flutterVC2!.tabBarItem = UITabBarItem(title: "Flutter 2", image: nil, selectedImage: nil)
        
        // Set the VCs to the tabs
        self.viewControllers = [platformVC!, flutterVC1!, flutterVC2!] 
    }
    
    // Watch for when the user switchces to a FlutterVC. When they do, attach it to the engine.
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.title == "Flutter 1") {
            flutterEngine!.viewController = flutterVC1
        } else if (item.title == "Flutter 2") {
            flutterEngine!.viewController = flutterVC2
        }
    }
}

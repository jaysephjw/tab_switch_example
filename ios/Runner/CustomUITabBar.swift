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
    private var flutterVC1: WrappedVC?
    private var flutterVC2: WrappedVC?

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
        flutterVC1 = WrappedVC(child: FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil), name: "Flutter 1")
        flutterVC2 = WrappedVC(child: FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil), name: "Flutter 2")
        
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
}

// TODO: Do we need to bind to Flutter lifecycle methods with appear/disappear here?
// Like https://github.com/alibaba/flutter_boost/blob/ee90a5f5f5a812a5b97d241fa1d988be3e629961/ios/Classes/container/FLBFlutterViewContainer.m.
class WrappedVC : UIViewController {
    
    public let child: FlutterViewController
    public let name: String
    
    init(child: FlutterViewController, name: String) {
        self.child = child
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        print("\(name) viewDidLoad")
       super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(name) viewWillAppear")
        embedChild()

        if (child.engine.viewController != child) {
            child.engine.viewController = child
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(name) viewDidAppear")

        // Sanity check implied from https://github.com/alibaba/flutter_boost/blob/ee90a5f5f5a812a5b97d241fa1d988be3e629961/ios/Classes/container/FLBFlutterViewContainer.m#L188
        if (child.engine.viewController != child) {
            child.engine.viewController = child
        }
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(name) viewWillDisappear")
        removeChild()
    }
    
    // MARK: Privates
    
    private func embedChild() {
        let flutterView: UIView = child.view!
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(child)
        view.addSubview(flutterView)
        
        let constraints = [
            flutterView.topAnchor.constraint(equalTo: view.topAnchor),
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        child.didMove(toParentViewController: self)
    }
    
    private func removeChild() {
        child.willMove(toParentViewController: nil)
        child.view!.removeFromSuperview()
        child.removeFromParentViewController()
    }

}

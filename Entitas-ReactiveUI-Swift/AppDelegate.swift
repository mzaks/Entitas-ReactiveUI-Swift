//
//  AppDelegate.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 06.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ctx : Context!
    var rootChain : SystemChain!
    private var _link : CADisplayLink!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ctx = Context()
        rootChain = createRootChain(ctx: ctx)
        
        rootChain.initialize()
        
        setupLink()
        
        setupViewController(ctx: ctx, application: application)
        
        return true
    }

    func setupLink() {
        _link = CADisplayLink(target: self, selector: #selector(tick))
        _link.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func tick(){
        rootChain.execute()
        rootChain.cleanup()
    }
    
    func setupViewController(ctx : Context, application : UIApplication){
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let initailViewController = storyBoard.instantiateInitialViewController()
        
        if let vc = initailViewController as? ViewController {
            vc.setContext(ctx: ctx)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = initailViewController
            window.makeKeyAndVisible()
        }
    }
}


//
//  SceneDelegate.swift
//  LeasingActivity
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let dealsView = DealsView().environmentObject(observableDealShell)
            window.rootViewController = UIHostingController(rootView: dealsView)
            self.window = window
            window.makeKeyAndVisible()
            
            dealShell.subscription = { observableDealShell.deals = $0 }
        }
    }
}

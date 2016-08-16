//
//  AppDelegate.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/23/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let dataSource = PassDataSource()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let navController = self.window?.rootViewController as? UINavigationController else { return false }
        guard let viewController = navController.childViewControllers.first as? PassViewController else { return false }
        viewController.dataSource = dataSource
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let navController = self.window?.rootViewController as? UINavigationController else { return false }
        navController.delegate = self
        
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        UINavigationBar.appearance().barTintColor = AppStyle.Color.ForestGreen
        UINavigationBar.appearance().tintColor = UIColor.white
        
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
}

extension AppDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = toVC as? DetailViewController, let _ = fromVC as? PassViewController {
            return ShowDetailAnimator()
        }
        else if let _ = fromVC as? DetailViewController, let _ = toVC as? PassViewController {
            return HideDetailAnimator()
        }
        
        return nil
    }
}

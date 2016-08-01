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
    
    @objc(application:willFinishLaunchingWithOptions:) func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        guard let navController = self.window?.rootViewController as? UINavigationController else { return false }
        guard let viewController = navController.childViewControllers.first as? PassViewController else { return false }
        viewController.dataSource = dataSource
        
        return true
    }

    @objc(application:didFinishLaunchingWithOptions:) func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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

    @objc(applicationWillResignActive:) func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    @objc(applicationDidEnterBackground:) func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    @objc(applicationWillEnterForeground:) func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    @objc(applicationDidBecomeActive:) func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    @objc(applicationWillTerminate:) func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UINavigationControllerDelegate {
    
    @objc(navigationController:animationControllerForOperation:fromViewController:toViewController:)
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

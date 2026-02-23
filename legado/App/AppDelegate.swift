//
//  AppDelegate.swift
//  legado
//
//  App 入口，对应 Android App.kt
//  使用传统 window 生命周期（无 Scene），避免配置歧义
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
        // 主题 / 外观、GRDB、JS 桥接等初始化在后续 Step 完成
        return true
    }
}

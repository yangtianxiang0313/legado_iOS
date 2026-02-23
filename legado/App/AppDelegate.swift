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
        do {
            try AppDatabase.setup()
        } catch {
            fatalError("数据库初始化失败: \(error)")
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
        #if DEBUG
        StepVerification.runAll()
        #endif
        return true
    }
}

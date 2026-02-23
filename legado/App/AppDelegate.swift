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
        // Step 1.1 验证：插入并查询 BookSource（验证通过后删除）
        #if DEBUG
        Self.verifyBookSourceCRUD()
        #endif
        return true
    }

    #if DEBUG
    private static func verifyBookSourceCRUD() {
        var source = BookSource()
        source.bookSourceUrl = "https://example.com"
        source.bookSourceName = "测试书源"
        do {
            try AppDatabase.shared.write { db in
                try source.save(db)
            }
            let fetched = try? AppDatabase.shared.read { db in
                try BookSource.fetchOne(db, key: "https://example.com")
            }
            assert(fetched?.bookSourceName == "测试书源", "BookSource 插入/查询验证失败")
            // 验证后删除测试数据
            try? AppDatabase.shared.write { db in
                _ = try BookSource.deleteOne(db, key: "https://example.com")
            }
        } catch {
            print("BookSource 验证失败: \(error)")
        }
    }
    #endif
}

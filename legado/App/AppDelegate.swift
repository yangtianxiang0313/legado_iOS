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
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard url.scheme == "legado" else { return false }
        Task {
            let service = LegadoURLImportService()
            let result = await service.handle(url: url)
            await MainActor.run {
                handleImportResult(result)
            }
        }
        return true
    }

    private func handleImportResult(_ result: LegadoImportResult) {
        switch result {
        case .success(let count, let path):
            showAlert(title: "导入成功", message: "已导入 \(count) 个\(path == "bookSource" ? "书源" : path)")
        case .unsupportedPath(let path):
            showAlert(title: "不支持", message: "暂不支持 path: \(path)")
        case .missingSrc:
            showAlert(title: "参数错误", message: "缺少 src 参数")
        case .failed(let error):
            showAlert(title: "导入失败", message: error.localizedDescription)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first
        guard let rootVC = window?.rootViewController else { return }
        rootVC.present(alert, animated: true)
    }
}

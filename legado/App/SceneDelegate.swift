//
//  SceneDelegate.swift
//  legado
//
//  Scene 生命周期，创建 UIWindow 与根 VC
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = PlaceholderViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

// MARK: - 占位 VC（Step 0.3 将由 MainTabBarController 替换）

private final class PlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

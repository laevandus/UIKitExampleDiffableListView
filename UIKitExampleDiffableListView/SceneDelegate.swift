//
//  SceneDelegate.swift
//  UIKitExampleDiffableListView
//
//  Created by Toomas Vahter on 17.04.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewModel = ListViewController.ViewModel(palettes: [.fancy, .secondary])
        window?.rootViewController = UINavigationController(rootViewController: ListViewController(viewModel: viewModel))
        window?.makeKeyAndVisible()
    }
}


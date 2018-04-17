//
//  RootViewController.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
    private var previousViewController: UIViewController?
    
    private let popularNavigationController: UINavigationController
    private let favoritesNavigationController: UINavigationController
    
    init(popularNavigationController: UINavigationController, favoritesNavigationController: UINavigationController) {
        self.popularNavigationController = popularNavigationController
        self.favoritesNavigationController = favoritesNavigationController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewControllers = [popularNavigationController, favoritesNavigationController]
    }
}

// MARK: UITabBarControllerDelegate
extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if previousViewController == viewController {
            if let navController = viewController as? UINavigationController {
                if let popularVC = navController.topViewController as? PopularViewController {
                    popularVC.scrollToTop()
                }
                if let favoritesVC = navController.topViewController as? FavoritesViewController {
                    favoritesVC.scrollToTop()
                }
            }
        }
        previousViewController = viewController
    }
}

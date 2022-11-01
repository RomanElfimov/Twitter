//
//  ContainerViewController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 05.11.2021.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    var controller = UIViewController()
    var menuViewController: UIViewController!
    var isMove: Bool = false
    
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80
    
    // MARK: - Lifycycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMainViewController()
    }
    
    // MARK: - Selectors
    
    @objc func dismissMenu() {
        isMove = false
        showMenuViewController(shouldMove: isMove)
    }
    
    // MARK: - Helpers
    
    // Метод подгружает Main Tab View Controller
    func configureMainViewController() {
        let mainTabController = MainTabController()
        mainTabController.menuDelegate = self
        controller = mainTabController
        view.addSubview(controller.view)
        addChild(controller)
    }
    
    // Метод подгружает Menu View Controller
    func configureMenuViewController() {
        // Если нет menuViewController - инициализируем его.
        if menuViewController == nil {
            
            menuViewController = MenuController()
            
            self.view.insertSubview(self.menuViewController.view, at: 0)
            self.addChild(self.menuViewController)
            
            self.configureBlackView()
        }
    }
    
    func showMenuViewController(shouldMove: Bool) {
        if shouldMove {
            // показываем menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.controller.view.frame.origin.x = self.controller.view.frame.width - 80
                self.blackView.alpha = 1
            }
        } else {
            // убираем menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.controller.view.frame.origin.x = 0
                self.menuViewController.view.removeFromSuperview()
                self.blackView.alpha = 0
                self.menuViewController = nil
            }
        }
    }
    
    func configureBlackView() {
        self.blackView.frame = CGRect(x: xOrigin,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }

}

// MARK: - MenuViewControllerDelegate

extension ContainerViewController: MenuViewControllerDelegate {
    
    func toggleMenu() {
        configureMenuViewController()
        
        isMove = !isMove
        showMenuViewController(shouldMove: isMove)
    }
}

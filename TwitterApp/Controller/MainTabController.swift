//
//  MainTabController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 12.10.2021.
//

import UIKit
import Firebase

protocol MenuViewControllerDelegate {
    func toggleMenu()
}

// Enumeration for Action Button
enum ActionButtonConfiguration {
    
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var menuDelegate: MenuViewControllerDelegate?
    
    var user: TwitterUser? {
        didSet {
            guard let nav = viewControllers?.first as? UINavigationController else { return }
            guard let feedVC = nav.viewControllers.first as? FeedController else { return }
            
            feedVC.user = user
        }
    }
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        logUserOut()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
        
        // IOS 15 changes
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .systemBackground
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    
        guard let nav = viewControllers?.first as? UINavigationController else { return }
        guard let feedVC = nav.viewControllers.first as? FeedController else { return }
        feedVC.showMenuDelegate = self
        
        guard let nav = viewControllers?[3] as? UINavigationController else { return }
        guard let convVC = nav.viewControllers.first as? ConversationController else { return }
        convVC.delegate = self
    }
    
    // MARK: - API
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { [weak self] user in
            self?.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonTapped() {
        
        // different button action for different screens
        
        let controller: UIViewController
        
        switch buttonConfig {
        case .message:
            controller = SearchController(config: .messages)
        case .tweet:
            guard let user = user else { return }
            controller = UploadTweetController(user: user, config: .tweet)
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        // IOS 15 changes
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .systemBackground
        nav.navigationBar.standardAppearance = navBarAppearance
        nav.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        self.delegate = self
        
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers() {
        
        let feedVC = generateNavigationController(rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout()),
                                                  image: UIImage(named: "home_unselected")!)
        
        let exploreVC = generateNavigationController(rootViewController: SearchController(config: .userSearch),
                                                     image: UIImage(named: "search_unselected")!)
        let notificationsVC = generateNavigationController(rootViewController: NotificationsController(),
                                                           image: UIImage(named: "like_unselected")!)
        let conversationVC = generateNavigationController(rootViewController: ConversationController(),
                                                          image: UIImage(named: "ic_mail_outline_white_2x-1")!)
        
        viewControllers = [feedVC, exploreVC, notificationsVC, conversationVC]
    }
    
    // MARK: - Private Methods
    
    private func generateNavigationController(rootViewController: UIViewController, image: UIImage) -> UIViewController {
        
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.navigationBar.barTintColor = .white
        
        // IOS 15 changes
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .systemBackground
        navigationVC.navigationBar.standardAppearance = navBarAppearance
        navigationVC.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        return navigationVC
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    // Отслежиает на какой вкладке мы сейчас находимся UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? "mail" : "new_tweet"
        actionButton.setImage(UIImage(named: imageName), for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
    }
}

extension MainTabController: OpenMenuDelegate {
    
    func showMenu() {
        menuDelegate?.toggleMenu()
    }
    
}

extension MainTabController: ChatsControllerProtocol {
    
    func hideNewChatButton() {
        actionButton.removeFromSuperview()
    }
    
    func showNewChatButton() {
        actionButton.setDimensions(width: 56, height: 56)
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
}

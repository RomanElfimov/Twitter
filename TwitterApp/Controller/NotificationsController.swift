//
//  NotificationsController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 12.10.2021.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        
        NotificationService.shared.fetchNotifications { [weak self] notifications in
            
            self?.refreshControl?.endRefreshing()
            self?.notifications = notifications
            self?.checkIsUserIsFollowed(notifications: notifications)
        }
    }
    
    func checkIsUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else {
            presentAlertController(withTitle: "", withMessage: "У вас пока нет уведомлений")
            return
        }
        
        notifications.forEach { notification in
            
            guard case .follow = notification.type else { return }
            let user = notification.user
            
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { [weak self] isFollowed in
                
                if let index = self?.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self?.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        
        view.backgroundColor = .white
        navigationItem.title = "Уведомления"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? NotificationCell else { return UITableViewCell() }
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else { return }
        
        TweetService.shared.fetchTweet(withTweetID: tweetID) { [weak self] tweet in
            let controller = TweetController(tweet: tweet)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelagate

extension NotificationsController: NotificationCellDelagate {
    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return}
        
        if user.isFollowed {
            // unfollow user
            UserService.shared.unfollowUser(uid: user.uid) { _, _ in
                cell.notification?.user.isFollowed = false
            }
        } else {
            // follow user
            UserService.shared.followUser(uid: user.uid) { _, _ in
                cell.notification?.user.isFollowed = true
            }
        }
    }
}

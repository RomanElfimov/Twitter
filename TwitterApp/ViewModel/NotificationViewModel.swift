//
//  NotificationViewModel.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 01.11.2021.
//

import UIKit

struct NotificationViewModel {
    
    // MARK: - Properties
    
    private let notification: Notification
    private let type: NotificationType
    private let user: TwitterUser
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: notification.timestamp, to: now) ?? "2m"
    }
    
    var notificationMessage: String {
        switch type {
        case .follow:
            return " начал читать вас"
        case .like:
            return " оценил твит"
        case .reply:
            return " ответил на твит"
        case .retweet:
            return " рутвитнул ваш твит"
        case .mention:
            return " упомянул вас"
        }
    }
    
    var notificationText: NSAttributedString? {
        guard let timestamp = timestampString else { return nil }
        
        let attributedText = NSMutableAttributedString(string: user.username,
                                       attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage,
                                        attributes: [.font: UIFont.systemFont(ofSize: 12)]))
        
        attributedText.append(NSAttributedString(string: " • \(timestamp)",
                                        attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var shouldHideFollowButton: Bool {
        return type != .follow
    }
    
    var followButtonText: String {
        return user.isFollowed ? "Читаю" : "Читать"
    }
    
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}

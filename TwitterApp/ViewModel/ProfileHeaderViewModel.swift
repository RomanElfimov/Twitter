//
//  ProfileHeaderViewModel.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 21.10.2021.
//

import UIKit

// Опции для фильтрации в Profile View

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Твиты"
        case .replies: return "Твиты и ответы"
        case .likes: return "Нравится"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: TwitterUser
    
    let userNameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "читателей")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "читаемых")
    }
    
    // follow / unfollow button
    var actionButtonTitle: String {
        // if user is current user then set to edit profile
        // else figure out following/not following
        
        if user.isCurrentUser {
            return "Изменить"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            return "Читать"
        }
        
        if user.isFollowed {
            return "Читаю"
        }
        
        return "Loading"
    }
    
    init(user: TwitterUser) {
        self.user = user
        
        self.userNameText = "@" + user.username
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                       attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                        attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
    
}

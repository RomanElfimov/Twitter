//
//  ActionSheetViewModel.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 31.10.2021.
//

import Foundation

// Какие действия в зависимости аккаунта (свой/нет) будут в action sheet table view

struct ActionSheetViewModel {
    
    private let user: TwitterUser
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.report )
        
        return results
    }
    
    init(user: TwitterUser) {
        self.user = user
    }
}

enum ActionSheetOptions {
    case follow(TwitterUser)
    case unfollow(TwitterUser)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user):
            return "Читать @\(user.username)"
        case .unfollow(let user):
            return "Перестать читать @\(user.username)"
        case .report:
            return "Пожаловаться"
        case .delete:
            return "Удалить Твит"
        }
    }
}

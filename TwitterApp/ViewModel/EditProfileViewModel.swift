//
//  EditProfileViewModel.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 03.11.2021.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .username:
            return "Логин"
        case .fullname:
            return "Имя"
        case .bio:
            return "Инфо"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: TwitterUser
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    init(user: TwitterUser, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}

//
//  AuthError.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 16.10.2021.
//

import Foundation

enum AuthError {
    case shortPassword
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .shortPassword:
            return NSLocalizedString("Пароль должен состоять из 6 или более символов", comment: "")
        }
    }
}

// The password is invalid or the user does not have a password.
// The email address is badly formatted.

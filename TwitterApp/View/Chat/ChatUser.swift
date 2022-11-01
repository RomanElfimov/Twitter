//
//  ChatUser.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 08.11.2021.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

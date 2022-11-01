//
//  User.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 17.10.2021.
//

import Foundation
import Firebase

struct TwitterUser {
    
    var fullname: String
    let email: String
    var username: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false
    var stats: UserRelationStats? // following / followers count
    var bio: String?
    
    // текущей ли пользователь
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    // use dictionary for initialize User
    init(uid: String, dictionary: [String: AnyObject]) {
       
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
    }
    
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}

//
//  Constants.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 16.10.2021.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

// for image
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

// upload tweet
let REF_TWEETS = DB_REF.child("tweets")

let REF_USER_TWEETS = DB_REF.child("user-tweets")
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")

let REF_TWEET_REPLIES = DB_REF.child("tweet-replies")

// likes
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_TWEET_LIKES = DB_REF.child("tweet-likes")

// notifications
let REF_NOTIFICATIONS = DB_REF.child("notifications")

let REF_USER_REPLIES = DB_REF.child("user-replies")

let REF_USER_USERNAMES = DB_REF.child("user-usernames")

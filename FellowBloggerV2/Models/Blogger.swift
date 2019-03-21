//
//  Blogger.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/13/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import Foundation

class Blogger {
    let bloggerId: String
    let displayName: String
    let email: String
    let photoURL: String?
    let coverImageURL: String?
    let joinedDate: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let blockedUsers: [String]
    let twitter: String?
    let github: String?
    let linkedIn: String?
    
    public var fullName: String {
        return ((firstName ?? "") + " " + (lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(userId: String,
         displayName: String,
         email: String,
         photoURL: String?,
         coverImageURL: String?,
         joinedDate: String,
         firstName: String?,
         lastName: String?,
         bio: String?,
         blockedUsers: [String],
         twitter: String?,
         github: String?,
         linkedIn: String?) {
        self.bloggerId = userId
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
        self.coverImageURL = coverImageURL
        self.joinedDate = joinedDate
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.blockedUsers = blockedUsers
        self.twitter = twitter
        self.github = github
        self.linkedIn = linkedIn
    }
    
    init(dict: [String: Any]) {
        self.bloggerId = dict[BloggersCollectionKeys.BloggerIdKey] as? String ?? ""
        self.displayName = dict[BloggersCollectionKeys.DisplayNameKey] as? String ?? ""
        self.email = dict[BloggersCollectionKeys.EmailKey] as? String ?? ""
        self.photoURL = dict[BloggersCollectionKeys.PhotoURLKey] as? String ?? ""
        self.coverImageURL = dict[BloggersCollectionKeys.CoverImageURLKey] as? String ?? ""
        self.joinedDate = dict[BloggersCollectionKeys.JoinedDateKey] as? String ?? ""
        self.firstName = dict[BloggersCollectionKeys.FirstNameKey] as? String ?? "FirstName"
        self.lastName = dict[BloggersCollectionKeys.LastNameKey] as? String ?? "LastName"
        self.bio = dict[BloggersCollectionKeys.BioKey] as? String ?? "fellow bloggers are looking forward to reading your bio"
        self.blockedUsers = dict[BloggersCollectionKeys.BlockedUsersKey] as? [String] ?? [String]()
        self.twitter = dict[BloggersCollectionKeys.TwitterKey] as? String ?? ""
        self.github = dict[BloggersCollectionKeys.GithubKey] as? String ?? ""
        self.linkedIn = dict[BloggersCollectionKeys.LinkedInKey] as? String ?? ""
    }
}

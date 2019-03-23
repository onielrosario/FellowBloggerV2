//
//  DBService.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/13/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

struct BloggersCollectionKeys {
    static let CollectionKey = "bloggers"
    static let BloggerIdKey = "bloggerId"
    static let DisplayNameKey = "displayName"
    static let FirstNameKey = "firstName"
    static let LastNameKey = "lastName"
    static let EmailKey = "email"
    static let PhotoURLKey = "photoURL"
    static let CoverImageURLKey = "coverImageURL"
    static let JoinedDateKey = "joinedDate"
    static let BioKey = "bio"
    static let BlockedUsersKey = "blockedUsers"
    static let GithubKey = "github"
    static let TwitterKey = "twitter"
    static let LinkedInKey = "linkedIn"
}

struct BlogsCollectionKeys {
    static let CollectionKey = "blogs"
    static let BlogDescritionKey = "blogDescription"
    static let BloggerIdKey = "bloggerId"
    static let CreatedDateKey = "createdDate"
    static let DocumentIdKey = "documentId"
    static let ImageURLKey = "imageURL"
}

final class DBService {
    private init() {}
    public static var firestoreDB: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }()
    
    //create separate func to post cover image
    
    static public var generateDocumentId: String {
        return firestoreDB.collection(BloggersCollectionKeys.CollectionKey).document().documentID
    }
    
    static public func createBlogger(blogger: Blogger, completion: @escaping (Error?) -> Void) {
        firestoreDB.collection(BloggersCollectionKeys.CollectionKey)
            .document(blogger.bloggerId)
            .setData([ BloggersCollectionKeys.BloggerIdKey : blogger.bloggerId,
                       BloggersCollectionKeys.DisplayNameKey : blogger.displayName,
                       BloggersCollectionKeys.EmailKey       : blogger.email,
                       BloggersCollectionKeys.PhotoURLKey    : blogger.photoURL ?? "",
                       BloggersCollectionKeys.JoinedDateKey  : blogger.joinedDate,
                       BloggersCollectionKeys.BioKey         : blogger.bio ?? ""
            ]) { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
        }
    }
    
    static public func postBlog(blog: Blog) {
        firestoreDB.collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId).setData([
                BlogsCollectionKeys.CreatedDateKey     : blog.createdDate,
                BlogsCollectionKeys.BloggerIdKey          : blog.bloggerId,
                BlogsCollectionKeys.BlogDescritionKey: blog.blogDescription,
                BlogsCollectionKeys.ImageURLKey        : blog.imageURL,
                BlogsCollectionKeys.DocumentIdKey      : blog.documentId
                ])
            { (error) in
                if let error = error {
                    print("posting blog error: \(error)")
                } else {
                    print("blog posted successfully to ref: \(blog.documentId)")
                }
        }
    }
    
    static public func postComment(comment: String, blog: Blog) {
        guard let user = AppDelegate.authService.getCurrentUser() else {
            return
        }
        let docRef = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId)
            .collection(CommentsCollectionKeys.CollectionKey).document()
        DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId)
            .collection(CommentsCollectionKeys.CollectionKey)
            .document(docRef.documentID)
            .setData([CommentsCollectionKeys.CommentIdKey : docRef.documentID,
                      CommentsCollectionKeys.CommentedByKey : user.uid,
                      CommentsCollectionKeys.CommentTextKey : comment,
                      CommentsCollectionKeys.CreatedDateKey : Date.getISOTimestamp(),
                      CommentsCollectionKeys.BlogIdKey : blog.documentId
            ]) { (error) in
                if let error = error {
                    print("failed to add comment with error: \(error.localizedDescription)")
                }
        }
    }
    
    static public func GetComments(blog: Blog, completionHandler: @escaping([Comment]?, Error?) -> Void) {
        DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId)
            .collection(CommentsCollectionKeys.CollectionKey)
            .getDocuments { (comments, error) in
                if let error = error {
                    print("could not get comments with error: \(error.localizedDescription)")
                    completionHandler(nil, error)
                } else if let comments = comments {
                    let allComments = comments.documents.map{Comment(dict: $0.data())}
                    completionHandler(allComments,nil)
                }
        }
    }
}

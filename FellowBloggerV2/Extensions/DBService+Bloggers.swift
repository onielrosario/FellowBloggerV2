//
//  DBService+Bloggers.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/18/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import Foundation



extension DBService {
    static public func getBlogger(userId: String, completion: @escaping(Error?, Blogger?) -> Void) {
        DBService.firestoreDB.collection(BloggersCollectionKeys.CollectionKey)
            .whereField(BloggersCollectionKeys.BloggerIdKey, isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error, nil)
                } else if let snapshot = snapshot?.documents.first {
                    let blogger = Blogger(dict: snapshot.data())
                    completion(nil, blogger)
                }
        }
    }
}

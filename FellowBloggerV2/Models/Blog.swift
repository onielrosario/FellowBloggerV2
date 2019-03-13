//
//  Blog.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/13/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import Foundation


import Foundation

struct Blog {
    let createdDate: String
    let bloggerId: String
    let imageURL: String
    let blogDescription: String
    let documentId: String
    
    init(createdDate: String, bloggerId: String, imageURL: String, blogDescription: String, documentId: String) {
        self.createdDate = createdDate
        self.bloggerId = bloggerId
        self.imageURL = imageURL
        self.blogDescription = blogDescription
        self.documentId = documentId
    }
    
    init(dict: [String: Any]) {
        self.createdDate = dict[BlogsCollectionKeys.CreatedDateKey] as? String ?? "no date"
        self.bloggerId = dict[BlogsCollectionKeys.BloggerIdKey] as? String ?? "no blogger id"
        self.imageURL = dict[BlogsCollectionKeys.ImageURLKey] as? String ?? "no imageURL"
        self.blogDescription = dict[BlogsCollectionKeys.BlogDescritionKey] as? String ?? "no description"
        self.documentId = dict[BlogsCollectionKeys.DocumentIdKey] as? String ?? "no document id"
    }
}

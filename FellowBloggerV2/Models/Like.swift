//
//  Like.swift
//  FellowBloggerV2
//
//  Created by Alex Paul on 3/13/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import Foundation

enum LikeStatus {
  case isLiked
  case noStatus
}

class Like {
  let likeId: String
  let blogId: String
  let likedBy: String
  let createdDate: String
  
  init(likeId: String, blogId: String, likedBy: String, createdDate: String) {
    self.likeId = likeId
    self.blogId = blogId
    self.likedBy = likedBy
    self.createdDate = createdDate
  }
  
  init(dict: [String: Any]) {
    self.likeId = dict[LikesCollectionKeys.LikeIdKey] as? String ?? ""
    self.blogId = dict[LikesCollectionKeys.BlogIdKey] as? String ?? ""
    self.likedBy = dict[LikesCollectionKeys.LikedByKey] as? String ?? ""
    self.createdDate = dict[LikesCollectionKeys.CreatedDateKey] as? String ?? ""
  }
}
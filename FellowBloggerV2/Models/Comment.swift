//
//  Comment.swift
//  FellowBloggerV2
//
//  Created by Alex Paul on 3/12/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import Foundation

struct Comment {
  let blogId: String
  let commentId: String
  let commentText: String
  let commentedBy: String
  let createdDate: String
  
  init(blogId: String, commentId: String, commentText: String,
       commentedBy: String, createdDate: String) {
    self.blogId = blogId
    self.commentId = commentId
    self.commentText = commentText
    self.commentedBy = commentedBy
    self.createdDate = Date.getISOTimestamp()
  }
  
  init(dict: [String: Any]) {
    self.blogId = dict[CommentsCollectionKeys.BlogIdKey] as? String ?? ""
    self.commentId = dict[CommentsCollectionKeys.CommentIdKey] as? String ?? ""
    self.commentText = dict[CommentsCollectionKeys.CommentTextKey] as? String ?? ""
    self.commentedBy = dict[CommentsCollectionKeys.CommentedByKey] as? String ?? ""
    self.createdDate = dict[CommentsCollectionKeys.CreatedDateKey] as? String ?? ""
  }
}
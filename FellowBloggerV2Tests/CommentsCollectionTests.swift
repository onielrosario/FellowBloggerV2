//
//  CommentsCollectionTests.swift
//  FellowBloggerV2Tests
//
//  Created by Oniel Rosario on 3/22/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import XCTest
import FirebaseFirestore
import Firebase
@testable import FellowBloggerV2

class CommentsCollectionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddComment() {
        guard let user = AppDelegate.authService.getCurrentUser() else {
             XCTFail("failed to get user")
            return
        }
        let exp = expectation(description: "comment added")
        let blogId = "Rxj31Ve6PeaLfVeOgSVm"
        let docRef = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blogId)
            .collection(CommentsCollectionKeys.CollectionKey).document()
        DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blogId)
            .collection(CommentsCollectionKeys.CollectionKey)
            .document(docRef.documentID)
            .setData([CommentsCollectionKeys.CommentIdKey : docRef.documentID,
                      CommentsCollectionKeys.CommentedByKey : user.uid,
                      CommentsCollectionKeys.CommentTextKey : "nice!",
                      CommentsCollectionKeys.CreatedDateKey : Date.getISOTimestamp(),
                      CommentsCollectionKeys.BlogIdKey : blogId
            ]) { (error) in
                if let error = error {
                    XCTFail("failed to add comment with error: \(error.localizedDescription)")
                }
                exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
}

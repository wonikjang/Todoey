//
//  Post.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/23/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit

class Post: NSObject {

    var author: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!
    
    var peopleWhoLike: [String] = [String] ()
    
}

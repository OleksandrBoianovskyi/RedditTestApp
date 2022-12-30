//
//  PageModel.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 05.09.2022.
//

import UIKit
import Foundation

// MARK: - PageModel

struct PageModel: Codable {
    let data: Post
}

// MARK: - Post
struct Post: Codable {
    let children: [Child]
}

// MARK: - Child
struct Child: Codable {
    let data: ChildData
}

// MARK: - ChildData
struct ChildData: Codable {
    let title: String
    let subredditNamePrefixed: String
    let numComments: Int
    let score: Int
    let thumbnail: String
    let allAwardings: [AllAwarding]

    enum CodingKeys: String, CodingKey {
        case thumbnail
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case title
        case numComments = "num_comments"
        case score
        case allAwardings = "all_awardings"
    }
    
    init(title: String, subredditNamePrefixed: String, numComments: Int, score: Int, thumbnail: String, allAwardings: [AllAwarding]) {
        self.title = title
        self.subredditNamePrefixed = subredditNamePrefixed
        self.numComments = numComments
        self.score = score
        self.thumbnail = thumbnail
        self.allAwardings = allAwardings
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title =  try values.decode(String.self, forKey: .title)
        subredditNamePrefixed =  try values.decode(String.self, forKey: .subredditNamePrefixed)
        numComments =  try values.decode(Int.self, forKey: .numComments)
        score =  try values.decode(Int.self, forKey: .score)
        thumbnail =  try values.decode(String.self, forKey: .thumbnail)
        allAwardings = try values.decode([AllAwarding].self, forKey: .allAwardings)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(score, forKey: .score)
        try container.encode(numComments, forKey: .numComments)
        try container.encode(subredditNamePrefixed, forKey: .subredditNamePrefixed)
    }
}

// MARK: - AllAwarding

struct AllAwarding: Codable {
    let iconURL: String

    enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
    }
}

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
//    let edited: Bool?
    let numComments: Int
    let preview: Preview?
    let score: Int

    enum CodingKeys: String, CodingKey {
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case title
//        case edited
        case preview
        case numComments = "num_comments"
        case score
    }
}

// MARK: - Preview
struct Preview: Codable {
    let images: [Image]
    let enabled: Bool
}

// MARK: - Image
struct Image: Codable {
    let source: ResizedIcon
    let resolutions: [ResizedIcon]
    let id: String
}

// MARK: - ResizedIcon
struct ResizedIcon: Codable {
    let url: String
    let width, height: Int
}

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
    let data: Posts
}

// MARK: - Post
struct Posts: Codable {
    let children: [Post]
}

// MARK: - Child
struct Post: Codable {
    let data: PostData
}

// MARK: - ChildData
struct PostData: Codable {
    let title: String
    let subredditNamePrefixed: String
    let numComments: Int
    let score: Int
    let thumbnail: String
    let media: Media?
    let isVideo: Bool
    let allAwardings: [AllAwarding]
    let totalAwardsReceived: Int
    let authorFullname: String
    let urlOverriddenByDest: String
    
    enum CodingKeys: String, CodingKey {
        case thumbnail
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case title
        case numComments = "num_comments"
        case score
        case allAwardings = "all_awardings"
        case media
        case isVideo = "is_video"
        case totalAwardsReceived = "total_awards_received"
        case authorFullname = "author_fullname"
        case urlOverriddenByDest = "url_overridden_by_dest"
    }
    
    init(title: String, subredditNamePrefixed: String, numComments: Int, score: Int, thumbnail: String, allAwardings: [AllAwarding], media: Media?, isVideo: Bool, totalAwardsReceived: Int, authorFullname: String, urlOverriddenByDest: String) {
        self.title = title
        self.subredditNamePrefixed = subredditNamePrefixed
        self.numComments = numComments
        self.score = score
        self.thumbnail = thumbnail
        self.allAwardings = allAwardings
        self.media = media
        self.isVideo = isVideo
        self.totalAwardsReceived = totalAwardsReceived
        self.authorFullname = authorFullname
        self.urlOverriddenByDest = urlOverriddenByDest
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title =  try values.decode(String.self, forKey: .title)
        subredditNamePrefixed =  try values.decode(String.self, forKey: .subredditNamePrefixed)
        numComments =  try values.decode(Int.self, forKey: .numComments)
        score =  try values.decode(Int.self, forKey: .score)
        thumbnail =  try values.decode(String.self, forKey: .thumbnail)
        allAwardings = try values.decode([AllAwarding].self, forKey: .allAwardings)
        media = try values.decode(Media?.self, forKey: .media)
        isVideo = try values.decode(Bool.self, forKey: .isVideo)
        totalAwardsReceived = try values.decode(Int.self, forKey: .totalAwardsReceived)
        authorFullname = try values.decode(String.self, forKey: .authorFullname)
        urlOverriddenByDest = try values.decode(String.self, forKey: .urlOverriddenByDest)
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

// MARK: - Media
struct Media: Codable {
    let redditVideo: RedditVideo?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case redditVideo = "reddit_video"
        case type
    }
}

// MARK: - RedditVideo
struct RedditVideo: Codable {
    let bitrateKbps: Int
    let fallbackURL: String
    let height, width: Int
    let scrubberMediaURL: String
    let dashURL: String
    let duration: Int
    let hlsURL: String
    let isGIF: Bool

    enum CodingKeys: String, CodingKey {
        case bitrateKbps = "bitrate_kbps"
        case fallbackURL = "fallback_url"
        case height, width
        case scrubberMediaURL = "scrubber_media_url"
        case dashURL = "dash_url"
        case duration
        case hlsURL = "hls_url"
        case isGIF = "is_gif"
    }
}

//
//  ExploreRule.swift
//  legado
//
//  发现结果规则，对应 Android ExploreRule
//

import Foundation

struct ExploreRule: Codable, Equatable {
    var bookList: String?
    var name: String?
    var author: String?
    var intro: String?
    var kind: String?
    var lastChapter: String?
    var updateTime: String?
    var bookUrl: String?
    var coverUrl: String?
    var wordCount: String?
}

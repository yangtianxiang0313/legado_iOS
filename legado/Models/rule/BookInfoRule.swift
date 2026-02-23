//
//  BookInfoRule.swift
//  legado
//
//  书籍详情页规则，对应 Android BookInfoRule
//

import Foundation

struct BookInfoRule: Codable, Equatable {
    /// init 为 Swift 保留字，用 CodingKeys 映射 JSON 键 "init"
    private var _init: String?
    var initRule: String? {
        get { _init }
        set { _init = newValue }
    }

    var name: String?
    var author: String?
    var intro: String?
    var kind: String?
    var lastChapter: String?
    var updateTime: String?
    var coverUrl: String?
    var tocUrl: String?
    var wordCount: String?
    var canReName: String?
    var downloadUrls: String?

    enum CodingKeys: String, CodingKey {
        case _init = "init"
        case name
        case author
        case intro
        case kind
        case lastChapter
        case updateTime
        case coverUrl
        case tocUrl
        case wordCount
        case canReName
        case downloadUrls
    }
}

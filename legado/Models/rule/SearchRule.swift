//
//  SearchRule.swift
//  legado
//
//  搜索结果处理规则，对应 Android SearchRule
//

import Foundation

struct SearchRule: Codable, Equatable {
    var checkKeyWord: String?
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

//
//  TocRule.swift
//  legado
//
//  目录页规则，对应 Android TocRule
//

import Foundation

struct TocRule: Codable, Equatable {
    var preUpdateJs: String?
    var chapterList: String?
    var chapterName: String?
    var chapterUrl: String?
    var formatJs: String?
    var isVolume: String?
    var isVip: String?
    var isPay: String?
    var updateTime: String?
    var nextTocUrl: String?
}

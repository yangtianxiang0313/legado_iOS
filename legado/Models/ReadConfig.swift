//
//  ReadConfig.swift
//  legado
//
//  阅读配置，对应 Android Book.ReadConfig
//

import Foundation

struct ReadConfig: Codable, Equatable {
    var reverseToc: Bool = false
    var pageAnim: Int?
    var reSegment: Bool = false
    var imageStyle: String?
    var useReplaceRule: Bool?
    var delTag: Int64 = 0
    var ttsEngine: String?
    var splitLongChapter: Bool = true
    var readSimulating: Bool = false
    var startDate: String?
    var startChapter: Int?
    var dailyChapters: Int = 3
}

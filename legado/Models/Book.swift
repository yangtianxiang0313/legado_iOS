//
//  Book.swift
//  legado
//
//  书籍模型，对应 Android Book
//  字段名与 data-models 完全一致
//

import Foundation
import GRDB

struct Book: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "books"

    var bookUrl: String = ""
    var tocUrl: String = ""
    var origin: String = "local"
    var originName: String = ""
    var name: String = ""
    var author: String = ""
    var kind: String?
    var customTag: String?
    var coverUrl: String?
    var customCoverUrl: String?
    var intro: String?
    var customIntro: String?
    var charset: String?
    var type: Int = 0
    var group: Int64 = 0
    var latestChapterTitle: String?
    var latestChapterTime: Int64 = 0
    var lastCheckTime: Int64 = 0
    var lastCheckCount: Int = 0
    var totalChapterNum: Int = 0
    var durChapterTitle: String?
    var durChapterIndex: Int = 0
    var durChapterPos: Int = 0
    var durChapterTime: Int64 = 0
    var wordCount: String?
    var canUpdate: Bool = true
    var order: Int = 0
    var originOrder: Int = 0
    var variable: String?
    var readConfig: ReadConfig?
    var syncTime: Int64 = 0

    init() {}

    // MARK: - GRDB Persistence

    private static let jsonEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .useDefaultKeys
        return e
    }()

    private static let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()

    func encode(to container: inout PersistenceContainer) {
        container["bookUrl"] = bookUrl
        container["tocUrl"] = tocUrl
        container["origin"] = origin
        container["originName"] = originName
        container["name"] = name
        container["author"] = author
        container["kind"] = kind
        container["customTag"] = customTag
        container["coverUrl"] = coverUrl
        container["customCoverUrl"] = customCoverUrl
        container["intro"] = intro
        container["customIntro"] = customIntro
        container["charset"] = charset
        container["type"] = type
        container["group"] = group
        container["latestChapterTitle"] = latestChapterTitle
        container["latestChapterTime"] = latestChapterTime
        container["lastCheckTime"] = lastCheckTime
        container["lastCheckCount"] = lastCheckCount
        container["totalChapterNum"] = totalChapterNum
        container["durChapterTitle"] = durChapterTitle
        container["durChapterIndex"] = durChapterIndex
        container["durChapterPos"] = durChapterPos
        container["durChapterTime"] = durChapterTime
        container["wordCount"] = wordCount
        container["canUpdate"] = canUpdate
        container["order"] = order
        container["originOrder"] = originOrder
        container["variable"] = variable
        container["readConfig"] = encodeReadConfig(readConfig)
        container["syncTime"] = syncTime
    }

    init(row: Row) throws {
        bookUrl = row["bookUrl"] ?? ""
        tocUrl = row["tocUrl"] ?? ""
        origin = row["origin"] ?? "local"
        originName = row["originName"] ?? ""
        name = row["name"] ?? ""
        author = row["author"] ?? ""
        kind = row["kind"]
        customTag = row["customTag"]
        coverUrl = row["coverUrl"]
        customCoverUrl = row["customCoverUrl"]
        intro = row["intro"]
        customIntro = row["customIntro"]
        charset = row["charset"]
        type = row["type"] ?? 0
        group = row["group"] ?? 0
        latestChapterTitle = row["latestChapterTitle"]
        latestChapterTime = row["latestChapterTime"] ?? 0
        lastCheckTime = row["lastCheckTime"] ?? 0
        lastCheckCount = row["lastCheckCount"] ?? 0
        totalChapterNum = row["totalChapterNum"] ?? 0
        durChapterTitle = row["durChapterTitle"]
        durChapterIndex = row["durChapterIndex"] ?? 0
        durChapterPos = row["durChapterPos"] ?? 0
        durChapterTime = row["durChapterTime"] ?? 0
        wordCount = row["wordCount"]
        canUpdate = row["canUpdate"] ?? true
        order = row["order"] ?? 0
        originOrder = row["originOrder"] ?? 0
        variable = row["variable"]
        readConfig = decodeReadConfig(from: row["readConfig"])
        syncTime = row["syncTime"] ?? 0
    }

    private func encodeReadConfig(_ config: ReadConfig?) -> String? {
        guard let config = config else { return nil }
        guard let data = try? Self.jsonEncoder.encode(config) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func decodeReadConfig(from json: String?) -> ReadConfig? {
        guard let json = json, !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? Self.jsonDecoder.decode(ReadConfig.self, from: data)
    }
}

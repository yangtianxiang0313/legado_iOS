//
//  BookSource.swift
//  legado
//
//  书源模型，对应 Android BookSource
//  字段名与 data-models 完全一致
//

import Foundation
import GRDB

struct BookSource: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "book_sources"

    var bookSourceUrl: String = ""
    var bookSourceName: String = ""
    var bookSourceGroup: String?
    var bookSourceType: Int = 0
    var bookUrlPattern: String?
    var customOrder: Int = 0
    var enabled: Bool = true
    var enabledExplore: Bool = true
    var jsLib: String?
    var enabledCookieJar: Bool? = true
    var concurrentRate: String?
    var header: String?
    var loginUrl: String?
    var loginUi: String?
    var loginCheckJs: String?
    var coverDecodeJs: String?
    var bookSourceComment: String?
    var variableComment: String?
    var lastUpdateTime: Int64 = 0
    var respondTime: Int64 = 180_000
    var weight: Int = 0
    var exploreUrl: String?
    var exploreScreen: String?
    var searchUrl: String?
    var ruleExplore: ExploreRule?
    var ruleSearch: SearchRule?
    var ruleBookInfo: BookInfoRule?
    var ruleToc: TocRule?
    var ruleContent: ContentRule?

    init() {}

    // MARK: - Codable（字段缺失用默认值，兼容导入）

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        bookSourceUrl = try c.decodeIfPresent(String.self, forKey: .bookSourceUrl) ?? ""
        bookSourceName = try c.decodeIfPresent(String.self, forKey: .bookSourceName) ?? ""
        bookSourceGroup = try c.decodeIfPresent(String.self, forKey: .bookSourceGroup)
        bookSourceType = try c.decodeIfPresent(Int.self, forKey: .bookSourceType) ?? 0
        bookUrlPattern = try c.decodeIfPresent(String.self, forKey: .bookUrlPattern)
        customOrder = try c.decodeIfPresent(Int.self, forKey: .customOrder) ?? 0
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        enabledExplore = try c.decodeIfPresent(Bool.self, forKey: .enabledExplore) ?? true
        jsLib = try c.decodeIfPresent(String.self, forKey: .jsLib)
        enabledCookieJar = try c.decodeIfPresent(Bool.self, forKey: .enabledCookieJar)
        concurrentRate = try c.decodeIfPresent(String.self, forKey: .concurrentRate)
        header = try c.decodeIfPresent(String.self, forKey: .header)
        loginUrl = try c.decodeIfPresent(String.self, forKey: .loginUrl)
        loginUi = try c.decodeIfPresent(String.self, forKey: .loginUi)
        loginCheckJs = try c.decodeIfPresent(String.self, forKey: .loginCheckJs)
        coverDecodeJs = try c.decodeIfPresent(String.self, forKey: .coverDecodeJs)
        bookSourceComment = try c.decodeIfPresent(String.self, forKey: .bookSourceComment)
        variableComment = try c.decodeIfPresent(String.self, forKey: .variableComment)
        lastUpdateTime = try c.decodeIfPresent(Int64.self, forKey: .lastUpdateTime) ?? 0
        respondTime = try c.decodeIfPresent(Int64.self, forKey: .respondTime) ?? 180_000
        weight = try c.decodeIfPresent(Int.self, forKey: .weight) ?? 0
        exploreUrl = try c.decodeIfPresent(String.self, forKey: .exploreUrl)
        exploreScreen = try c.decodeIfPresent(String.self, forKey: .exploreScreen)
        searchUrl = try c.decodeIfPresent(String.self, forKey: .searchUrl)
        ruleExplore = try c.decodeIfPresent(ExploreRule.self, forKey: .ruleExplore)
        ruleSearch = try c.decodeIfPresent(SearchRule.self, forKey: .ruleSearch)
        ruleBookInfo = try c.decodeIfPresent(BookInfoRule.self, forKey: .ruleBookInfo)
        ruleToc = try c.decodeIfPresent(TocRule.self, forKey: .ruleToc)
        ruleContent = try c.decodeIfPresent(ContentRule.self, forKey: .ruleContent)
    }

    enum CodingKeys: String, CodingKey {
        case bookSourceUrl, bookSourceName, bookSourceGroup, bookSourceType, bookUrlPattern
        case customOrder, enabled, enabledExplore, jsLib, enabledCookieJar, concurrentRate
        case header, loginUrl, loginUi, loginCheckJs, coverDecodeJs
        case bookSourceComment, variableComment
        case lastUpdateTime, respondTime, weight
        case exploreUrl, exploreScreen, searchUrl
        case ruleExplore, ruleSearch, ruleBookInfo, ruleToc, ruleContent
    }

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
        container["bookSourceUrl"] = bookSourceUrl
        container["bookSourceName"] = bookSourceName
        container["bookSourceGroup"] = bookSourceGroup
        container["bookSourceType"] = bookSourceType
        container["bookUrlPattern"] = bookUrlPattern
        container["customOrder"] = customOrder
        container["enabled"] = enabled
        container["enabledExplore"] = enabledExplore
        container["jsLib"] = jsLib
        container["enabledCookieJar"] = enabledCookieJar
        container["concurrentRate"] = concurrentRate
        container["header"] = header
        container["loginUrl"] = loginUrl
        container["loginUi"] = loginUi
        container["loginCheckJs"] = loginCheckJs
        container["coverDecodeJs"] = coverDecodeJs
        container["bookSourceComment"] = bookSourceComment
        container["variableComment"] = variableComment
        container["lastUpdateTime"] = lastUpdateTime
        container["respondTime"] = respondTime
        container["weight"] = weight
        container["exploreUrl"] = exploreUrl
        container["exploreScreen"] = exploreScreen
        container["searchUrl"] = searchUrl
        container["ruleExplore"] = encodeRule(ruleExplore)
        container["ruleSearch"] = encodeRule(ruleSearch)
        container["ruleBookInfo"] = encodeRule(ruleBookInfo)
        container["ruleToc"] = encodeRule(ruleToc)
        container["ruleContent"] = encodeRule(ruleContent)
    }

    init(row: Row) throws {
        bookSourceUrl = row["bookSourceUrl"] ?? ""
        bookSourceName = row["bookSourceName"] ?? ""
        bookSourceGroup = row["bookSourceGroup"]
        bookSourceType = row["bookSourceType"] ?? 0
        bookUrlPattern = row["bookUrlPattern"]
        customOrder = row["customOrder"] ?? 0
        enabled = row["enabled"] ?? true
        enabledExplore = row["enabledExplore"] ?? true
        jsLib = row["jsLib"]
        enabledCookieJar = row["enabledCookieJar"]
        concurrentRate = row["concurrentRate"]
        header = row["header"]
        loginUrl = row["loginUrl"]
        loginUi = row["loginUi"]
        loginCheckJs = row["loginCheckJs"]
        coverDecodeJs = row["coverDecodeJs"]
        bookSourceComment = row["bookSourceComment"]
        variableComment = row["variableComment"]
        lastUpdateTime = row["lastUpdateTime"] ?? 0
        respondTime = row["respondTime"] ?? 180_000
        weight = row["weight"] ?? 0
        exploreUrl = row["exploreUrl"]
        exploreScreen = row["exploreScreen"]
        searchUrl = row["searchUrl"]
        ruleExplore = decodeRule(ExploreRule.self, from: row["ruleExplore"])
        ruleSearch = decodeRule(SearchRule.self, from: row["ruleSearch"])
        ruleBookInfo = decodeRule(BookInfoRule.self, from: row["ruleBookInfo"])
        ruleToc = decodeRule(TocRule.self, from: row["ruleToc"])
        ruleContent = decodeRule(ContentRule.self, from: row["ruleContent"])
    }

    private func encodeRule<T: Encodable>(_ rule: T?) -> String? {
        guard let rule = rule else { return nil }
        guard let data = try? Self.jsonEncoder.encode(rule) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func decodeRule<T: Decodable>(_ type: T.Type, from json: String?) -> T? {
        guard let json = json, !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? Self.jsonDecoder.decode(T.self, from: data)
    }
}

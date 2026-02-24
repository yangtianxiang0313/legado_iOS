//
//  SearchKeyword.swift
//  legado
//
//  搜索历史关键词，对应 Android SearchKeyword
//

import Foundation
import GRDB

struct SearchKeyword: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "search_keywords"

    var word: String = ""
    var usage: Int = 1
    var lastUseTime: Int64 = 0

    init() {}

    init(word: String, usage: Int = 1, lastUseTime: Int64? = nil) {
        self.word = word
        self.usage = usage
        self.lastUseTime = lastUseTime ?? Int64(Date().timeIntervalSince1970 * 1000)
    }

    func encode(to container: inout PersistenceContainer) {
        container["word"] = word
        container["usage"] = usage
        container["lastUseTime"] = lastUseTime
    }

    init(row: Row) throws {
        word = row["word"] ?? ""
        usage = row["usage"] ?? 1
        lastUseTime = row["lastUseTime"] ?? 0
    }
}

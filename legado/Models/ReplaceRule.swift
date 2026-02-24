//
//  ReplaceRule.swift
//  legado
//
//  替换净化规则模型，对应 Android ReplaceRule
//

import Foundation
import GRDB

struct ReplaceRule: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "replace_rules"

    var id: Int64 = 0
    var name: String = ""
    var group: String?
    var pattern: String = ""
    var replacement: String = ""
    var scope: String?
    var scopeTitle: Bool = false
    var scopeContent: Bool = true
    var excludeScope: String?
    var isEnabled: Bool = true
    var isRegex: Bool = true
    var timeoutMillisecond: Int64 = 3000
    var order: Int = Int.min

    init() {}

    func encode(to container: inout PersistenceContainer) {
        if id != 0 { container["id"] = id }
        container["name"] = name
        container["group"] = group
        container["pattern"] = pattern
        container["replacement"] = replacement
        container["scope"] = scope
        container["scopeTitle"] = scopeTitle
        container["scopeContent"] = scopeContent
        container["excludeScope"] = excludeScope
        container["isEnabled"] = isEnabled
        container["isRegex"] = isRegex
        container["timeoutMillisecond"] = timeoutMillisecond
        container["sortOrder"] = order
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(row: Row) throws {
        id = row["id"] ?? 0
        name = row["name"] ?? ""
        group = row["group"]
        pattern = row["pattern"] ?? ""
        replacement = row["replacement"] ?? ""
        scope = row["scope"]
        scopeTitle = row["scopeTitle"] ?? false
        scopeContent = row["scopeContent"] ?? true
        excludeScope = row["excludeScope"]
        isEnabled = row["isEnabled"] ?? true
        isRegex = row["isRegex"] ?? true
        timeoutMillisecond = row["timeoutMillisecond"] ?? 3000
        order = row["sortOrder"] ?? Int.min
    }
}

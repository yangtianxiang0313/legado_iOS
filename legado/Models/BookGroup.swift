//
//  BookGroup.swift
//  legado
//
//  书架分组模型，对应 Android BookGroup
//  groupId：-1 全部、-2 本地、-3 音频等
//

import Foundation
import GRDB

struct BookGroup: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "book_groups"

    static let idRoot: Int64 = -100
    static let idAll: Int64 = -1
    static let idLocal: Int64 = -2
    static let idAudio: Int64 = -3
    static let idNetNone: Int64 = -4
    static let idLocalNone: Int64 = -5
    static let idError: Int64 = -11

    var groupId: Int64 = 1
    var groupName: String = ""
    var cover: String?
    var order: Int = 0
    var enableRefresh: Bool = true
    var show: Bool = true
    var bookSort: Int = -1

    init() {}

    func encode(to container: inout PersistenceContainer) {
        container["groupId"] = groupId
        container["groupName"] = groupName
        container["cover"] = cover
        container["order"] = order
        container["enableRefresh"] = enableRefresh
        container["show"] = show
        container["bookSort"] = bookSort
    }

    init(row: Row) throws {
        groupId = row["groupId"] ?? 1
        groupName = row["groupName"] ?? ""
        cover = row["cover"]
        order = row["order"] ?? 0
        enableRefresh = row["enableRefresh"] ?? true
        show = row["show"] ?? true
        bookSort = row["bookSort"] ?? -1
    }
}

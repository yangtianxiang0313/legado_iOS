//
//  Cookie.swift
//  legado
//
//  书源/RSS 登录态 Cookie，对应 Android Cookie
//

import Foundation
import GRDB

struct Cookie: Codable, TableRecord, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "cookies"

    var url: String = ""
    var cookie: String = ""

    init() {}

    init(url: String, cookie: String) {
        self.url = url
        self.cookie = cookie
    }

    func encode(to container: inout PersistenceContainer) {
        container["url"] = url
        container["cookie"] = cookie
    }

    init(row: Row) throws {
        url = row["url"] ?? ""
        cookie = row["cookie"] ?? ""
    }
}

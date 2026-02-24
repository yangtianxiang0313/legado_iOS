//
//  SearchKeywordRepository.swift
//  legado
//
//  搜索历史 CRUD，对应 Android SearchKeywordDao
//

import Foundation
import GRDB

struct SearchKeywordRepository {
    private let db: DatabaseQueue

    init(db: DatabaseQueue = AppDatabase.shared) {
        self.db = db
    }

    func insert(_ keyword: SearchKeyword) throws {
        try db.write { db in
            var k = keyword
            try k.save(db)
        }
    }

    func insertOrUpdate(word: String) throws {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        if let existing = try get(word: word) {
            var updated = existing
            updated.usage += 1
            updated.lastUseTime = now
            try update(updated)
        } else {
            try insert(SearchKeyword(word: word, usage: 1, lastUseTime: now))
        }
    }

    func update(_ keyword: SearchKeyword) throws {
        try db.write { db in
            var k = keyword
            try k.save(db)
        }
    }

    func get(word: String) throws -> SearchKeyword? {
        try db.read { db in
            try SearchKeyword.fetchOne(db, key: word)
        }
    }

    func allByUsage() throws -> [SearchKeyword] {
        try db.read { db in
            try SearchKeyword.order(Column("usage").desc, Column("lastUseTime").desc).fetchAll(db)
        }
    }

    func allByTime() throws -> [SearchKeyword] {
        try db.read { db in
            try SearchKeyword.order(Column("lastUseTime").desc).fetchAll(db)
        }
    }

    func delete(word: String) throws {
        try db.write { db in
            _ = try SearchKeyword.deleteOne(db, key: word)
        }
    }

    func delete(_ keyword: SearchKeyword) throws {
        try delete(word: keyword.word)
    }
}

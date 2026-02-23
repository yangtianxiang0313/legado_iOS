//
//  BookSourceRepository.swift
//  legado
//
//  BookSource 的 CRUD 封装，对应 Android BookSourceDao
//

import Foundation
import GRDB

struct BookSourceRepository {

    private let db: DatabaseQueue

    init(db: DatabaseQueue = AppDatabase.shared) {
        self.db = db
    }

    func insert(_ source: BookSource) throws {
        try db.write { db in
            var s = source
            try s.save(db)
        }
    }

    func insert(_ sources: [BookSource]) throws {
        try db.write { db in
            for var source in sources {
                try source.save(db)
            }
        }
    }

    func update(_ source: BookSource) throws {
        try db.write { db in
            var s = source
            try s.save(db)
        }
    }

    func get(bookSourceUrl: String) throws -> BookSource? {
        try db.read { db in
            try BookSource.fetchOne(db, key: bookSourceUrl)
        }
    }

    func all() throws -> [BookSource] {
        try db.read { db in
            try BookSource.order(Column("customOrder")).fetchAll(db)
        }
    }

    func has(bookSourceUrl: String) throws -> Bool {
        try db.read { db in
            try BookSource.filter(Column("bookSourceUrl") == bookSourceUrl).fetchCount(db) > 0
        }
    }

    func delete(_ source: BookSource) throws {
        try db.write { db in
            var s = source
            _ = try s.delete(db)
        }
    }

    func delete(bookSourceUrl: String) throws {
        try db.write { db in
            _ = try BookSource.deleteOne(db, key: bookSourceUrl)
        }
    }

    func count() throws -> Int {
        try db.read { db in
            try BookSource.fetchCount(db)
        }
    }
}

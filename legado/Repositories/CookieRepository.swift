//
//  CookieRepository.swift
//  legado
//
//  Cookie CRUD，对应 Android CookieDao
//

import Foundation
import GRDB

struct CookieRepository {
    private let db: DatabaseQueue

    init(db: DatabaseQueue = AppDatabase.shared) {
        self.db = db
    }

    func insert(_ cookie: Cookie) throws {
        try db.write { db in
            var c = cookie
            try c.save(db)
        }
    }

    func update(_ cookie: Cookie) throws {
        try db.write { db in
            var c = cookie
            try c.save(db)
        }
    }

    func get(url: String) throws -> Cookie? {
        try db.read { db in
            try Cookie.fetchOne(db, key: url)
        }
    }

    func all() throws -> [Cookie] {
        try db.read { db in
            try Cookie.fetchAll(db)
        }
    }

    func delete(url: String) throws {
        try db.write { db in
            _ = try Cookie.deleteOne(db, key: url)
        }
    }
}

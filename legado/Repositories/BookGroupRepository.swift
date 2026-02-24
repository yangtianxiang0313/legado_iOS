//
//  BookGroupRepository.swift
//  legado
//
//  书架分组 CRUD，对应 Android BookGroupDao
//

import Foundation
import GRDB

struct BookGroupRepository {
    private let db: DatabaseQueue

    init(db: DatabaseQueue = AppDatabase.shared) {
        self.db = db
    }

    func insert(_ group: BookGroup) throws {
        try db.write { db in
            var g = group
            try g.save(db)
        }
    }

    func update(_ group: BookGroup) throws {
        try db.write { db in
            var g = group
            try g.save(db)
        }
    }

    func get(groupId: Int64) throws -> BookGroup? {
        try db.read { db in
            try BookGroup.fetchOne(db, key: groupId)
        }
    }

    func all() throws -> [BookGroup] {
        try db.read { db in
            try BookGroup.order(Column("order")).fetchAll(db)
        }
    }

    func delete(groupId: Int64) throws {
        try db.write { db in
            _ = try BookGroup.deleteOne(db, key: groupId)
        }
    }
}

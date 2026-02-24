//
//  ReplaceRuleRepository.swift
//  legado
//
//  替换规则 CRUD，对应 Android ReplaceRuleDao
//

import Foundation
import GRDB

struct ReplaceRuleRepository {
    private let db: DatabaseQueue

    init(db: DatabaseQueue = AppDatabase.shared) {
        self.db = db
    }

    func insert(_ rule: inout ReplaceRule) throws {
        try db.write { db in
            try rule.save(db)
        }
    }

    func update(_ rule: ReplaceRule) throws {
        try db.write { db in
            var r = rule
            try r.save(db)
        }
    }

    func get(id: Int64) throws -> ReplaceRule? {
        try db.read { db in
            try ReplaceRule.fetchOne(db, key: id)
        }
    }

    func all() throws -> [ReplaceRule] {
        try db.read { db in
            try ReplaceRule.order(Column("sortOrder")).fetchAll(db)
        }
    }

    func enabled() throws -> [ReplaceRule] {
        try db.read { db in
            try ReplaceRule.filter(Column("isEnabled") == true).order(Column("sortOrder")).fetchAll(db)
        }
    }

    func delete(id: Int64) throws {
        try db.write { db in
            _ = try ReplaceRule.deleteOne(db, key: id)
        }
    }
}

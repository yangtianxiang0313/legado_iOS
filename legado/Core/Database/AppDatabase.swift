//
//  AppDatabase.swift
//  legado
//
//  GRDB 数据库封装，对应 Android AppDatabase
//

import Foundation
import GRDB

enum AppDatabase {
    static var shared: DatabaseQueue!

    static func setup() throws {
        let path = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("legado", isDirectory: true)
            .path
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        let dbPath = "\(path)/legado.sqlite"
        shared = try DatabaseQueue(path: dbPath)
        try migrate(shared)
    }

    private static func migrate(_ db: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("create_book_sources") { db in
            try db.create(table: BookSource.databaseTableName) { t in
                t.primaryKey(["bookSourceUrl"])
                t.column("bookSourceUrl", .text).notNull()
                t.column("bookSourceName", .text).notNull()
                t.column("bookSourceGroup", .text)
                t.column("bookSourceType", .integer).notNull().defaults(to: 0)
                t.column("bookUrlPattern", .text)
                t.column("customOrder", .integer).notNull().defaults(to: 0)
                t.column("enabled", .boolean).notNull().defaults(to: true)
                t.column("enabledExplore", .boolean).notNull().defaults(to: true)
                t.column("jsLib", .text)
                t.column("enabledCookieJar", .boolean)
                t.column("concurrentRate", .text)
                t.column("header", .text)
                t.column("loginUrl", .text)
                t.column("loginUi", .text)
                t.column("loginCheckJs", .text)
                t.column("coverDecodeJs", .text)
                t.column("bookSourceComment", .text)
                t.column("variableComment", .text)
                t.column("lastUpdateTime", .integer).notNull().defaults(to: 0)
                t.column("respondTime", .integer).notNull().defaults(to: 180000)
                t.column("weight", .integer).notNull().defaults(to: 0)
                t.column("exploreUrl", .text)
                t.column("exploreScreen", .text)
                t.column("searchUrl", .text)
                t.column("ruleExplore", .text)
                t.column("ruleSearch", .text)
                t.column("ruleBookInfo", .text)
                t.column("ruleToc", .text)
                t.column("ruleContent", .text)
            }
        }
        try migrator.migrate(db)
    }
}

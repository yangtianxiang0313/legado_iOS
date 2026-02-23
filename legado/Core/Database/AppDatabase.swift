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
        migrator.registerMigration("create_books") { db in
            try db.create(table: Book.databaseTableName) { t in
                t.primaryKey(["bookUrl"])
                t.column("bookUrl", .text).notNull()
                t.column("tocUrl", .text).notNull().defaults(to: "")
                t.column("origin", .text).notNull().defaults(to: "local")
                t.column("originName", .text).notNull().defaults(to: "")
                t.column("name", .text).notNull().defaults(to: "")
                t.column("author", .text).notNull().defaults(to: "")
                t.column("kind", .text)
                t.column("customTag", .text)
                t.column("coverUrl", .text)
                t.column("customCoverUrl", .text)
                t.column("intro", .text)
                t.column("customIntro", .text)
                t.column("charset", .text)
                t.column("type", .integer).notNull().defaults(to: 0)
                t.column("group", .integer).notNull().defaults(to: 0)
                t.column("latestChapterTitle", .text)
                t.column("latestChapterTime", .integer).notNull().defaults(to: 0)
                t.column("lastCheckTime", .integer).notNull().defaults(to: 0)
                t.column("lastCheckCount", .integer).notNull().defaults(to: 0)
                t.column("totalChapterNum", .integer).notNull().defaults(to: 0)
                t.column("durChapterTitle", .text)
                t.column("durChapterIndex", .integer).notNull().defaults(to: 0)
                t.column("durChapterPos", .integer).notNull().defaults(to: 0)
                t.column("durChapterTime", .integer).notNull().defaults(to: 0)
                t.column("wordCount", .text)
                t.column("canUpdate", .boolean).notNull().defaults(to: true)
                t.column("order", .integer).notNull().defaults(to: 0)
                t.column("originOrder", .integer).notNull().defaults(to: 0)
                t.column("variable", .text)
                t.column("readConfig", .text)
                t.column("syncTime", .integer).notNull().defaults(to: 0)
            }
        }
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

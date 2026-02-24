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
        migrator.registerMigration("create_book_groups") { db in
            try db.create(table: BookGroup.databaseTableName) { t in
                t.primaryKey(["groupId"])
                t.column("groupId", .integer).notNull()
                t.column("groupName", .text).notNull().defaults(to: "")
                t.column("cover", .text)
                t.column("order", .integer).notNull().defaults(to: 0)
                t.column("enableRefresh", .boolean).notNull().defaults(to: true)
                t.column("show", .boolean).notNull().defaults(to: true)
                t.column("bookSort", .integer).notNull().defaults(to: -1)
            }
        }
        migrator.registerMigration("create_replace_rules") { db in
            try db.create(table: ReplaceRule.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().defaults(to: "")
                t.column("group", .text)
                t.column("pattern", .text).notNull().defaults(to: "")
                t.column("replacement", .text).notNull().defaults(to: "")
                t.column("scope", .text)
                t.column("scopeTitle", .boolean).notNull().defaults(to: false)
                t.column("scopeContent", .boolean).notNull().defaults(to: true)
                t.column("excludeScope", .text)
                t.column("isEnabled", .boolean).notNull().defaults(to: true)
                t.column("isRegex", .boolean).notNull().defaults(to: true)
                t.column("timeoutMillisecond", .integer).notNull().defaults(to: 3000)
                t.column("sortOrder", .integer).notNull().defaults(to: 0)
            }
        }
        migrator.registerMigration("create_search_keywords") { db in
            try db.create(table: SearchKeyword.databaseTableName) { t in
                t.primaryKey(["word"])
                t.column("word", .text).notNull()
                t.column("usage", .integer).notNull().defaults(to: 1)
                t.column("lastUseTime", .integer).notNull().defaults(to: 0)
            }
        }
        migrator.registerMigration("create_cookies") { db in
            try db.create(table: Cookie.databaseTableName) { t in
                t.primaryKey(["url"])
                t.column("url", .text).notNull()
                t.column("cookie", .text).notNull().defaults(to: "")
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

    /// 供 XCTest 使用的测试库，与真实数据隔离，全用例公用一个
    private static var testDBInitialized = false

    static func setupForTesting() throws {
        if testDBInitialized { return }
        let testDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("legado_test", isDirectory: true)
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        let dbPath = testDir.appendingPathComponent("legado.sqlite").path
        shared = try DatabaseQueue(path: dbPath)
        try migrate(shared)
        testDBInitialized = true
    }
}

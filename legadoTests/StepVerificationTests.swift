//
//  StepVerificationTests.swift
//  legadoTests
//
//  phased-implementation 各 Step 的 XCTest 验证
//  运行: xcodebuild test -scheme legado -destination 'platform=iOS Simulator,name=iPhone 16e'
//

import XCTest
@testable import legado

final class StepVerificationTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        try AppDatabase.setupForTesting()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Step 1.1 BookSource CRUD

    func testStep1_1_BookSourceCRUD() throws {
        let repo = BookSourceRepository()
        var source = BookSource()
        source.bookSourceUrl = "https://example.com"
        source.bookSourceName = "测试书源"

        try repo.insert(source)
        let fetched = try repo.get(bookSourceUrl: "https://example.com")
        XCTAssertEqual(fetched?.bookSourceName, "测试书源", "BookSourceRepository 插入/查询验证")

        try repo.delete(bookSourceUrl: "https://example.com")
    }

    // MARK: - Step 1.2 Book CRUD

    func testStep1_2_BookCRUD() throws {
        var book = Book()
        book.bookUrl = "https://example.com/book1"
        book.name = "测试书籍"
        book.author = "测试作者"

        try AppDatabase.shared.write { db in
            try book.save(db)
        }
        let fetched = try AppDatabase.shared.read { db in
            try Book.fetchOne(db, key: "https://example.com/book1")
        }
        XCTAssertEqual(fetched?.name, "测试书籍", "Book 插入/查询验证")

        try AppDatabase.shared.write { db in
            _ = try Book.deleteOne(db, key: "https://example.com/book1")
        }
    }

    // MARK: - Step 1.3 BookSourceRepository

    func testStep1_3_BookSourceRepository() throws {
        let repo = BookSourceRepository()
        var source = BookSource()
        source.bookSourceUrl = "https://repo-test.com"
        source.bookSourceName = "Repository 测试"

        try repo.insert(source)
        let fetched = try repo.get(bookSourceUrl: "https://repo-test.com")
        XCTAssertEqual(fetched?.bookSourceName, "Repository 测试")
        XCTAssertEqual(try repo.count(), 1)

        try repo.delete(bookSourceUrl: "https://repo-test.com")
        XCTAssertNil(try repo.get(bookSourceUrl: "https://repo-test.com"))
    }

    // MARK: - Step 1.4 BookSource JSON 导入

    func testStep1_4_BookSourceImport() throws {
        let json = """
        {"bookSourceUrl":"https://import-test.com","bookSourceName":"导入测试书源"}
        """
        let service = BookSourceImportService()
        let count = try service.importFromJSON(json)

        XCTAssertEqual(count, 1, "BookSource JSON 导入应返回 1")

        let repo = BookSourceRepository()
        let fetched = try repo.get(bookSourceUrl: "https://import-test.com")
        XCTAssertEqual(fetched?.bookSourceName, "导入测试书源")

        try repo.delete(bookSourceUrl: "https://import-test.com")
    }

    // MARK: - Step 1.5 HttpClient

    func testStep1_5_HttpClient() async throws {
        let client = HttpClient()
        let body = try await client.request(url: "https://httpbin.org/get")

        XCTAssertFalse(body.isEmpty)
        XCTAssertTrue(body.contains("httpbin.org"))

        let bodyWithHeader = try await client.request(
            url: "https://httpbin.org/headers",
            headers: #"{"X-Custom-Header":"Step1.5"}"#
        )
        XCTAssertTrue(bodyWithHeader.contains("X-Custom-Header"))
        XCTAssertTrue(bodyWithHeader.contains("Step1.5"))
    }

    // MARK: - Step 1.6 legado:// URL Scheme 解析

    func testStep1_6_LegadoURLImport() async throws {
        let service = LegadoURLImportService()

        let noSrc = URL(string: "legado://import/bookSource")!
        let r1 = await service.handle(url: noSrc)
        if case .missingSrc = r1 { } else {
            XCTFail("缺少 src 应返回 missingSrc")
        }

        let unsupported = URL(string: "legado://import/other?src=https://example.com")!
        let r2 = await service.handle(url: unsupported)
        if case .unsupportedPath = r2 { } else {
            XCTFail("不支持的 path 应返回 unsupportedPath")
        }
    }

    // MARK: - Step 1.7 书源管理列表

    func testStep1_7_BookSourceList() throws {
        let repo = BookSourceRepository()
        var count = try repo.count()

        if count == 0 {
            var demo = BookSource()
            demo.bookSourceUrl = "https://step17-demo.legado"
            demo.bookSourceName = "演示书源"
            try repo.insert(demo)
            count = 1
        }

        let all = try repo.all()
        XCTAssertEqual(all.count, count, "BookSourceRepository.all 应与 count 一致")
    }

    // MARK: - Step 2.1 规则切分器

    func testStep2_1_RuleParser() throws {
        let r1 = RuleParser.splitRule("a||b").map(\.rule)
        XCTAssertEqual(r1, ["a", "b"], "a||b 应切分为 [a,b]")

        let r2 = RuleParser.splitRule("a&&b").map(\.rule)
        XCTAssertEqual(r2, ["a", "b"], "a&&b 应切分为 [a,b]")

        let r3 = RuleParser.splitRule(#"a||"b||c""#).map(\.rule)
        XCTAssertEqual(r3, [#"a"#, #""b||c""#], #"引号内 || 不切分"#)
    }

    // MARK: - Step 2.2 URL 占位符替换

    func testStep2_2_UrlPlaceholder() throws {
        let url = "https://x.com/search?key={{key}}&page={{page}}"
        let result = UrlPlaceholder.replacePlaceholders(in: url, key: "test", page: 1)
        XCTAssertEqual(result, "https://x.com/search?key=test&page=1")

        // exploreKey
        let url2 = "https://x.com/explore?cat={{exploreKey}}"
        let result2 = UrlPlaceholder.replacePlaceholders(in: url2, exploreKey: "玄幻")
        XCTAssertEqual(result2, "https://x.com/explore?cat=玄幻")

        // <1,2,3> 页码列表
        let url3 = "https://x.com/list<1,2,3>"
        let r3a = UrlPlaceholder.replacePlaceholders(in: url3, page: 1)
        XCTAssertEqual(r3a, "https://x.com/list1")
        let r3b = UrlPlaceholder.replacePlaceholders(in: url3, page: 3)
        XCTAssertEqual(r3b, "https://x.com/list3")
    }

    // MARK: - Step 2.3 CSS 解析器（SwiftSoup）

    func testStep2_3_SwiftSoupAnalyzer() throws {
        let html = #"<div class='x'><a href='/a'>链接</a></div>"#
        let rule = "@css:.x a@text"
        let result = try SwiftSoupAnalyzer.evaluate(html: html, rule: rule)
        XCTAssertEqual(result, "链接", "HTML + @css:.x a@text 应得到「链接」")

        // href
        let hrefResult = try SwiftSoupAnalyzer.evaluate(html: html, rule: "@css:.x a@href")
        XCTAssertEqual(hrefResult, "/a")

        // 净化 ##正则##替换
        let html2 = "<p> 多余空格 </p>"
        let rule2 = "@css:p@text##\\s+##"
        let r2 = try SwiftSoupAnalyzer.evaluate(html: html2, rule: rule2)
        XCTAssertNotNil(r2)
        XCTAssertFalse(r2?.contains("  ") ?? true, "净化后不应含连续空格")
    }

    // MARK: - Step 2.4 JSONPath 解析器（Sextant）

    func testStep2_4_SextantAnalyzer() throws {
        let json = #"{"data":{"name":"书"}}"#
        let path = "$.data.name"
        let result = SextantAnalyzer.evaluate(json: json, path: path)
        XCTAssertEqual(result, "书", "JSON + $.data.name 应得到「书」")
    }
}

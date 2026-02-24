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

    // MARK: - Step 0.4 日志初始化

    func testStep0_4_LogConfig() throws {
        LogConfig.setup()
        LogConfig.logTestMessage()
        // 调用日志 API 无崩溃即通过；控制台可见输出
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

    // MARK: - Step 1.8 BookGroup

    func testStep1_8_BookGroup() throws {
        let repo = BookGroupRepository()
        var group = BookGroup()
        group.groupId = 100
        group.groupName = "自定义分组"

        try repo.insert(group)
        let fetched = try repo.get(groupId: 100)
        XCTAssertEqual(fetched?.groupName, "自定义分组")

        let all = try repo.all()
        XCTAssertTrue(all.contains { $0.groupId == 100 })

        try repo.delete(groupId: 100)
    }

    // MARK: - Step 1.9 ReplaceRule

    func testStep1_9_ReplaceRule() throws {
        let repo = ReplaceRuleRepository()
        var rule = ReplaceRule()
        rule.name = "测试规则"
        rule.pattern = "广告"
        rule.replacement = ""
        rule.isEnabled = true

        try repo.insert(&rule)
        XCTAssertTrue(rule.id > 0)

        let all = try repo.all()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all[0].name, "测试规则")

        var fetched = try repo.get(id: rule.id)!
        fetched.isEnabled = false
        try repo.update(fetched)

        let enabled = try repo.enabled()
        XCTAssertTrue(enabled.isEmpty || !enabled.contains { $0.id == rule.id })

        try repo.delete(id: rule.id)
    }

    // MARK: - Step 1.10 SearchKeyword

    func testStep1_10_SearchKeyword() throws {
        let repo = SearchKeywordRepository()
        try repo.insertOrUpdate(word: "测试")
        try repo.insertOrUpdate(word: "测试")  // usage 应增加

        let byUsage = try repo.allByUsage()
        XCTAssertTrue(byUsage.contains { $0.word == "测试" })
        XCTAssertEqual(byUsage.first { $0.word == "测试" }?.usage, 2)

        try repo.delete(word: "测试")
        XCTAssertNil(try repo.get(word: "测试"))
    }

    // MARK: - Step 1.11 Cookie

    func testStep1_11_Cookie() throws {
        let repo = CookieRepository()
        let cookie = Cookie(url: "https://example.com", cookie: "session=abc123")

        try repo.insert(cookie)
        let fetched = try repo.get(url: "https://example.com")
        XCTAssertEqual(fetched?.cookie, "session=abc123")

        try repo.delete(url: "https://example.com")
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

    // MARK: - Step 2.5 AnalyzeRule 主入口

    func testStep2_5_AnalyzeRule() throws {
        // HTML + CSS 规则
        let html = #"<div class='x'><a href='/a'>链接</a></div>"#
        let r1 = AnalyzeRule.getString(content: html, rule: "@css:.x a@text")
        XCTAssertEqual(r1, "链接", "HTML + @css 应得「链接」")

        // JSON + $. 规则
        let json = #"{"data":{"name":"书"}}"#
        let r2 = AnalyzeRule.getString(content: json, rule: "$.data.name")
        XCTAssertEqual(r2, "书", "JSON + $. 应得「书」")

        // || 链取第一个非空（$.missing 对 HTML 无效，取 @css）
        let r3 = AnalyzeRule.getString(content: html, rule: "@css:.none||@css:.x a@text")
        XCTAssertEqual(r3, "链接", "|| 应取第一个有值")
    }

    // MARK: - Step 2.6 HTTP 请求 + 规则解析（单书源搜索）

    func testStep2_6_AnalyzeRuleGetElements() throws {
        // HTML bookList
        let html = """
        <div class="book"><a href="/book/1">书一</a><span class="author">作者A</span></div>
        <div class="book"><a href="/book/2">书二</a><span class="author">作者B</span></div>
        """
        let elements = AnalyzeRule.getElements(content: html, rule: "@css:.book")
        XCTAssertEqual(elements.count, 2, "bookList 应得 2 个元素")
        let name1 = AnalyzeRule.getString(content: elements[0], rule: "@css:a@text")
        XCTAssertEqual(name1, "书一")
        let author1 = AnalyzeRule.getString(content: elements[0], rule: "@css:.author@text")
        XCTAssertEqual(author1, "作者A")

        // JSON bookList
        let json = #"{"data":{"books":[{"name":"书A","author":"作者甲"},{"name":"书B","author":"作者乙"}]}}"#
        let jsonElements = AnalyzeRule.getElements(content: json, rule: "$.data.books")
        XCTAssertEqual(jsonElements.count, 2, "JSON bookList 应得 2 个元素")
        let jName = AnalyzeRule.getString(content: jsonElements[0], rule: "$.name")
        XCTAssertEqual(jName, "书A")
    }

    func testStep2_6_WebBookServiceSearchBook() async throws {
        let html = """
        <html><body>
        <div class="book-item">
            <a class="title" href="/book/abc">三体</a>
            <span class="author">刘慈欣</span>
        </div>
        </body></html>
        """
        var source = BookSource()
        source.bookSourceUrl = "https://search-test.legado"
        source.bookSourceName = "搜索测试"
        source.searchUrl = "https://search-test.legado/search"
        source.ruleSearch = SearchRule(
            bookList: "@css:.book-item",
            name: "@css:.title@text",
            author: "@css:.author@text",
            bookUrl: "@css:.title@href"
        )

        let results = try await WebBookService.searchBook(
            bookSource: source,
            key: "三体",
            page: 1,
            bodyOverride: html
        )

        XCTAssertFalse(results.isEmpty, "选一有效书源+关键词，应返回非空 [SearchBook]")
        XCTAssertEqual(results[0].name, "三体")
        XCTAssertEqual(results[0].author, "刘慈欣")
        XCTAssertTrue(results[0].bookUrl.contains("abc") || results[0].bookUrl.hasSuffix("/book/abc"))
        XCTAssertEqual(results[0].origin, "https://search-test.legado")
    }
}

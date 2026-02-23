//
//  StepVerification.swift
//  legado
//
//  phased-implementation 各 Step 的验证逻辑，仅 DEBUG 构建执行
// 抽离自 AppDelegate，保持主流程清晰
//

import Foundation
import GRDB

#if DEBUG
enum StepVerification {

    /// 启动时执行全部验证（由 AppDelegate 调用）
    static func runAll() {
        verifyBookSourceCRUD()
        verifyBookCRUD()
        verifyBookSourceImport()
        Task { await verifyHttpClient() }
    }

    // MARK: - Step 1.1 验证：BookSource CRUD

    private static func verifyBookSourceCRUD() {
        let repo = BookSourceRepository()
        var source = BookSource()
        source.bookSourceUrl = "https://example.com"
        source.bookSourceName = "测试书源"
        do {
            try repo.insert(source)
            let fetched = try? repo.get(bookSourceUrl: "https://example.com")
            assert(fetched?.bookSourceName == "测试书源", "BookSourceRepository 插入/查询验证失败")
            try? repo.delete(bookSourceUrl: "https://example.com")
        } catch {
            print("BookSourceRepository 验证失败: \(error)")
        }
    }

    // MARK: - Step 1.1 验证：Book CRUD

    private static func verifyBookCRUD() {
        var book = Book()
        book.bookUrl = "https://example.com/book1"
        book.name = "测试书籍"
        book.author = "测试作者"
        do {
            try AppDatabase.shared.write { db in
                try book.save(db)
            }
            let fetched = try? AppDatabase.shared.read { db in
                try Book.fetchOne(db, key: "https://example.com/book1")
            }
            assert(fetched?.name == "测试书籍", "Book 插入/查询验证失败")
            try? AppDatabase.shared.write { db in
                _ = try Book.deleteOne(db, key: "https://example.com/book1")
            }
        } catch {
            print("Book 验证失败: \(error)")
        }
    }

    // MARK: - Step 1.6 验证：BookSource JSON 导入

    private static func verifyBookSourceImport() {
        let json = """
        {"bookSourceUrl":"https://import-test.com","bookSourceName":"导入测试书源"}
        """
        let service = BookSourceImportService()
        do {
            let count = try service.importFromJSON(json)
            assert(count == 1, "BookSource JSON 导入验证失败")
            let repo = BookSourceRepository()
            let fetched = try? repo.get(bookSourceUrl: "https://import-test.com")
            assert(fetched?.bookSourceName == "导入测试书源", "导入后查询验证失败")
            try? repo.delete(bookSourceUrl: "https://import-test.com")
        } catch {
            print("BookSource 导入验证失败: \(error)")
        }
    }

    // MARK: - Step 1.5 验证：HttpClient GET 请求

    private static func verifyHttpClient() async {
        let client = HttpClient()
        do {
            let body = try await client.request(url: "https://httpbin.org/get")
            assert(!body.isEmpty, "HttpClient 返回 body 不应为空")
            assert(body.contains("httpbin.org"), "应包含请求 URL 信息")
            // 测试自定义 header
            let bodyWithHeader = try await client.request(
                url: "https://httpbin.org/headers",
                headers: #"{"X-Custom-Header":"Step1.5"}"#
            )
            assert(bodyWithHeader.contains("X-Custom-Header"), "自定义 header 应被发送")
            assert(bodyWithHeader.contains("Step1.5"), "header 值应正确")
            print("HttpClient 验证通过")
        } catch {
            print("HttpClient 验证失败: \(error)")
        }
    }
}
#endif

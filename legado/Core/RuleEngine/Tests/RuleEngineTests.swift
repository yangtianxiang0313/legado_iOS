//
//  RuleEngineTests.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 规则引擎测试类
class RuleEngineTests {
    
    private let unifiedAnalyzer = UnifiedRuleAnalyzer()
    
    // MARK: - 测试数据
    
    private let testHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>测试页面</title>
    </head>
    <body>
        <div class="book-list">
            <div class="book-item" data-id="1">
                <h3 class="title">书籍标题1</h3>
                <p class="author">作者1</p>
                <a href="/book/1" class="link">详情链接</a>
            </div>
            <div class="book-item" data-id="2">
                <h3 class="title">书籍标题2</h3>
                <p class="author">作者2</p>
                <a href="/book/2" class="link">详情链接</a>
            </div>
        </div>
        <div class="pagination">
            <span class="current">1</span>
            <a href="/page/2">2</a>
            <a href="/page/3">3</a>
        </div>
    </body>
    </html>
    """
    
    // MARK: - 测试方法
    
    /// 运行所有测试
    func runAllTests() {
        print("=== 规则引擎测试开始 ===")
        
        testRuleTypeDetection()
        testJSoupAnalyzer()
        testXPathAnalyzer()
        testRegexAnalyzer()
        testUnifiedAnalyzer()
        
        print("=== 规则引擎测试完成 ===")
    }
    
    /// 测试规则类型检测
    private func testRuleTypeDetection() {
        print("\n--- 测试规则类型检测 ---")
        
        let testCases = [
            (".book-item", RuleType.jsoup),
            ("//div[@class='book-item']", RuleType.xpath),
            ("##\\d+", RuleType.regex),
            ("@js:return 'test'", RuleType.javascript),
            ("$.books[0].title", RuleType.jsonPath)
        ]
        
        for (rule, expectedType) in testCases {
            let detectedType = unifiedAnalyzer.detectRuleType(rule)
            let result = detectedType == expectedType ? "✅" : "❌"
            print("\(result) 规则: \(rule) -> 检测类型: \(detectedType), 期望类型: \(expectedType)")
        }
    }
    
    /// 测试JSoup解析器
    private func testJSoupAnalyzer() {
        print("\n--- 测试JSoup解析器 ---")
        
        do {
            // 测试CSS选择器
            let titles = try unifiedAnalyzer.analyzeWithType(
                content: testHTML,
                rule: ".book-item .title",
                type: .jsoup
            )
            print("✅ 书籍标题: \(titles)")
            
            // 测试属性获取
            let bookIds = try unifiedAnalyzer.getAttributes(
                content: testHTML,
                rule: ".book-item",
                attribute: "data-id"
            )
            print("✅ 书籍ID: \(bookIds)")
            
            // 测试链接获取
            let links = try unifiedAnalyzer.getAttributes(
                content: testHTML,
                rule: ".book-item .link",
                attribute: "href"
            )
            print("✅ 详情链接: \(links)")
            
        } catch {
            print("❌ JSoup测试失败: \(error)")
        }
    }
    
    /// 测试XPath解析器
    private func testXPathAnalyzer() {
        print("\n--- 测试XPath解析器 ---")
        
        do {
            // 测试XPath表达式
            let authors = try unifiedAnalyzer.analyzeWithType(
                content: testHTML,
                rule: "//p[@class='author']/text()",
                type: .xpath
            )
            print("✅ 作者信息: \(authors)")
            
            // 测试属性获取
            let hrefs = try unifiedAnalyzer.getAttributes(
                content: testHTML,
                rule: "//a[@class='link']",
                attribute: "href"
            )
            print("✅ 链接地址: \(hrefs)")
            
        } catch {
            print("❌ XPath测试失败: \(error)")
        }
    }
    
    /// 测试正则表达式解析器
    private func testRegexAnalyzer() {
        print("\n--- 测试正则表达式解析器 ---")
        
        do {
            // 测试正则表达式
            let pageNumbers = try unifiedAnalyzer.analyzeWithType(
                content: testHTML,
                rule: "href=\"/page/(\\d+)\"",
                type: .regex
            )
            print("✅ 页码: \(pageNumbers)")
            
            // 测试书籍ID提取
            let dataIds = try unifiedAnalyzer.analyzeWithType(
                content: testHTML,
                rule: "data-id=\"(\\d+)\"",
                type: .regex
            )
            print("✅ 数据ID: \(dataIds)")
            
        } catch {
            print("❌ 正则表达式测试失败: \(error)")
        }
    }
    
    /// 测试统一分析器
    private func testUnifiedAnalyzer() {
        print("\n--- 测试统一分析器 ---")
        
        do {
            // 自动检测规则类型并解析
            let cssResult = try unifiedAnalyzer.analyze(
                content: testHTML,
                rule: ".book-item .title"
            )
            print("✅ CSS自动解析: \(cssResult)")
            
            let xpathResult = try unifiedAnalyzer.analyze(
                content: testHTML,
                rule: "//h3[@class='title']/text()"
            )
            print("✅ XPath自动解析: \(xpathResult)")
            
            let regexResult = try unifiedAnalyzer.analyze(
                content: testHTML,
                rule: "##data-id=\"(\\d+)\""
            )
            print("✅ 正则自动解析: \(regexResult)")
            
            // 测试URL处理
            let relativeUrls = ["/book/1", "/book/2", "https://example.com/book/3"]
            let absoluteUrls = unifiedAnalyzer.processUrls(relativeUrls, baseUrl: "https://example.com")
            print("✅ URL处理: \(absoluteUrls)")
            
        } catch {
            print("❌ 统一分析器测试失败: \(error)")
        }
    }
}

// MARK: - 便捷测试函数

/// 快速运行规则引擎测试
func runRuleEngineTests() {
    let tests = RuleEngineTests()
    tests.runAllTests()
}
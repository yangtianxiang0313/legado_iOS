# Legado iOS版本 - 最终技术方案

## 项目概述

基于开源Android阅读器Legado，开发功能完整的iOS版本，支持自定义书源、本地文件阅读、在线内容订阅等核心功能。

## 核心技术栈

### 架构模式
- **MVVM + Coordinator Pattern**
- **SwiftUI + Combine** (响应式编程)
- **依赖注入** (Protocol-based)

### 数据存储
- **SQLite + WCDB** (主数据库，腾讯开源高性能数据库框架)
  - 基于 SQLite 的高性能数据库框架
  - 支持 ORM 自动映射，简化数据库操作
  - 内置加密支持，保障数据安全
  - 优秀的性能表现和内存管理
  - 完善的多线程支持和事务处理
- **UserDefaults** (用户设置)
- **Keychain** (敏感数据)
- **FileManager** (本地文件管理)

### 网络层
- **URLSession** (原生网络框架)
- **自定义NetworkManager** (封装复杂逻辑)
- **Cookie自动管理**
- **智能重试机制**
- **反爬虫策略**

### HTML解析
- **SwiftSoup** (主要HTML解析，CSS选择器支持)
- **Fuzi** (XPath解析器，推荐首选)
- **libxml2** (系统级XPath支持，高性能场景)
- **JSONPath-Swift** (JSON路径解析)
- **JavaScriptCore** (JavaScript执行引擎)
- **正则表达式** (Swift Regex，辅助文本处理)

### 文件解析
- **自研EPUB解析器**
- **TXT编码检测与解析**
- **PDF基础支持**

### 测试框架
- **XCTest** (单元测试)
- **XCUITest** (UI自动化测试)
- **Quick + Nimble** (BDD测试)

### 国际化支持
- **SwiftUI Localization** (多语言UI)
- **NSLocalizedString** (文本本地化)
- **Locale-aware formatting** (日期、数字格式化)

### 数据导入导出
- **JSON序列化** (数据格式标准化)
- **文件系统操作** (备份文件管理)
- **iCloud同步** (跨设备数据同步)
- **AirDrop分享** (快速数据传输)

## 详细架构设计

### 1. 项目结构

```
Legado/
├── App/
│   ├── LegadoApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Database/
│   │   ├── WCDBManager.swift
│   │   ├── Models/
│   │   └── Migrations/
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   ├── BookSourceEngine.swift
│   │   └── RequestModels/
│   ├── Parser/
│   │   ├── HTMLParser.swift
│   │   ├── EPUBParser.swift
│   │   └── TXTParser.swift
│   └── Reader/
│       ├── ReaderEngine.swift
│       ├── TextRenderer.swift
│       └── PageCalculator.swift
├── Features/
│   ├── Bookshelf/
│   ├── Reader/
│   ├── BookSource/
│   ├── Discovery/
│   ├── Settings/
│   └── LocalFiles/
├── Shared/
│   ├── Extensions/
│   ├── Utils/
│   ├── Constants/
│   ├── Protocols/
│   └── Localization/
│       ├── LocalizationManager.swift
│       └── LocalizedStrings.swift
├── DataManager/
│   ├── ImportExportManager.swift
│   ├── BackupManager.swift
│   ├── SyncManager.swift
│   └── DataModels/
│       ├── ExportData.swift
│       └── ImportData.swift
└── Resources/
    ├── Assets.xcassets
    ├── Localizations/
    │   ├── en.lproj/
    │   │   └── Localizable.strings
    │   ├── zh-Hans.lproj/
    │   │   └── Localizable.strings
    │   ├── zh-Hant.lproj/
    │   │   └── Localizable.strings
    │   └── ja.lproj/
    │       └── Localizable.strings
    └── DefaultBookSources.json
```

### 2. 数据模型设计

#### 核心实体

```swift
// 书籍模型 (WCDB)
import WCDBSwift

class Book: TableCodable {
    var id: String = UUID().uuidString
    var title: String = ""
    var author: String = ""
    var coverURL: String?
    var bookSourceURL: String?
    var localPath: String?
    var lastReadChapter: Int = 0
    var lastReadPosition: Int = 0
    var addTime: Date = Date()
    var updateTime: Date = Date()
    var groupId: String?
    var tags: [String] = []
    var customCover: String?
    var readingProgress: Float = 0.0
    var totalChapters: Int = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Book
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case title
        case author
        case coverURL
        case bookSourceURL
        case localPath
        case lastReadChapter
        case lastReadPosition
        case addTime
        case updateTime
        case groupId
        case tags
        case customCover
        case readingProgress
        case totalChapters
    }
}

// 书源模型 (WCDB)
class BookSource: TableCodable {
    var id: String = UUID().uuidString
    var name: String = ""
    var baseURL: String = ""
    var searchRule: String = "" // JSON 字符串存储
    var chapterRule: String = "" // JSON 字符串存储
    var contentRule: String = "" // JSON 字符串存储
    var headers: String = "{}" // JSON 字符串存储
    var isEnabled: Bool = true
    var weight: Int = 0
    var lastUpdateTime: Date = Date()
    var customUserAgent: String?
    var enabledCookieJar: Bool = false
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = BookSource
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case name
        case baseURL
        case searchRule
        case chapterRule
        case contentRule
        case headers
        case isEnabled
        case weight
        case lastUpdateTime
        case customUserAgent
        case enabledCookieJar
    }
}

// 书籍分组模型
struct BookGroup: Codable {
    let id: String
    let name: String
    let order: Int
    let isDefault: Bool
    let createdTime: Date
}

// UI设置模型
struct UISettings: Codable {
    let theme: String
    let fontSize: Float
    let fontFamily: String
    let lineSpacing: Float
    let paragraphSpacing: Float
    let pageMargins: EdgeInsets
    let backgroundColor: String
    let textColor: String
    let isNightMode: Bool
    let pageAnimationType: String
    let statusBarStyle: String
}

// 完整导出数据模型
struct ExportData: Codable {
    let version: String
    let exportTime: Date
    let books: [Book]
    let bookSources: [BookSource]
    let bookGroups: [BookGroup]
    let uiSettings: UISettings
    let readingSettings: ReadingSettings
    let appSettings: AppSettings
    let bookmarks: [Bookmark]
    let readingNotes: [ReadingNote]
}

// 章节模型 (WCDB)
class Chapter: TableCodable {
    var id: String = UUID().uuidString
    var bookId: String = ""
    var title: String = ""
    var url: String?
    var chapterIndex: Int = 0 // 避免使用 index 关键字
    var content: String?
    var isDownloaded: Bool = false
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Chapter
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case bookId
        case title
        case url
        case chapterIndex
        case content
        case isDownloaded
        case createdAt
    }
}
```

### 3. 核心功能模块

#### 3.1 WCDB 数据库管理器

```swift
import WCDBSwift

class WCDBManager {
    static let shared = WCDBManager()
    private var database: Database?
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(documentsPath)/legado.db"
        
        do {
            database = Database(at: dbPath)
            createTables()
        } catch {
            print("数据库初始化失败: \(error)")
        }
    }
    
    private func createTables() {
        do {
            try database?.create(table: "books", of: Book.self)
            try database?.create(table: "chapters", of: Chapter.self)
            try database?.create(table: "book_sources", of: BookSource.self)
        } catch {
            print("创建表失败: \(error)")
        }
    }
    
    // MARK: - 书籍操作
    func insertBook(_ book: Book) throws {
        try database?.insert(book, intoTable: "books")
    }
    
    func getAllBooks() throws -> [Book] {
        return try database?.getObjects(fromTable: "books") ?? []
    }
    
    func updateBook(_ book: Book) throws {
        try database?.insertOrReplace(book, intoTable: "books")
    }
    
    func deleteBook(id: String) throws {
        try database?.delete(fromTable: "books", where: Book.Properties.id == id)
    }
    
    // MARK: - 章节操作
    func insertChapter(_ chapter: Chapter) throws {
        try database?.insert(chapter, intoTable: "chapters")
    }
    
    func getChapters(for bookId: String) throws -> [Chapter] {
        return try database?.getObjects(
            fromTable: "chapters",
            where: Chapter.Properties.bookId == bookId,
            orderBy: Chapter.Properties.chapterIndex.asOrder()
        ) ?? []
    }
    
    func deleteChapter(id: String) throws {
        try database?.delete(fromTable: "chapters", where: Chapter.Properties.id == id)
    }
    
    // MARK: - 书源操作
    func insertBookSource(_ source: BookSource) throws {
        try database?.insert(source, intoTable: "book_sources")
    }
    
    func getAllBookSources() throws -> [BookSource] {
        return try database?.getObjects(
            fromTable: "book_sources",
            where: BookSource.Properties.isEnabled == true,
            orderBy: BookSource.Properties.weight.asOrder(.descending)
        ) ?? []
    }
}
```

#### 3.2 书源引擎

##### 技术规划与选型

基于对Android Legado源码的深入分析和POP（Protocol-Oriented Programming）设计思路，为iOS版本制定完整的书源引擎技术方案。

###### Android版本核心组件分析

通过分析Android源码，发现其书源引擎主要由以下核心组件构成：

1. **AnalyzeRule** - 规则解析核心类，支持多种解析模式
2. **RuleAnalyzer** - 规则分析器，负责规则切分和平衡组处理
3. **多种解析器**：
   - AnalyzeByJSoup（HTML/XML解析）
   - AnalyzeByJSonPath（JSON解析）
   - AnalyzeByXPath（XPath解析）
   - AnalyzeByRegex（正则表达式解析）
4. **WebBook** - 书源业务逻辑封装

###### 关键技术特点

- 支持混合规则解析（JS、XPath、CSS选择器、JSONPath、正则）
- 智能规则类型检测和切换
- 规则缓存机制提升性能
- 平衡组解析处理复杂嵌套规则
- 协程支持异步处理

###### iOS版本POP设计方案

**1. 核心协议设计**

```swift
// 规则解析器协议
protocol RuleAnalyzing {
    func analyze(content: String, rule: String) throws -> [String]
    func analyzeFirst(content: String, rule: String) throws -> String?
    func analyzeElements(content: String, rule: String) throws -> [Any]
}

// 书源引擎协议
protocol BookSourceEngine {
    func searchBooks(query: String, page: Int) async throws -> [SearchBook]
    func getBookInfo(url: String) async throws -> Book
    func getChapterList(book: Book) async throws -> [Chapter]
    func getChapterContent(chapter: Chapter) async throws -> String
}

// 规则类型检测协议
protocol RuleTypeDetecting {
    func detectRuleType(_ rule: String) -> RuleType
    func isValidRule(_ rule: String, type: RuleType) -> Bool
}
```

**2. 解析器实现架构**

```swift
// 统一解析管理器
class UnifiedRuleAnalyzer: RuleAnalyzing {
    private let xpathAnalyzer: XPathAnalyzer
    private let jsoupAnalyzer: JSoupAnalyzer
    private let jsonPathAnalyzer: JSONPathAnalyzer
    private let regexAnalyzer: RegexAnalyzer
    private let jsAnalyzer: JSAnalyzer
    private let ruleDetector: RuleTypeDetecting
    
    // 智能路由到对应解析器
    func analyze(content: String, rule: String) throws -> [String] {
        let ruleType = ruleDetector.detectRuleType(rule)
        switch ruleType {
        case .xpath: return try xpathAnalyzer.analyze(content: content, rule: rule)
        case .jsoup: return try jsoupAnalyzer.analyze(content: content, rule: rule)
        case .jsonPath: return try jsonPathAnalyzer.analyze(content: content, rule: rule)
        case .regex: return try regexAnalyzer.analyze(content: content, rule: rule)
        case .javascript: return try jsAnalyzer.analyze(content: content, rule: rule)
        case .mixed: return try analyzeMixedRule(content: content, rule: rule)
        }
    }
}
```

**3. 技术选型建议**

*核心依赖库*
1. **HTML/XML解析**: SwiftSoup（Swift原生JSoup实现）
2. **XPath解析**: Fuzi（基于libxml2的Swift封装）
3. **JSON解析**: JSONPath-Swift
4. **正则表达式**: Foundation.NSRegularExpression
5. **JavaScript执行**: JavaScriptCore
6. **网络请求**: URLSession + Combine
7. **数据库**: WCDB.swift（与Android版本保持一致）

*性能优化策略*
1. **规则缓存**: 使用NSCache缓存编译后的规则
2. **异步处理**: 基于Swift Concurrency的async/await
3. **内存管理**: 弱引用避免循环引用
4. **批量处理**: 支持批量规则解析减少开销

**4. 实现优先级**

*Phase 1: 核心解析引擎*
- 实现基础的RuleAnalyzing协议
- 完成JSoup、XPath、JSONPath解析器
- 建立规则类型检测机制

*Phase 2: 高级功能*
- JavaScript执行环境集成
- 混合规则解析支持
- 规则缓存和性能优化

*Phase 3: 业务集成*
- BookSourceEngine协议实现
- 与现有BookSource模型集成
- 完整的书源测试和验证

**5. 兼容性考虑**

- **规则格式**: 完全兼容Android版本的规则格式
- **数据模型**: 保持BookSource数据结构一致性
- **解析行为**: 确保解析结果与Android版本一致
- **错误处理**: 统一的错误类型和处理机制

##### 具体实现架构

基于上述POP设计思路，iOS版本将采用以下具体架构设计：

##### 核心架构组件

```swift
// 主引擎类 - 对应Android的WebBook.kt，实现BookSourceEngine协议
class LegadoBookSourceEngine: BookSourceEngine {
    private let networkManager: NetworkManager
    private let ruleAnalyzer: UnifiedRuleAnalyzer
    private let wcdbManager = WCDBManager.shared
    private let ruleCache = NSCache<NSString, AnyObject>()
    
    init(networkManager: NetworkManager, ruleAnalyzer: UnifiedRuleAnalyzer) {
        self.networkManager = networkManager
        self.ruleAnalyzer = ruleAnalyzer
        setupRuleCache()
    }
    
    // MARK: - BookSourceEngine协议实现
    
    // 搜索书籍 - 对应searchBookAwait
    func searchBooks(query: String, page: Int) async throws -> [SearchBook] {
        // 实现搜索逻辑
    }
    
    // 获取书籍信息 - 对应getBookInfoAwait
    func getBookInfo(url: String) async throws -> Book {
        // 实现书籍信息获取逻辑
    }
    
    // 获取章节列表 - 对应getChapterListAwait
    func getChapterList(book: Book) async throws -> [Chapter] {
        // 实现章节列表获取逻辑
    }
    
    // 获取章节内容 - 对应getContentAwait
    func getChapterContent(chapter: Chapter) async throws -> String {
        // 实现章节内容获取逻辑
    }
    
    // MARK: - 扩展功能
    
    // 发现书籍 - 对应exploreBookAwait
    func explore(source: BookSource, url: String, page: Int = 1) async throws -> [SearchResult] {
        // 实现发现功能
    }
    
    // 验证书源
    func validateBookSource(_ source: BookSource) async -> Bool {
        // 实现书源验证逻辑
    }
    
    // 精确搜索 - 对应preciseSearch
    func preciseSearch(name: String, author: String, source: BookSource) async throws -> Book? {
        // 实现精确搜索逻辑
    }
    
    // MARK: - 私有方法
    
    private func setupRuleCache() {
        ruleCache.countLimit = 100
        ruleCache.totalCostLimit = 1024 * 1024 * 10 // 10MB
    }
    
    private func getCachedRule(key: String) -> Any? {
        return ruleCache.object(forKey: key as NSString)
    }
    
    private func cacheRule(key: String, value: Any) {
        ruleCache.setObject(value as AnyObject, forKey: key as NSString)
    }
}

// 规则分析器 - 对应Android的AnalyzeRule.kt，实现RuleAnalyzing协议
class RuleAnalyzer: RuleAnalyzing {
    private let unifiedAnalyzer: UnifiedRuleAnalyzer
    
    init(unifiedAnalyzer: UnifiedRuleAnalyzer) {
        self.unifiedAnalyzer = unifiedAnalyzer
    }
    
    // MARK: - RuleAnalyzing协议实现
    
    func analyze(content: String, rule: String) throws -> [String] {
        return try unifiedAnalyzer.analyze(content: content, rule: rule)
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try unifiedAnalyzer.analyzeFirst(content: content, rule: rule)
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        return try unifiedAnalyzer.analyzeElements(content: content, rule: rule)
    }
    
    // MARK: - 扩展功能
    
    // 带基础URL的解析接口
    func analyze(content: String, rule: String, baseUrl: String? = nil) throws -> [String] {
        // 处理baseUrl逻辑后调用基础解析方法
        return try analyze(content: content, rule: rule)
    }
    
    func analyzeFirst(content: String, rule: String, baseUrl: String? = nil) throws -> String? {
        // 处理baseUrl逻辑后调用基础解析方法
        return try analyzeFirst(content: content, rule: rule)
    }
}

// 各类解析器实现 - 都实现RuleAnalyzing协议
import Fuzi
import SwiftSoup
import JavaScriptCore

class XPathAnalyzer: RuleAnalyzing {
    // MARK: - RuleAnalyzing协议实现
    func analyze(content: String, rule: String) throws -> [String] {
        let elements = try analyzeElements(content: content, rule: rule)
        return elements.compactMap { ($0 as? XMLElement)?.stringValue }
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try analyze(content: content, rule: rule).first
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        let document = try XMLDocument(string: content)
        let nodes = try document.xpath(rule)
        return nodes
    }
    
    // MARK: - XPath特有功能
    func getAttribute(rule: String, attribute: String, content: String) throws -> String? {
        // 实现属性获取逻辑
        return nil
    }
}

class JSoupAnalyzer: RuleAnalyzing {
    // MARK: - RuleAnalyzing协议实现
    func analyze(content: String, rule: String) throws -> [String] {
        let elements = try analyzeElements(content: content, rule: rule)
        return elements.compactMap { ($0 as? Element)?.text() }
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try analyze(content: content, rule: rule).first
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        let document = try SwiftSoup.parse(content)
        let elements = try document.select(rule)
        return elements.array()
    }
    
    // MARK: - JSoup特有功能
    func getAttribute(rule: String, attribute: String, content: String) throws -> String? {
        // 实现属性获取逻辑
        return nil
    }
}

class JSONPathAnalyzer: RuleAnalyzing {
    // MARK: - RuleAnalyzing协议实现
    func analyze(content: String, rule: String) throws -> [String] {
        let result = try analyzeAny(content: content, rule: rule)
        if let array = result as? [Any] {
            return array.compactMap { String(describing: $0) }
        } else if let single = result {
            return [String(describing: single)]
        }
        return []
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try analyze(content: content, rule: rule).first
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        let result = try analyzeAny(content: content, rule: rule)
        if let array = result as? [Any] {
            return array
        } else if let single = result {
            return [single]
        }
        return []
    }
    
    // MARK: - JSONPath特有功能
    func analyzeAny(content: String, rule: String) throws -> Any? {
        // 实现JSONPath解析逻辑
        return nil
    }
}

class RegexAnalyzer: RuleAnalyzing {
    // MARK: - RuleAnalyzing协议实现
    func analyze(content: String, rule: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: rule)
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            return String(content[range])
        }
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try analyze(content: content, rule: rule).first
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        return try analyze(content: content, rule: rule)
    }
    
    // MARK: - 正则表达式特有功能
    func replace(content: String, pattern: String, replacement: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            return regex.stringByReplacingMatches(in: content, range: NSRange(content.startIndex..., in: content), withTemplate: replacement)
        } catch {
            return content
        }
    }
    
    func matches(rule: String, content: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: rule)
            return regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) != nil
        } catch {
            return false
        }
    }
}

class JSAnalyzer: RuleAnalyzing {
    private let jsContext: JSContext
    
    init() {
        self.jsContext = JSContext()
        setupJSEnvironment()
    }
    
    // MARK: - RuleAnalyzing协议实现
    func analyze(content: String, rule: String) throws -> [String] {
        let result = try evaluate(script: rule, content: content)
        if let array = result as? [Any] {
            return array.compactMap { String(describing: $0) }
        } else if let single = result {
            return [String(describing: single)]
        }
        return []
    }
    
    func analyzeFirst(content: String, rule: String) throws -> String? {
        return try analyze(content: content, rule: rule).first
    }
    
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        let result = try evaluate(script: rule, content: content)
        if let array = result as? [Any] {
            return array
        } else if let single = result {
            return [single]
        }
        return []
    }
    
    // MARK: - JavaScript特有功能
    func evaluate(script: String, content: String) throws -> Any? {
        jsContext.setObject(content, forKeyedSubscript: "content" as NSString)
        let result = jsContext.evaluateScript(script)
        return result?.toObject()
    }
    
    func evaluateString(script: String, content: String) throws -> String? {
        let result = try evaluate(script: script, content: content)
        return result as? String
    }
    
    private func setupJSEnvironment() {
        // 设置JavaScript执行环境
        jsContext.exceptionHandler = { context, exception in
            print("JS Exception: \(exception?.toString() ?? "Unknown error")")
        }
    }
}
```

##### 规则类型检测与枚举

```swift
// 规则类型枚举
enum RuleType: String, CaseIterable {
    case xpath = "xpath"
    case jsoup = "jsoup"
    case jsonPath = "jsonPath"
    case regex = "regex"
    case javascript = "javascript"
    case mixed = "mixed"
    
    var description: String {
        switch self {
        case .xpath: return "XPath表达式"
        case .jsoup: return "CSS选择器"
        case .jsonPath: return "JSONPath表达式"
        case .regex: return "正则表达式"
        case .javascript: return "JavaScript脚本"
        case .mixed: return "混合规则"
        }
    }
}

// 规则类型检测器实现
class RuleTypeDetector: RuleTypeDetecting {
    func detectRuleType(_ rule: String) -> RuleType {
        let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // JavaScript规则检测
        if trimmedRule.hasPrefix("@js:") || trimmedRule.contains("function") || trimmedRule.contains("=>") {
            return .javascript
        }
        
        // JSONPath规则检测
        if trimmedRule.hasPrefix("$.") || trimmedRule.hasPrefix("@.") {
            return .jsonPath
        }
        
        // XPath规则检测
        if trimmedRule.hasPrefix("//") || trimmedRule.hasPrefix("/") || trimmedRule.contains("[@") {
            return .xpath
        }
        
        // 正则表达式检测
        if trimmedRule.hasPrefix("##") || (trimmedRule.hasPrefix("^") && trimmedRule.hasSuffix("$")) {
            return .regex
        }
        
        // 混合规则检测
        if trimmedRule.contains("&&") || trimmedRule.contains("||") || trimmedRule.contains("@js:") {
            return .mixed
        }
        
        // 默认为JSoup CSS选择器
        return .jsoup
    }
    
    func isValidRule(_ rule: String, type: RuleType) -> Bool {
        let detectedType = detectRuleType(rule)
        return detectedType == type || detectedType == .mixed
    }
    
    // 规则预处理
    func preprocessRule(_ rule: String) -> String {
        var processedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 移除规则前缀
        if processedRule.hasPrefix("@js:") {
            processedRule = String(processedRule.dropFirst(4))
        } else if processedRule.hasPrefix("##") {
            processedRule = String(processedRule.dropFirst(2))
        }
        
        return processedRule
    }
}
```

##### 规则数据模型

```swift
// 对应Android的各种Rule类
struct SearchRule: Codable {
    var checkKeyWord: String?
    var bookList: String?
    var name: String?
    var author: String?
    var intro: String?
    var kind: String?
    var lastChapter: String?
    var updateTime: String?
    var bookUrl: String?
    var coverUrl: String?
    var wordCount: String?
}

struct ContentRule: Codable {
    var content: String?
    var title: String?
    var nextContentUrl: String?
    var webJs: String?
    var sourceRegex: String?
    var replaceRegex: String?
    var imageStyle: String?
    var imageDecode: String?
    var payAction: String?
}

struct BookInfoRule: Codable {
    var init: String?
    var name: String?
    var author: String?
    var intro: String?
    var kind: String?
    var lastChapter: String?
    var updateTime: String?
    var coverUrl: String?
    var tocUrl: String?
    var wordCount: String?
    var canReName: String?
    var downloadUrls: String?
}

struct TocRule: Codable {
    var chapterList: String?
    var chapterName: String?
    var chapterUrl: String?
    var isVolume: String?
    var updateTime: String?
    var isVip: String?
    var isPay: String?
}

enum RuleType {
    case xpath
    case jsoup
    case jsonPath
    case regex
    case javascript
    case mixed
}
```

#### 3.4 多语言管理器

```swift
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .system
    
    enum Language: String, CaseIterable {
        case system = "system"
        case english = "en"
        case simplifiedChinese = "zh-Hans"
        case traditionalChinese = "zh-Hant"
        case japanese = "ja"
        
        var displayName: String {
            switch self {
            case .system: return NSLocalizedString("system_language", comment: "")
            case .english: return "English"
            case .simplifiedChinese: return "简体中文"
            case .traditionalChinese: return "繁體中文"
            case .japanese: return "日本語"
            }
        }
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        // 触发UI重新加载
    }
    
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
```

#### 3.5 数据导入导出管理器

```swift
class ImportExportManager {
    private let databaseManager: WCDBManager
    private let fileManager = FileManager.default
    
    // 导出所有数据
    func exportAllData() async throws -> URL {
        let exportData = ExportData(
            version: Bundle.main.appVersion,
            exportTime: Date(),
            books: try await databaseManager.getAllBooks(),
            bookSources: try await databaseManager.getAllBookSources(),
            bookGroups: try await databaseManager.getAllBookGroups(),
            uiSettings: SettingsManager.shared.uiSettings,
            readingSettings: SettingsManager.shared.readingSettings,
            appSettings: SettingsManager.shared.appSettings,
            bookmarks: try await databaseManager.getAllBookmarks(),
            readingNotes: try await databaseManager.getAllReadingNotes()
        )
        
        let jsonData = try JSONEncoder().encode(exportData)
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsPath.appendingPathComponent("legado_backup_\(Date().timestamp).json")
        
        try jsonData.write(to: exportURL)
        return exportURL
    }
    
    // 导入数据
    func importData(from url: URL) async throws {
        let jsonData = try Data(contentsOf: url)
        let importData = try JSONDecoder().decode(ExportData.self, from: jsonData)
        
        // 验证数据版本兼容性
        try validateDataVersion(importData.version)
        
        // 导入数据到数据库
        try await databaseManager.importBooks(importData.books)
        try await databaseManager.importBookSources(importData.bookSources)
        try await databaseManager.importBookGroups(importData.bookGroups)
        try await databaseManager.importBookmarks(importData.bookmarks)
        try await databaseManager.importReadingNotes(importData.readingNotes)
        
        // 导入设置
        SettingsManager.shared.importUISettings(importData.uiSettings)
        SettingsManager.shared.importReadingSettings(importData.readingSettings)
        SettingsManager.shared.importAppSettings(importData.appSettings)
    }
    
    // 选择性导出
    func exportSelectedData(
        includeBooks: Bool = true,
        includeBookSources: Bool = true,
        includeSettings: Bool = true,
        includeBookmarks: Bool = true
    ) async throws -> URL {
        // 根据选择导出特定数据
    }
    
    // iCloud同步
    func syncToiCloud() async throws {
        let exportURL = try await exportAllData()
        try await CloudKitManager.shared.uploadBackup(exportURL)
    }
    
    // 从iCloud恢复
    func restoreFromiCloud() async throws {
        let backupURL = try await CloudKitManager.shared.downloadLatestBackup()
        try await importData(from: backupURL)
    }
}
```

#### 3.2 阅读引擎

```swift
class ReaderEngine {
    private let textRenderer: TextRenderer
    private let pageCalculator: PageCalculator
    
    func renderPage(content: String, config: ReadingConfig) -> PageContent
    func calculatePages(content: String, config: ReadingConfig) -> [PageInfo]
    func getReadingProgress(currentPage: Int, totalPages: Int) -> Float
}
```

#### 3.3 网络管理器

```swift
class NetworkManager {
    private let session: URLSession
    private let cookieManager: CookieManager
    
    func request<T: Codable>(_ request: NetworkRequest) async throws -> T
    func downloadFile(from url: URL, to destination: URL) async throws
    func setCookies(_ cookies: [HTTPCookie], for url: URL)
    func getUserAgent(for source: BookSource) -> String
}
```

### 4. UI层设计

#### 4.1 主要视图

```swift
// 主界面
struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var localizationManager = LocalizationManager()
    
    var body: some View {
        TabView {
            BookshelfView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text(localizationManager.localizedString(for: "bookshelf"))
                }
            DiscoveryView()
                .tabItem {
                    Image(systemName: "safari")
                    Text(localizationManager.localizedString(for: "discovery"))
                }
            LocalFilesView()
                .tabItem {
                    Image(systemName: "folder")
                    Text(localizationManager.localizedString(for: "local_files"))
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(localizationManager.localizedString(for: "settings"))
                }
        }
        .environmentObject(coordinator)
        .environmentObject(localizationManager)
    }
}

// 阅读界面
struct ReaderView: View {
    @StateObject private var viewModel: ReaderViewModel
    
    var body: some View {
        GeometryReader { geometry in
            PageView(pages: viewModel.pages)
                .gesture(tapGesture)
                .overlay(menuOverlay)
        }
    }
}
```

#### 4.2 ViewModel示例

```swift
class BookshelfViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookRepository: BookRepository
    private let bookSourceEngine: BookSourceEngine
    
    func loadBooks() async {
        // 实现书架加载逻辑
    }
    
    func refreshBook(_ book: Book) async {
        // 实现书籍更新逻辑
    }
}
```

## 关键技术实现

### 1. 多语言支持实现

#### 1.1 本地化文件结构
```
Resources/Localizations/
├── en.lproj/
│   └── Localizable.strings
├── zh-Hans.lproj/
│   └── Localizable.strings
├── zh-Hant.lproj/
│   └── Localizable.strings
└── ja.lproj/
    └── Localizable.strings
```

#### 1.2 本地化字符串示例
```swift
// en.lproj/Localizable.strings
"bookshelf" = "Bookshelf";
"discovery" = "Discovery";
"local_files" = "Local Files";
"settings" = "Settings";
"reading_progress" = "Reading Progress";
"chapter_list" = "Chapter List";
"book_sources" = "Book Sources";
"import_export" = "Import/Export";

// zh-Hans.lproj/Localizable.strings
"bookshelf" = "书架";
"discovery" = "发现";
"local_files" = "本地文件";
"settings" = "设置";
"reading_progress" = "阅读进度";
"chapter_list" = "章节列表";
"book_sources" = "书源";
"import_export" = "导入导出";
```

#### 1.3 动态语言切换
```swift
struct LanguageSettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        List {
            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                HStack {
                    Text(language.displayName)
                    Spacer()
                    if localizationManager.currentLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    localizationManager.setLanguage(language)
                }
            }
        }
        .navigationTitle(localizationManager.localizedString(for: "language_settings"))
    }
}
```

### 2. 数据导入导出实现

#### 2.1 导出功能界面
```swift
struct ImportExportView: View {
    @StateObject private var importExportManager = ImportExportManager()
    @State private var showingExportOptions = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    
    var body: some View {
        List {
            Section("export_data") {
                Button("export_all_data") {
                    Task {
                        do {
                            exportURL = try await importExportManager.exportAllData()
                            showingExportOptions = true
                        } catch {
                            // 处理错误
                        }
                    }
                }
                
                Button("selective_export") {
                    // 显示选择性导出界面
                }
            }
            
            Section("import_data") {
                Button("import_from_file") {
                    showingImportPicker = true
                }
                
                Button("restore_from_icloud") {
                    Task {
                        try await importExportManager.restoreFromiCloud()
                    }
                }
            }
            
            Section("sync_settings") {
                Button("sync_to_icloud") {
                    Task {
                        try await importExportManager.syncToiCloud()
                    }
                }
                
                Toggle("auto_backup", isOn: .constant(true))
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Task {
                        try await importExportManager.importData(from: url)
                    }
                }
            case .failure(let error):
                print("Import failed: \(error)")
            }
        }
    }
}
```

#### 2.2 数据版本兼容性处理
```swift
extension ImportExportManager {
    private func validateDataVersion(_ version: String) throws {
        let currentVersion = Bundle.main.appVersion
        let importVersion = SemanticVersion(version)
        let currentSemanticVersion = SemanticVersion(currentVersion)
        
        // 检查版本兼容性
        if importVersion.major > currentSemanticVersion.major {
            throw ImportError.incompatibleVersion("Data from newer version")
        }
        
        // 处理版本迁移
        if importVersion.major < currentSemanticVersion.major {
            // 执行数据迁移逻辑
        }
    }
    
    private func migrateDataIfNeeded(_ data: inout ExportData) {
        // 根据版本差异执行数据迁移
        // 例如：添加新字段的默认值，转换旧格式等
    }
}
```

### 3. 书源规则解析

```swift
struct SearchRule {
    let searchURL: String
    let method: HTTPMethod
    let charset: String
    let bookList: String
    let name: String
    let author: String
    let coverURL: String
    let detailURL: String
}

class RuleParser {
    func parseSearchRule(_ rule: String, html: String) -> [SearchResult]
    func parseContentRule(_ rule: String, html: String) -> String?
    func parseBookInfoRule(_ rule: String, html: String) -> BookInfo?
    func parseTocRule(_ rule: String, html: String) -> [Chapter]
    private func detectRuleType(_ rule: String) -> RuleType
}
```

### 2. 文本渲染引擎

```swift
class TextRenderer {
    func renderText(
        _ text: String,
        config: ReadingConfig,
        bounds: CGRect
    ) -> NSAttributedString {
        // 使用Core Text进行高性能文本渲染
        // 支持自定义字体、行间距、段落间距
        // 实现文字阴影、描边等效果
    }
}
```

### 3. 缓存策略

```swift
class CacheManager {
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let diskCache: DiskCache
    
    func cacheChapterContent(_ content: String, for chapterId: String)
    func getCachedContent(for chapterId: String) -> String?
    func clearExpiredCache()
}
```

## 开发计划

### 阶段1：项目基础搭建 (2-3周)
- [x] 项目初始化和基础架构
- [x] WCDB数据库设计和实现
- [ ] 基础网络层封装
- [x] 核心数据模型定义 (支持WCDB TableCodable)
- [ ] 基础UI框架搭建

### 阶段2：核心功能开发 (4-5周)
- [ ] 书源引擎实现
- [ ] HTML解析器集成
- [ ] 搜索功能实现
- [ ] 章节列表获取
- [ ] 内容解析和缓存

### 阶段3：阅读器开发 (4-5周)
- [ ] 文本渲染引擎
- [ ] 翻页动画和手势
- [ ] 阅读设置界面
- [ ] 书签和笔记功能
- [ ] 阅读进度同步

### 阶段4：本地文件支持 (2-3周)
- [ ] EPUB解析器
- [ ] TXT文件处理
- [ ] 文件导入功能
- [ ] 本地书库管理

### 阶段5：高级功能 (3-4周)
- [ ] 订阅功能
- [ ] 替换净化
- [ ] 主题和样式
- [ ] 多语言支持实现
- [ ] 数据导入导出功能
- [ ] iCloud同步集成
- [ ] 书籍分组管理
- [ ] 书签和笔记系统

### 阶段6：测试和优化 (2-3周)
- [ ] 单元测试覆盖
- [ ] UI自动化测试
- [ ] 多语言测试
- [ ] 导入导出功能测试
- [ ] iCloud同步测试
- [ ] 性能优化
- [ ] Bug修复

## 测试策略

### 单元测试
- 数据模型测试
- 网络层测试
- 解析器测试
- 业务逻辑测试

### 集成测试
- 书源引擎集成测试
- 数据库操作测试
- 文件解析测试

### UI测试
- 关键用户流程测试
- 界面交互测试
- 性能测试

### 自动化测试
```swift
class BookSourceEngineTests: XCTestCase {
    func testSearchBooks() async throws {
        let engine = BookSourceEngine()
        let results = await engine.search(keyword: "测试", sources: mockSources)
        XCTAssertFalse(results.isEmpty)
    }
}

class ImportExportTests: XCTestCase {
    func testDataExportImport() async throws {
        let manager = ImportExportManager()
        
        // 测试导出
        let exportURL = try await manager.exportAllData()
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))
        
        // 测试导入
        try await manager.importData(from: exportURL)
        
        // 验证数据完整性
        let importedBooks = try await WCDBManager.shared.getAllBooks()
        XCTAssertFalse(importedBooks.isEmpty)
    }
    
    func testLocalization() {
        let manager = LocalizationManager()
        
        // 测试不同语言
        manager.setLanguage(.english)
        XCTAssertEqual(manager.localizedString(for: "bookshelf"), "Bookshelf")
        
        manager.setLanguage(.simplifiedChinese)
        XCTAssertEqual(manager.localizedString(for: "bookshelf"), "书架")
    }
}
```

## 性能优化

### 1. 内存管理
- 图片懒加载和缓存
- 章节内容分页加载
- 及时释放不需要的资源

### 2. 网络优化
- 请求合并和批处理
- 智能重试机制
- 连接池管理

### 3. 渲染优化
- 文本预渲染
- 页面缓存机制
- 异步渲染

### 4. 存储优化
- 数据库索引优化
- 文件压缩存储
- 定期清理缓存

## 安全考虑

### 1. 网络安全
- HTTPS强制使用
- 证书验证
- 请求签名

### 2. 数据安全
- 敏感数据加密
- 沙盒隔离
- 权限最小化

### 3. 书源安全
- 恶意代码检测
- 资源访问限制
- 执行时间限制

## 发布策略

### 1. 版本规划
- v1.0: 基础阅读功能
- v1.1: 书源管理优化
- v1.2: 高级阅读功能
- v2.0: 完整功能对标Android版

### 2. 分发渠道
- App Store (主要)
- TestFlight (测试)
- 企业分发 (内测)

## 风险评估与应对

### 技术风险
- **书源兼容性**：建立测试书源库，持续验证
- **性能问题**：早期性能测试，及时优化
- **iOS版本兼容**：支持iOS 15+，向下兼容

### 业务风险
- **版权问题**：明确免责声明，用户自负责任
- **App Store审核**：避免内置书源，用户自行添加

## 总结

本技术方案基于iOS原生技术栈，采用现代化的架构模式，确保应用的性能、可维护性和扩展性。特别选择了腾讯开源的 WCDB 作为数据库框架，相比传统的 SQLite.swift 具有以下优势：

### WCDB 技术优势
- **高性能**：针对移动端优化，读写性能显著提升
- **ORM 支持**：自动对象关系映射，减少样板代码
- **类型安全**：编译时检查，避免运行时错误
- **多线程安全**：内置线程安全机制，支持并发操作
- **数据加密**：内置 SQLCipher 支持，保障数据安全
- **内存优化**：智能缓存和内存管理，降低内存占用
- **易于维护**：清晰的 API 设计，降低学习成本

通过合理的技术选型和详细的开发计划，预计在14-18周内完成一个功能完整、性能优秀的Legado iOS版本。

**预计开发周期：16-20周**  
**团队规模：1人（全栈开发）**  
**技术难度：中高**  
**成功概率：高**

### 新增功能说明

#### 多语言支持
- **支持语言**：英语、简体中文、繁体中文、日语
- **动态切换**：无需重启应用即可切换语言
- **本地化内容**：UI文本、错误信息、日期格式、数字格式
- **RTL支持**：为未来支持阿拉伯语等RTL语言预留接口

#### 完整数据导入导出
- **导出内容**：书籍信息、书源配置、UI设置、阅读设置、书签笔记、分组信息
- **导出格式**：JSON格式，便于跨平台兼容
- **选择性导出**：用户可选择导出特定类型的数据
- **版本兼容**：支持不同版本间的数据迁移
- **云端同步**：集成iCloud自动备份和同步
- **分享功能**：支持AirDrop、邮件等方式分享备份文件

#### 数据安全保障
- **数据校验**：导入时验证数据完整性和格式正确性
- **增量备份**：只备份变更的数据，提高效率
- **加密存储**：敏感数据采用AES加密存储
- **恢复机制**：导入失败时自动回滚到之前状态

---

*最后更新：2025年6月23日*
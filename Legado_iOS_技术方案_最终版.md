# Legado iOS版本 - 最终技术方案

## 项目概述

基于开源Android阅读器Legado，开发功能完整的iOS版本，支持自定义书源、本地文件阅读、在线内容订阅等核心功能。

## 核心技术栈

### 架构模式
- **MVVM + Coordinator Pattern**
- **SwiftUI + Combine** (响应式编程)
- **依赖注入** (Protocol-based)

### 数据存储
- **SQLite + SQLite.swift** (主数据库)
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
- **SwiftSoup** (主要HTML解析)
- **WebKit** (JavaScript执行，按需使用)
- **正则表达式** (辅助文本处理)

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
│   │   ├── SQLiteManager.swift
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
// 书籍模型
struct Book: Codable {
    let id: String
    let title: String
    let author: String
    let coverURL: String?
    let bookSourceURL: String?
    let localPath: String?
    let lastReadChapter: Int
    let lastReadPosition: Int
    let addTime: Date
    let updateTime: Date
    let groupId: String?
    let tags: [String]
    let customCover: String?
    let readingProgress: Float
    let totalChapters: Int
}

// 书源模型
struct BookSource: Codable {
    let id: String
    let name: String
    let baseURL: String
    let searchRule: SearchRule
    let chapterRule: ChapterRule
    let contentRule: ContentRule
    let headers: [String: String]
    let isEnabled: Bool
    let weight: Int
    let lastUpdateTime: Date
    let customUserAgent: String?
    let enabledCookieJar: Bool
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

// 章节模型
struct Chapter {
    let id: String
    let bookId: String
    let title: String
    let url: String?
    let index: Int
    let content: String?
    let isDownloaded: Bool
}
```

### 3. 核心功能模块

#### 3.1 书源引擎

```swift
class BookSourceEngine {
    private let networkManager: NetworkManager
    private let htmlParser: HTMLParser
    
    func search(keyword: String, sources: [BookSource]) async -> [SearchResult]
    func getChapterList(book: Book) async -> [Chapter]
    func getChapterContent(chapter: Chapter) async -> String
    func validateBookSource(_ source: BookSource) async -> Bool
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
    private let databaseManager: SQLiteManager
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
    func parseSearchRule(_ rule: String, html: String) -> [SearchResult] {
        // 使用SwiftSoup解析HTML
        // 支持CSS选择器、XPath、正则表达式
    }
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
- [ ] SQLite数据库设计和实现
- [ ] 基础网络层封装
- [ ] 核心数据模型定义
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
        let importedBooks = try await SQLiteManager.shared.getAllBooks()
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

本技术方案基于iOS原生技术栈，采用现代化的架构模式，确保应用的性能、可维护性和扩展性。通过合理的技术选型和详细的开发计划，预计在14-18周内完成一个功能完整、性能优秀的Legado iOS版本。

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
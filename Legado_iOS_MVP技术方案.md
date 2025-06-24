# Legado iOS - MVP技术方案

**文档创建时间**：2025年6月23日  
**最后更新时间**：2025年6月23日

## 项目概述

基于开源Android阅读器Legado，采用MVP（最小可行产品）开发策略，分阶段实现iOS版本。优先实现核心阅读功能，后续迭代添加高级特性。

## MVP开发策略

### 核心理念
- **快速验证**：优先实现最核心的阅读功能
- **迭代开发**：分阶段添加功能，每个版本都是可用的完整产品
- **用户反馈驱动**：基于用户反馈决定后续功能优先级
- **技术债务控制**：在快速开发和代码质量间找到平衡

## 技术栈选择

### 核心技术
- **SwiftUI + Combine**：现代化UI框架，快速开发
- **SQLite.swift**：轻量级数据存储
- **SwiftSoup**：HTML解析
- **URLSession**：网络请求

### 架构模式
- **MVVM**：简化的架构，适合快速开发
- **Repository Pattern**：数据访问层抽象
- **Dependency Injection**：基于Protocol的依赖注入

## MVP版本规划

### MVP v1.0 - 基础阅读器 (4-5周)
**目标**：实现最基本的在线阅读功能

#### 核心功能
1. **书源管理**
   - 添加/删除书源
   - 书源列表显示
   - 基础书源验证

2. **图书搜索**
   - 关键词搜索
   - 搜索结果列表
   - 图书详情页

3. **基础阅读**
   - 章节列表
   - 文本阅读界面
   - 简单翻页（点击翻页）
   - 阅读进度保存

4. **书架管理**
   - 添加图书到书架
   - 书架列表显示
   - 删除图书

#### 技术实现
```swift
// 核心数据模型
struct Book: Codable, Identifiable {
    let id: String
    let title: String
    let author: String
    var coverUrl: String?
    let bookUrl: String
    var tocUrl: String?
    var lastChapter: String?
    var latestChapterTime: Date?
    var lastCheckTime: Date?
    let totalChapterNum: Int
    var durChapterIndex: Int
    var durChapterPos: Int
    var durChapterTime: Date?
    let durChapterTitle: String
    let canUpdate: Bool
    let order: Int
    let originName: String
    let origin: String
    let wordCount: String
    let kind: String
    let variable: String
}

struct BookSource: Codable, Identifiable {
    let id: String
    let name: String
    let baseURL: String
    let searchRule: String
    let chapterRule: String
    let contentRule: String
    let isEnabled: Bool
}

struct Chapter: Codable, Identifiable {
    let id: String
    let bookId: String
    let title: String
    let url: String
    let index: Int
    var content: String?
    let baseUrl: String
}
```

#### 项目结构
```
legado/
├── App/
│   └── legadoApp.swift
├── Models/
│   ├── Book.swift
│   ├── BookSource.swift
│   └── Chapter.swift
├── Views/
│   ├── ContentView.swift
│   ├── BookshelfView.swift
│   ├── SearchView.swift
│   └── ReaderView.swift
├── ViewModels/
│   ├── BookshelfViewModel.swift
│   ├── SearchViewModel.swift
│   └── ReaderViewModel.swift
├── Managers/
│   ├── DataManager.swift
│   ├── NetworkManager.swift
│   └── BookSourceEngine.swift
└── Extensions/
    └── SwiftUIExtensions.swift
```

### MVP v1.1 - 阅读体验优化 (2-3周)
**目标**：提升基础阅读体验

#### 新增功能
1. **阅读设置**
   - 字体大小调节
   - 背景色切换
   - 亮度调节

2. **翻页优化**
   - 滑动翻页
   - 翻页动画
   - 手势支持

3. **内容缓存**
   - 章节内容缓存
   - 离线阅读支持

4. **界面优化**
   - 加载状态显示
   - 错误处理优化
   - 用户体验改进

### MVP v1.2 - 本地文件支持 (2-3周)
**目标**：支持本地文件阅读

#### 新增功能
1. **文件导入**
   - TXT文件支持
   - 文件选择器
   - 编码检测

2. **本地书库**
   - 本地文件管理
   - 文件格式识别
   - 阅读进度同步

### MVP v1.3 - 用户体验增强 (2-3周)
**目标**：完善用户体验

#### 新增功能
1. **书签功能**
   - 添加/删除书签
   - 书签列表
   - 快速跳转

2. **搜索优化**
   - 搜索历史
   - 热门搜索
   - 搜索建议

3. **界面主题**
   - 日间/夜间模式
   - 多种主题色

### MVP v2.0 - 高级功能 (3-4周)
**目标**：添加高级特性

#### 新增功能
1. **多语言支持**
   - 中英文界面
   - 动态语言切换
   - 本地化字符串

2. **数据同步**
   - 数据导出/导入
   - 基础云同步

3. **EPUB支持**
   - EPUB文件解析
   - 图文混排

4. **高级阅读**
   - 阅读笔记
   - 文字选择
   - 复制分享

## 当前开发进度

### 已完成功能 ✅
1. **项目基础架构**
   - SwiftUI项目搭建
   - 基础数据模型定义
   - MVVM架构实现

2. **核心数据模型**
   - Book模型（已优化，支持可选属性）
   - Chapter模型
   - 数据模型类型安全优化

3. **书架功能**
   - 书架列表显示
   - 阅读进度显示
   - 基础书籍信息展示

4. **设置界面**
   - 基础设置页面
   - 语言选择功能
   - 关于页面

5. **本地化系统**
   - LocalizedKey枚举定义
   - LocalizationManager实现
   - SwiftUI扩展支持
   - 迁移到原生LocalizedStringKey

6. **数据管理**
   - DataManager基础实现
   - 示例数据生成

### 正在开发 🚧
1. **书源引擎**
   - 网络请求封装
   - HTML解析集成
   - 书源规则解析

2. **搜索功能**
   - 搜索界面设计
   - 搜索结果展示

### 待开发 📋
1. **阅读器核心**
   - 文本渲染引擎
   - 翻页逻辑
   - 阅读界面

2. **章节管理**
   - 章节列表获取
   - 内容解析
   - 缓存机制

3. **网络层完善**
   - 错误处理
   - 重试机制
   - Cookie管理

## 技术实现细节

### 数据存储策略
```swift
// 简化的数据管理器
class DataManager: ObservableObject {
    @Published var books: [Book] = []
    @Published var bookSources: [BookSource] = []
    
    // MVP阶段使用内存存储，后续迁移到SQLite
    func addBook(_ book: Book) {
        books.append(book)
    }
    
    func removeBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
    }
    
    // 后续版本添加持久化
    func saveToDatabase() {
        // SQLite存储实现
    }
}
```

### 网络层设计
```swift
// 简化的网络管理器
class NetworkManager {
    private let session = URLSession.shared
    
    func fetchHTML(from url: String) async throws -> String {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
```

### 书源引擎设计
```swift
// MVP版本的书源引擎
class BookSourceEngine {
    private let networkManager = NetworkManager()
    
    func search(keyword: String, source: BookSource) async throws -> [Book] {
        // 简化的搜索实现
        let html = try await networkManager.fetchHTML(from: source.baseURL)
        return parseSearchResults(html: html, rule: source.searchRule)
    }
    
    private func parseSearchResults(html: String, rule: String) -> [Book] {
        // 基础HTML解析
        // 后续版本完善规则引擎
        return []
    }
}
```

## 开发里程碑

### 第1阶段：MVP v1.0 基础功能 (当前)
- **时间**：4-5周
- **目标**：可用的基础阅读器
- **验收标准**：
  - 能够添加书源
  - 能够搜索和添加图书
  - 能够阅读章节内容
  - 能够保存阅读进度

### 第2阶段：体验优化
- **时间**：2-3周
- **目标**：提升用户体验
- **验收标准**：
  - 流畅的翻页体验
  - 个性化阅读设置
  - 稳定的离线阅读

### 第3阶段：功能扩展
- **时间**：2-3周
- **目标**：支持本地文件
- **验收标准**：
  - 支持TXT文件导入
  - 本地文件管理
  - 统一的阅读体验

### 第4阶段：高级特性
- **时间**：3-4周
- **目标**：完整功能集
- **验收标准**：
  - 多语言支持
  - 数据同步功能
  - EPUB文件支持

## 风险控制

### 技术风险
1. **书源兼容性**
   - 风险：不同书源规则差异大
   - 应对：先支持主流书源，逐步扩展

2. **性能问题**
   - 风险：大文本渲染性能
   - 应对：分页加载，异步渲染

3. **网络稳定性**
   - 风险：网络请求失败
   - 应对：重试机制，错误提示

### 产品风险
1. **用户接受度**
   - 风险：功能不满足用户需求
   - 应对：快速迭代，用户反馈驱动

2. **竞品压力**
   - 风险：其他阅读器功能更完善
   - 应对：专注核心体验，差异化竞争

## 成功指标

### MVP v1.0 成功指标
- [ ] 能够成功添加至少3个主流书源
- [ ] 搜索成功率 > 80%
- [ ] 章节加载成功率 > 90%
- [ ] 应用崩溃率 < 1%
- [ ] 用户留存率 > 60%（7天）

### 后续版本指标
- [ ] 支持文件格式数量
- [ ] 用户活跃度
- [ ] 功能使用率
- [ ] 用户满意度评分

## 总结

采用MVP开发策略，我们能够：

1. **快速验证产品价值**：尽早发布可用版本，获取用户反馈
2. **降低开发风险**：分阶段开发，每个阶段都有明确目标
3. **灵活调整方向**：基于用户反馈调整功能优先级
4. **控制技术债务**：在快速开发和代码质量间找到平衡

**预计MVP v1.0完成时间：4-5周**  
**完整功能版本时间：12-15周**  
**开发人员：1人**  
**成功概率：高**

---

*创建时间：2025年6月23日*  
*最后更新：2025年6月23日*
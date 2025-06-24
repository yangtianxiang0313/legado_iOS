import Foundation
import WCDBSwift

// MARK: - 书源数据模型
final class BookSource: TableModel {
    static let tableName = "book_sources"
    var id: String = UUID().uuidString
    
    // MARK: - 基本信息
    var bookSourceUrl: String = ""           // 书源URL
    var bookSourceName: String = ""          // 书源名称
    var bookSourceGroup: String?        // 书源分组
    var bookSourceComment: String?      // 书源说明
    var loginUrl: String?               // 登录地址
    var loginUi: String?                // 登录UI
    var loginCheckJs: String?           // 登录检测js
    var bookSourceType: Int = 0             // 书源类型: 0-文本, 1-音频, 2-图片, 3-文件
    var bookUrlPattern: String?         // 书籍URL正则
    var customOrder: Int = 0                // 自定义排序
    var enabled: Bool = true                   // 是否启用
    var enabledExplore: Bool = true            // 是否启用发现
    var enabledCookieJar: Bool?         // 是否启用CookieJar
    var concurrentRate: String?         // 并发率
    var header: String?                 // 请求头
    var jsLib: String?                  // js库
    var variableComment: String?        // 变量说明
    var coverDecodeJs: String?          // 封面解码js
    var exploreScreen: String?          // 发现界面
    var lastUpdateTime: Int64 = 0       // 最后更新时间
    var respondTime: Int64 = 180000     // 响应时间
    var weight: Int = 0                 // 权重
    
    // 发现规则
    var exploreUrl: String?             // 发现URL
    var ruleExplore: ExploreRule?       // 发现规则
    
    // 搜索规则
    var searchUrl: String?              // 搜索URL
    var ruleSearch: SearchRule?         // 搜索规则
    
    // 书籍信息规则
    var ruleBookInfo: BookInfoRule?     // 书籍信息规则
    
    // 目录规则
    var ruleToc: TocRule?               // 目录规则
    
    // 正文规则
    var ruleContent: ContentRule?       // 正文规则
    
    // 评论规则
    var ruleReview: ReviewRule?         // 评论规则
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = BookSource
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case bookSourceUrl, bookSourceName, bookSourceGroup, bookSourceComment
        case loginUrl, loginUi, loginCheckJs
        case bookSourceType, bookUrlPattern, customOrder, enabled, enabledExplore
        case enabledCookieJar, concurrentRate, header, jsLib, variableComment
        case coverDecodeJs, exploreScreen
        case lastUpdateTime, respondTime, weight
        case exploreUrl, ruleExplore, searchUrl, ruleSearch
        case ruleBookInfo, ruleToc, ruleContent, ruleReview
    }
    
    // MARK: - Hashable实现
    func hash(into hasher: inout Hasher) {
        hasher.combine(bookSourceUrl)
    }
    
    static func == (lhs: BookSource, rhs: BookSource) -> Bool {
        return lhs.bookSourceUrl == rhs.bookSourceUrl
    }
    
    // MARK: - 便利初始化器
    convenience init(bookSourceUrl: String, bookSourceName: String) {
        self.init()
        self.bookSourceUrl = bookSourceUrl
        self.bookSourceName = bookSourceName
    }
    
    // MARK: - WCDB JSON转换支持
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    // 规则对象转JSON字符串
    func encodeRuleToJSON<T: Codable>(_ rule: T?) -> String? {
        guard let rule = rule else { return nil }
        do {
            let data = try BookSource.jsonEncoder.encode(rule)
            return String(data: data, encoding: .utf8)
        } catch {
            print("规则编码失败: \(error)")
            return nil
        }
    }
    
    // JSON字符串转规则对象
    func decodeRuleFromJSON<T: Codable>(_ jsonString: String?, type: T.Type) -> T? {
        guard let jsonString = jsonString,
              let data = jsonString.data(using: .utf8) else { return nil }
        do {
            return try BookSource.jsonDecoder.decode(type, from: data)
        } catch {
            print("规则解码失败: \(error)")
            return nil
        }
    }
}

// MARK: - 发现规则
struct ExploreRule: Codable {
    var bookList: String?               // 书籍列表规则
    var name: String?                   // 书名规则
    var author: String?                 // 作者规则
    var intro: String?                  // 简介规则
    var kind: String?                   // 分类规则
    var lastChapter: String?            // 最新章节规则
    var updateTime: String?             // 更新时间规则
    var bookUrl: String?                // 书籍URL规则
    var coverUrl: String?               // 封面URL规则
    var wordCount: String?              // 字数规则
}

// MARK: - 搜索规则
struct SearchRule: Codable {
    var checkKeyWord: String?           // 校验关键字规则
    var bookList: String?               // 书籍列表规则
    var name: String?                   // 书名规则
    var author: String?                 // 作者规则
    var intro: String?                  // 简介规则
    var kind: String?                   // 分类规则
    var lastChapter: String?            // 最新章节规则
    var updateTime: String?             // 更新时间规则
    var bookUrl: String?                // 书籍URL规则
    var coverUrl: String?               // 封面URL规则
    var wordCount: String?              // 字数规则
}

// MARK: - 书籍信息规则
struct BookInfoRule: Codable {
    var `init`: String?                   // 预处理规则
    var name: String?                   // 书名规则
    var author: String?                 // 作者规则
    var intro: String?                  // 简介规则
    var kind: String?                   // 分类规则
    var lastChapter: String?            // 最新章节规则
    var updateTime: String?             // 更新时间规则
    var coverUrl: String?               // 封面URL规则
    var tocUrl: String?                 // 目录URL规则
    var wordCount: String?              // 字数规则
    var canReName: String?              // 允许修改书名规则
    var downloadUrls: String?           // 下载链接规则
}

// MARK: - 目录规则
struct TocRule: Codable {
    var preUpdateJs: String?            // 目录预处理JS
    var chapterList: String?            // 章节列表规则
    var chapterName: String?            // 章节名称规则
    var chapterUrl: String?             // 章节URL规则
    var isVolume: String?               // 是否为卷规则
    var updateTime: String?             // 更新时间规则
    var isVip: String?                  // 是否VIP章节规则
    var isPay: String?                  // 是否付费章节规则
}

// MARK: - 正文规则
struct ContentRule: Codable {
    var content: String?                // 正文规则
    var nextContentUrl: String?         // 下一页URL规则
    var webJs: String?                  // 网页JS
    var sourceRegex: String?            // 资源正则
    var replaceRegex: String?           // 替换正则
    var imageStyle: String?             // 图片样式
    var imageDecode: String?            // 图片解码
    var payAction: String?              // 购买操作
}

// MARK: - 评论规则
struct ReviewRule: Codable {
    var reviewUrl: String?              // 评论URL规则
    var avatarRule: String?             // 头像规则
    var dateRule: String?               // 日期规则
    var starRule: String?               // 星级规则
    var reviewRule: String?             // 评论内容规则
}

// MARK: - 书源扩展方法
extension BookSource {
    // 获取解析后的请求头
    func getHeaders() -> [String: String] {
        guard let headerString = header,
              let data = headerString.data(using: .utf8),
              let headers = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return [:]
        }
        return headers
    }
    
    // 检查书源是否有效
    func isValid() -> Bool {
        return !bookSourceUrl.isEmpty && !bookSourceName.isEmpty && isValidURL(bookSourceUrl)
    }
    
    // 验证URL格式
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
    
    // 获取书源类型描述
    func getTypeDescription() -> String {
        switch bookSourceType {
        case 0:
            return "文本"
        case 1:
            return "音频"
        case 2:
            return "图片"
        case 3:
            return "文件"
        default:
            return "未知"
        }
    }
    
    // 检查是否支持搜索
    func canSearch() -> Bool {
        return searchUrl != nil && ruleSearch != nil
    }
    
    // 检查是否支持发现
    func canExplore() -> Bool {
        return exploreUrl != nil && ruleExplore != nil && enabledExplore
    }
    
    // 获取显示名称（包含分组）
    func getDisplayNameGroup() -> String {
        if let group = bookSourceGroup, !group.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(bookSourceName) (\(group))"
        } else {
            return bookSourceName
        }
    }
    
    // 添加分组
    func addGroup(_ groups: String) {
        let newGroups = groups.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        if let existingGroup = bookSourceGroup {
            let existingGroups = existingGroup.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let allGroups = Set(existingGroups + newGroups)
            bookSourceGroup = Array(allGroups).filter { !$0.isEmpty }.joined(separator: ",")
        } else {
            bookSourceGroup = newGroups.filter { !$0.isEmpty }.joined(separator: ",")
        }
    }
    
    // 移除分组
    func removeGroup(_ groups: String) {
        guard let existingGroup = bookSourceGroup else { return }
        
        let groupsToRemove = Set(groups.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        let existingGroups = existingGroup.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let remainingGroups = existingGroups.filter { !groupsToRemove.contains($0) && !$0.isEmpty }
        
        bookSourceGroup = remainingGroups.isEmpty ? nil : remainingGroups.joined(separator: ",")
    }
    
    // 检查是否包含指定分组
    func hasGroup(_ group: String) -> Bool {
        guard let existingGroup = bookSourceGroup else { return false }
        let groups = existingGroup.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return groups.contains(group)
    }
    
    // 获取搜索规则（懒加载）
    func getSearchRule() -> SearchRule {
        return ruleSearch ?? SearchRule()
    }
    
    // 获取发现规则（懒加载）
    func getExploreRule() -> ExploreRule {
        return ruleExplore ?? ExploreRule()
    }
    
    // 获取书籍信息规则（懒加载）
    func getBookInfoRule() -> BookInfoRule {
        return ruleBookInfo ?? BookInfoRule()
    }
    
    // 获取目录规则（懒加载）
    func getTocRule() -> TocRule {
        return ruleToc ?? TocRule()
    }
    
    // 获取正文规则（懒加载）
    func getContentRule() -> ContentRule {
        return ruleContent ?? ContentRule()
    }
    
    // 获取评论规则（懒加载）
    func getReviewRule() -> ReviewRule {
        return ruleReview ?? ReviewRule()
    }
    
    // 添加错误注释
    func addErrorComment(_ error: Error) {
        let errorMessage = "// Error: \(error.localizedDescription)"
        if let existingComment = bookSourceComment, !existingComment.isEmpty {
            bookSourceComment = "\(errorMessage)\n\n\(existingComment)"
        } else {
            bookSourceComment = errorMessage
        }
    }
    
    // 移除错误注释
    func removeErrorComment() {
        guard let comment = bookSourceComment else { return }
        let lines = comment.components(separatedBy: "\n\n")
        let filteredLines = lines.filter { !$0.hasPrefix("// Error: ") }
        bookSourceComment = filteredLines.isEmpty ? nil : filteredLines.joined(separator: "\n")
    }
    
    // 获取检查关键字
    func getCheckKeyword(default defaultKeyword: String) -> String {
        if let keyword = ruleSearch?.checkKeyWord, !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return keyword
        }
        return defaultKeyword
    }
    
    // 获取变量注释显示
    func getDisplayVariableComment(otherComment: String) -> String {
        if let varComment = variableComment, !varComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(varComment)\n\(otherComment)"
        } else {
            return otherComment
        }
    }
}

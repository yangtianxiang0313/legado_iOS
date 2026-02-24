//
//  UrlPlaceholder.swift
//  legado
//
//  URL 占位符替换，对应 Android AnalyzeUrl.replaceKeyPageJs
//  book-source-rules §7
//

import Foundation

enum UrlPlaceholder {

    /// 将 searchKey、exploreKey、page 等占位符替换为实际值
    /// - Parameters:
    ///   - url: 含占位符的 URL，如 `https://x.com/search?key={{key}}&page={{page}}`
    ///   - key: 搜索关键字，对应 {{key}}
    ///   - page: 页码，对应 {{page}} 或 <1,2,3> 列表
    ///   - exploreKey: 发现分类 key，对应 {{exploreKey}}
    /// - Returns: 替换后的 URL
    static func replacePlaceholders(
        in url: String,
        key: String? = nil,
        page: Int? = nil,
        exploreKey: String? = nil
    ) -> String {
        var result = url

        // {{key}} → 搜索关键字
        result = result.replacingOccurrences(of: "{{key}}", with: key ?? "")

        // {{exploreKey}} → 发现分类
        result = result.replacingOccurrences(of: "{{exploreKey}}", with: exploreKey ?? "")

        // <1,2,3> 页码列表：page=1→"1", page=2→"2", page≥size→最后一项
        if let p = page, p > 0 {
            let pattern = #/<([^>]+)>/#
            while let match = result.firstMatch(of: pattern) {
                let list = String(match.1).split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let idx = min(p - 1, list.count - 1)
                let replacement = idx >= 0 ? list[idx] : ""
                result.replaceSubrange(match.range, with: replacement)
            }
        }

        // {{page}} → 页码（数字）
        let pageStr = page.map { String($0) } ?? "0"
        result = result.replacingOccurrences(of: "{{page}}", with: pageStr)

        return result
    }
}

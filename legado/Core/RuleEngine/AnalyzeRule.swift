//
//  AnalyzeRule.swift
//  legado
//
//  规则主入口，根据前缀选择 CSS 或 JSONPath 解析
//  对应 Android AnalyzeRule.getString/getStringList, book-source-rules §1-4
//

import Foundation

enum AnalyzeRule {

    /// 使用规则从 content 中提取字符串
    /// - Parameters:
    ///   - content: HTML 或 JSON 字符串
    ///   - rule: 规则，支持 @css:、$.、@Json: 等前缀；`||` 链取第一个非空
    /// - Returns: 提取结果，空则返回 ""
    static func getString(content: Any, rule: String) -> String {
        guard !rule.trimmingCharacters(in: .whitespaces).isEmpty else { return "" }
        let segments = RuleParser.splitRule(rule).map(\.rule)
        let contentStr = String(describing: content)

        for segment in segments {
            let trimmed = segment.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let result: String?
            if isJSONPathRule(trimmed) {
                result = SextantAnalyzer.evaluate(json: contentStr, path: trimmed)
            } else {
                result = try? SwiftSoupAnalyzer.evaluate(html: contentStr, rule: trimmed)
            }
            if let r = result, !r.isEmpty {
                return r
            }
        }
        return ""
    }

    /// 使用规则从 content 中提取字符串列表
    static func getStringList(content: Any, rule: String) -> [String]? {
        guard !rule.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        let segments = RuleParser.splitRule(rule).map(\.rule)
        let contentStr = String(describing: content)

        for segment in segments {
            let trimmed = segment.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let result: [String]?
            if isJSONPathRule(trimmed) {
                result = SextantAnalyzer.evaluateList(json: contentStr, path: trimmed)
            } else {
                result = try? SwiftSoupAnalyzer.evaluateList(html: contentStr, rule: trimmed)
            }
            if let r = result, !r.isEmpty {
                return r
            }
        }
        return nil
    }

    private static func isJSONPathRule(_ rule: String) -> Bool {
        let r = rule.trimmingCharacters(in: .whitespaces)
        return r.uppercased().hasPrefix("@JSON:") || r.hasPrefix("$.") || r.hasPrefix("$[")
    }
}

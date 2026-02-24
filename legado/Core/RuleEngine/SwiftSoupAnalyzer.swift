//
//  SwiftSoupAnalyzer.swift
//  legado
//
//  CSS 规则解析，对应 Android AnalyzeByJSoup
//  book-source-rules §1-2, ios-book-source-rules §1
//

import Foundation
import SwiftSoup

enum SwiftSoupAnalyzer {

    /// 使用 CSS 规则从 HTML 中提取内容
    /// - Parameters:
    ///   - html: HTML 字符串
    ///   - rule: 规则，支持 `@css:selector@mode` 或 `selector@mode`；可含 `##正则##替换` 净化
    /// - Returns: 第一个匹配结果；多结果用 \n 连接
    static func evaluate(html: String, rule: String) throws -> String? {
        let list = try evaluateList(html: html, rule: rule)
        guard let list, !list.isEmpty else { return nil }
        return list.joined(separator: "\n")
    }

    /// 使用 CSS 规则从 HTML 中提取内容列表
    static func evaluateList(html: String, rule: String) throws -> [String]? {
        let ruleStr = rule.trimmingCharacters(in: .whitespaces)
        guard !ruleStr.isEmpty else { return nil }

        // 去掉 @css: 或 @CSS: 前缀（大小写不敏感）
        var trimmed = ruleStr
        if ruleStr.uppercased().hasPrefix("@CSS:") {
            trimmed = String(ruleStr.dropFirst(5)).trimmingCharacters(in: .whitespaces)
        }

        // 解析 ##正则##替换 净化（在规则末尾，格式 ##regex##replacement）
        let (selectorPart, purifyRegex, purifyReplacement): (String, String?, String?) = {
            guard let first = trimmed.range(of: "##") else { return (trimmed, nil, nil) }
            let before = String(trimmed[..<first.lowerBound]).trimmingCharacters(in: .whitespaces)
            let afterFirst = trimmed[first.upperBound...]
            guard let second = afterFirst.range(of: "##") else { return (trimmed, nil, nil) }
            let regex = String(afterFirst[..<second.lowerBound])
            let replacement = String(afterFirst[second.upperBound...])
            return (before, regex.isEmpty ? nil : regex, regex.isEmpty ? nil : replacement)
        }()

        // selector@mode：最后一个 @ 分隔选择器和获取方式
        let selector: String
        let mode: String
        if let lastAt = selectorPart.lastIndex(of: "@") {
            selector = String(selectorPart[..<lastAt]).trimmingCharacters(in: .whitespaces)
            mode = String(selectorPart[selectorPart.index(after: lastAt)...]).trimmingCharacters(in: .whitespaces)
        } else {
            selector = selectorPart
            mode = "text"
        }

        guard !selector.isEmpty else { return nil }

        let doc = try SwiftSoup.parse(html)
        let elements = try doc.select(selector)
        guard !elements.isEmpty() else { return nil }

        var results: [String] = []
        for i in 0..<elements.size() {
            let el = elements.get(i)
            let value: String
            switch mode.lowercased() {
            case "text":
                value = try el.text()
            case "owntext":
                value = try el.ownText()
            case "html":
                try el.select("script").remove()
                try el.select("style").remove()
                value = try el.outerHtml()
            case "all":
                value = try el.outerHtml()
            default:
                value = try el.attr(mode)
            }
            if !value.isEmpty, !results.contains(value) {
                results.append(value)
            }
        }

        guard !results.isEmpty else { return nil }

        // 应用 ##正则##替换 净化
        if let regexStr = purifyRegex, let regex = try? NSRegularExpression(pattern: regexStr) {
            results = results.map { str in
                let range = NSRange(str.startIndex..., in: str)
                return regex.stringByReplacingMatches(
                    in: str,
                    range: range,
                    withTemplate: purifyReplacement ?? ""
                )
            }
        }

        return results
    }
}

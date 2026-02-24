//
//  SextantAnalyzer.swift
//  legado
//
//  JSONPath 规则解析，对应 Android AnalyzeByJSonPath
//  book-source-rules §1, ios-book-source-rules §1
//

import Foundation
import Sextant

enum SextantAnalyzer {

    /// 使用 JSONPath 从 JSON 中提取内容
    /// - Parameters:
    ///   - json: JSON 字符串
    ///   - path: JSONPath，如 `$.data.name`；支持 `@Json:` 前缀（会去掉）
    /// - Returns: 第一个匹配结果；多结果用 \n 连接
    static func evaluate(json: String, path: String) -> String? {
        let pathStr = normalizePath(path)
        guard let p = pathStr else { return nil }
        return json.query(string: p)
    }

    /// 使用 JSONPath 从 JSON 中提取内容列表
    static func evaluateList(json: String, path: String) -> [String]? {
        let pathStr = normalizePath(path)
        guard let p = pathStr else { return nil }
        guard let results = json.query(values: p) else { return nil }
        guard !results.isEmpty else { return nil }

        return results.map { value -> String in
            if let s = value as? String { return s }
            if let n = value as? Int { return String(n) }
            if let n = value as? Double { return String(n) }
            if let b = value as? Bool { return String(b) }
            return String(describing: value)
        }
    }

    private static func normalizePath(_ path: String) -> String? {
        var pathStr = path.trimmingCharacters(in: .whitespaces)
        guard !pathStr.isEmpty else { return nil }
        if pathStr.uppercased().hasPrefix("@JSON:") {
            pathStr = String(pathStr.dropFirst(6)).trimmingCharacters(in: .whitespaces)
        }
        guard pathStr.hasPrefix("$") else { return nil }
        return pathStr
    }
}

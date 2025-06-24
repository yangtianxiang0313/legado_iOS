//
//  RuleType.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 规则类型枚举
enum RuleType: String, CaseIterable, Codable {
    case xpath = "xpath"
    case jsoup = "jsoup"
    case jsonPath = "jsonPath"
    case regex = "regex"
    case javascript = "javascript"
    case mixed = "mixed"
    
    /// 规则类型的中文描述
    var description: String {
        switch self {
        case .xpath:
            return "XPath表达式"
        case .jsoup:
            return "CSS选择器"
        case .jsonPath:
            return "JSONPath表达式"
        case .regex:
            return "正则表达式"
        case .javascript:
            return "JavaScript脚本"
        case .mixed:
            return "混合规则"
        }
    }
    
    /// 规则类型的图标名称
    var iconName: String {
        switch self {
        case .xpath:
            return "doc.text.magnifyingglass"
        case .jsoup:
            return "text.magnifyingglass"
        case .jsonPath:
            return "curlybraces"
        case .regex:
            return "textformat.alt"
        case .javascript:
            return "chevron.left.forwardslash.chevron.right"
        case .mixed:
            return "gearshape.2"
        }
    }
    
    /// 是否支持属性提取
    var supportsAttributes: Bool {
        switch self {
        case .xpath, .jsoup:
            return true
        case .jsonPath, .regex, .javascript, .mixed:
            return false
        }
    }
}

/// 规则解析错误类型
enum RuleAnalyzeError: LocalizedError {
    case invalidRule(String)
    case parseError(String)
    case unsupportedRuleType(RuleType)
    case contentEmpty
    case ruleEmpty
    
    var errorDescription: String? {
        switch self {
        case .invalidRule(let rule):
            return "无效的规则: \(rule)"
        case .parseError(let message):
            return "解析错误: \(message)"
        case .unsupportedRuleType(let type):
            return "不支持的规则类型: \(type.description)"
        case .contentEmpty:
            return "内容为空"
        case .ruleEmpty:
            return "规则为空"
        }
    }
}
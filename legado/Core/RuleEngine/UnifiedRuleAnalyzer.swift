//
//  UnifiedRuleAnalyzer.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 统一规则分析器 - 协调不同类型的解析器
class UnifiedRuleAnalyzer {
    
    // MARK: - Properties
    
    private let ruleTypeDetector: RuleTypeDetecting
    private let jsoupAnalyzer: JSoupAnalyzer
    private let xpathAnalyzer: XPathAnalyzer
    private let regexAnalyzer: RegexAnalyzer
    
    // MARK: - Initialization
    
    init(ruleTypeDetector: RuleTypeDetecting = RuleTypeDetector()) {
        self.ruleTypeDetector = ruleTypeDetector
        self.jsoupAnalyzer = JSoupAnalyzer()
        self.xpathAnalyzer = XPathAnalyzer()
        self.regexAnalyzer = RegexAnalyzer()
    }
    
    // MARK: - Public Methods
    
    /// 智能解析规则并返回结果数组
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - baseUrl: 基础URL（可选）
    /// - Returns: 解析结果数组
    func analyze(content: String, rule: String, baseUrl: String? = nil) throws -> [String] {
        let preprocessedRule = ruleTypeDetector.preprocessRule(rule)
        let ruleType = ruleTypeDetector.detectRuleType(preprocessedRule)
        
        return try analyzeWithType(content: content, rule: preprocessedRule, type: ruleType, baseUrl: baseUrl)
    }
    
    /// 智能解析规则并返回第一个结果
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - baseUrl: 基础URL（可选）
    /// - Returns: 第一个解析结果
    func analyzeFirst(content: String, rule: String, baseUrl: String? = nil) throws -> String? {
        let results = try analyze(content: content, rule: rule, baseUrl: baseUrl)
        return results.first
    }
    
    /// 智能解析规则并返回元素数组
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - baseUrl: 基础URL（可选）
    /// - Returns: 元素数组
    func analyzeElements(content: String, rule: String, baseUrl: String? = nil) throws -> [Any] {
        let preprocessedRule = ruleTypeDetector.preprocessRule(rule)
        let ruleType = ruleTypeDetector.detectRuleType(preprocessedRule)
        
        return try analyzeElementsWithType(content: content, rule: preprocessedRule, type: ruleType, baseUrl: baseUrl)
    }
    
    /// 指定类型解析规则
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - type: 规则类型
    ///   - baseUrl: 基础URL（可选）
    /// - Returns: 解析结果数组
    func analyzeWithType(content: String, rule: String, type: RuleType, baseUrl: String? = nil) throws -> [String] {
        switch type {
        case .jsoup:
            return try jsoupAnalyzer.analyze(content: content, rule: rule)
        case .xpath:
            return try xpathAnalyzer.analyze(content: content, rule: rule)
        case .regex:
            return try regexAnalyzer.analyze(content: content, rule: rule)
        case .jsonPath:
            // TODO: 实现JSONPath解析器
            throw RuleAnalyzeError.unsupportedRuleType(type)
        case .javascript:
            // TODO: 实现JavaScript解析器
            throw RuleAnalyzeError.unsupportedRuleType(type)
        case .mixed:
            // TODO: 实现混合规则解析
            throw RuleAnalyzeError.unsupportedRuleType(type)
        }
    }
    
    /// 指定类型解析元素
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - type: 规则类型
    ///   - baseUrl: 基础URL（可选）
    /// - Returns: 元素数组
    func analyzeElementsWithType(content: String, rule: String, type: RuleType, baseUrl: String? = nil) throws -> [Any] {
        switch type {
        case .jsoup:
            return try jsoupAnalyzer.analyzeElements(content: content, rule: rule)
        case .xpath:
            return try xpathAnalyzer.analyzeElements(content: content, rule: rule)
        case .regex:
            return try regexAnalyzer.analyzeElements(content: content, rule: rule)
        case .jsonPath:
            // TODO: 实现JSONPath解析器
            throw RuleAnalyzeError.unsupportedRuleType(type)
        case .javascript:
            // TODO: 实现JavaScript解析器
            throw RuleAnalyzeError.unsupportedRuleType(type)
        case .mixed:
            // TODO: 实现混合规则解析
            throw RuleAnalyzeError.unsupportedRuleType(type)
        }
    }
    
    /// 获取属性值（仅支持JSoup和XPath）
    /// - Parameters:
    ///   - content: 内容字符串
    ///   - rule: 规则字符串
    ///   - attribute: 属性名
    /// - Returns: 属性值数组
    func getAttributes(content: String, rule: String, attribute: String) throws -> [String] {
        let preprocessedRule = ruleTypeDetector.preprocessRule(rule)
        let ruleType = ruleTypeDetector.detectRuleType(preprocessedRule)
        
        switch ruleType {
        case .jsoup:
            return try jsoupAnalyzer.getAttributes(content: content, rule: preprocessedRule, attribute: attribute)
        case .xpath:
            return try xpathAnalyzer.getAttributes(content: content, rule: preprocessedRule, attribute: attribute)
        default:
            throw RuleAnalyzeError.unsupportedRuleType(ruleType)
        }
    }
    
    /// 检测规则类型
    /// - Parameter rule: 规则字符串
    /// - Returns: 检测到的规则类型
    func detectRuleType(_ rule: String) -> RuleType {
        return ruleTypeDetector.detectRuleType(rule)
    }
    
    /// 验证规则是否有效
    /// - Parameters:
    ///   - rule: 规则字符串
    ///   - type: 期望的规则类型
    /// - Returns: 规则是否有效
    func isValidRule(_ rule: String, type: RuleType) -> Bool {
        return ruleTypeDetector.isValidRule(rule, type: type)
    }
}

// MARK: - URL处理扩展
extension UnifiedRuleAnalyzer {
    
    /// 处理相对URL转绝对URL
    /// - Parameters:
    ///   - urls: URL数组
    ///   - baseUrl: 基础URL
    /// - Returns: 处理后的URL数组
    func processUrls(_ urls: [String], baseUrl: String?) -> [String] {
        guard let baseUrl = baseUrl, let base = URL(string: baseUrl) else {
            return urls
        }
        
        return urls.compactMap { urlString in
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                return urlString
            } else {
                return URL(string: urlString, relativeTo: base)?.absoluteString
            }
        }
    }
}

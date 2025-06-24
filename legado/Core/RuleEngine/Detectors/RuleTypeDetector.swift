//
//  RuleTypeDetector.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 规则类型检测器实现
class RuleTypeDetector: RuleTypeDetecting {
    
    /// 检测规则类型
    /// - Parameter rule: 规则字符串
    /// - Returns: 检测到的规则类型
    func detectRuleType(_ rule: String) -> RuleType {
        let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 空规则检查
        guard !trimmedRule.isEmpty else {
            return .jsoup // 默认类型
        }
        
        // JavaScript规则检测
        if isJavaScriptRule(trimmedRule) {
            return .javascript
        }
        
        // JSONPath规则检测
        if isJSONPathRule(trimmedRule) {
            return .jsonPath
        }
        
        // XPath规则检测
        if isXPathRule(trimmedRule) {
            return .xpath
        }
        
        // 正则表达式检测
        if isRegexRule(trimmedRule) {
            return .regex
        }
        
        // 混合规则检测
        if isMixedRule(trimmedRule) {
            return .mixed
        }
        
        // 默认为JSoup CSS选择器
        return .jsoup
    }
    
    /// 验证规则是否有效
    /// - Parameters:
    ///   - rule: 规则字符串
    ///   - type: 期望的规则类型
    /// - Returns: 规则是否有效
    func isValidRule(_ rule: String, type: RuleType) -> Bool {
        let detectedType = detectRuleType(rule)
        return detectedType == type || detectedType == .mixed
    }
    
    /// 规则预处理 - 移除前缀等
    /// - Parameter rule: 原始规则
    /// - Returns: 处理后的规则
    func preprocessRule(_ rule: String) -> String {
        var processedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 移除JavaScript前缀
        if processedRule.hasPrefix("@js:") {
            processedRule = String(processedRule.dropFirst(4))
        }
        
        // 移除正则表达式前缀
        if processedRule.hasPrefix("##") {
            processedRule = String(processedRule.dropFirst(2))
        }
        
        return processedRule.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Private Methods
private extension RuleTypeDetector {
    
    /// 检测是否为JavaScript规则
    func isJavaScriptRule(_ rule: String) -> Bool {
        return rule.hasPrefix("@js:") ||
               rule.contains("function") ||
               rule.contains("=>") ||
               rule.contains("var ") ||
               rule.contains("let ") ||
               rule.contains("const ")
    }
    
    /// 检测是否为JSONPath规则
    func isJSONPathRule(_ rule: String) -> Bool {
        return rule.hasPrefix("$.") ||
               rule.hasPrefix("@.") ||
               rule.contains("$[") ||
               rule.contains("@[")
    }
    
    /// 检测是否为XPath规则
    func isXPathRule(_ rule: String) -> Bool {
        return rule.hasPrefix("//") ||
               rule.hasPrefix("/") ||
               rule.contains("[@") ||
               rule.contains("text()") ||
               rule.contains("node()") ||
               rule.contains("position()")
    }
    
    /// 检测是否为正则表达式规则
    func isRegexRule(_ rule: String) -> Bool {
        return rule.hasPrefix("##") ||
               (rule.hasPrefix("^") && rule.hasSuffix("$")) ||
               rule.contains("\\d") ||
               rule.contains("\\w") ||
               rule.contains("\\s")
    }
    
    /// 检测是否为混合规则
    func isMixedRule(_ rule: String) -> Bool {
        return rule.contains("&&") ||
               rule.contains("||") ||
               rule.contains("@js:") ||
               rule.contains("##") ||
               (rule.contains("$.") && rule.contains("//"))
    }
}
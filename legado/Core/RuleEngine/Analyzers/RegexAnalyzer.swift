//
//  RegexAnalyzer.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 正则表达式解析器
class RegexAnalyzer: RuleAnalyzing {
    
    // MARK: - RuleAnalyzing协议实现
    
    /// 解析正则表达式并返回匹配结果数组
    func analyze(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        let processedRule = preprocessRegexRule(rule)
        
        do {
            let regex = try NSRegularExpression(pattern: processedRule, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            return matches.compactMap { match in
                extractMatchResult(from: content, match: match)
            }.filter { !$0.isEmpty }
        } catch {
            throw RuleAnalyzeError.parseError("正则表达式解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 解析正则表达式并返回第一个匹配结果
    func analyzeFirst(content: String, rule: String) throws -> String? {
        let results = try analyze(content: content, rule: rule)
        return results.first
    }
    
    /// 解析正则表达式并返回NSTextCheckingResult数组
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        let processedRule = preprocessRegexRule(rule)
        
        do {
            let regex = try NSRegularExpression(pattern: processedRule, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            return matches
        } catch {
            throw RuleAnalyzeError.parseError("正则表达式元素解析失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - 正则表达式特有功能扩展
extension RegexAnalyzer {
    
    /// 获取指定分组的匹配结果
    /// - Parameters:
    ///   - content: 文本内容
    ///   - rule: 正则表达式规则
    ///   - groupIndex: 分组索引（0为整个匹配，1为第一个分组）
    /// - Returns: 分组匹配结果数组
    func getGroups(content: String, rule: String, groupIndex: Int = 1) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        let processedRule = preprocessRegexRule(rule)
        
        do {
            let regex = try NSRegularExpression(pattern: processedRule, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            return matches.compactMap { match in
                guard groupIndex < match.numberOfRanges else { return nil }
                let range = match.range(at: groupIndex)
                guard range.location != NSNotFound else { return nil }
                return String(content[Range(range, in: content)!])
            }.filter { !$0.isEmpty }
        } catch {
            throw RuleAnalyzeError.parseError("正则分组解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 替换匹配的内容
    /// - Parameters:
    ///   - content: 原始内容
    ///   - rule: 正则表达式规则
    ///   - replacement: 替换字符串
    /// - Returns: 替换后的内容
    func replace(content: String, rule: String, replacement: String) throws -> String {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        let processedRule = preprocessRegexRule(rule)
        
        do {
            let regex = try NSRegularExpression(pattern: processedRule, options: [.caseInsensitive, .dotMatchesLineSeparators])
            return regex.stringByReplacingMatches(in: content, options: [], range: NSRange(location: 0, length: content.count), withTemplate: replacement)
        } catch {
            throw RuleAnalyzeError.parseError("正则替换失败: \(error.localizedDescription)")
        }
    }
    
    /// 检查是否匹配
    /// - Parameters:
    ///   - content: 文本内容
    ///   - rule: 正则表达式规则
    /// - Returns: 是否匹配
    func isMatch(content: String, rule: String) throws -> Bool {
        let results = try analyze(content: content, rule: rule)
        return !results.isEmpty
    }
}

// MARK: - Private Methods
private extension RegexAnalyzer {
    
    /// 预处理正则表达式规则
    /// - Parameter rule: 原始规则
    /// - Returns: 处理后的规则
    func preprocessRegexRule(_ rule: String) -> String {
        var processedRule = rule
        
        // 移除##前缀
        if processedRule.hasPrefix("##") {
            processedRule = String(processedRule.dropFirst(2))
        }
        
        return processedRule
    }
    
    /// 从匹配结果中提取文本
    /// - Parameters:
    ///   - content: 原始内容
    ///   - match: 匹配结果
    /// - Returns: 提取的文本
    func extractMatchResult(from content: String, match: NSTextCheckingResult) -> String? {
        // 优先返回第一个分组，如果没有分组则返回整个匹配
        let rangeIndex = match.numberOfRanges > 1 ? 1 : 0
        let range = match.range(at: rangeIndex)
        
        guard range.location != NSNotFound,
              let swiftRange = Range(range, in: content) else {
            return nil
        }
        
        return String(content[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
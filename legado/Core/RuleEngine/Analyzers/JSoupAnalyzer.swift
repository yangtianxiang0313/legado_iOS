//
//  JSoupAnalyzer.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import SwiftSoup

/// JSoup CSS选择器解析器
class JSoupAnalyzer: RuleAnalyzing {
    
    // MARK: - RuleAnalyzing协议实现
    
    /// 解析CSS选择器规则并返回文本数组
    func analyze(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try SwiftSoup.parse(content)
            let elements = try document.select(rule)
            
            return try elements.array().map { element in
                try element.text()
            }
        } catch {
            throw RuleAnalyzeError.parseError("JSoup解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 解析CSS选择器规则并返回第一个匹配结果
    func analyzeFirst(content: String, rule: String) throws -> String? {
        let results = try analyze(content: content, rule: rule)
        return results.first
    }
    
    /// 解析CSS选择器规则并返回Element数组
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try SwiftSoup.parse(content)
            let elements = try document.select(rule)
            return elements.array()
        } catch {
            throw RuleAnalyzeError.parseError("JSoup元素解析失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - JSoup特有功能扩展
extension JSoupAnalyzer {
    
    /// 获取元素的指定属性值
    /// - Parameters:
    ///   - content: HTML内容
    ///   - rule: CSS选择器规则
    ///   - attribute: 属性名
    /// - Returns: 属性值数组
    func getAttributes(content: String, rule: String, attribute: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try SwiftSoup.parse(content)
            let elements = try document.select(rule)
            
            return try elements.array().compactMap { element in
                let attrValue = try element.attr(attribute)
                return attrValue.isEmpty ? nil : attrValue
            }
        } catch {
            throw RuleAnalyzeError.parseError("属性解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 获取元素的HTML内容
    /// - Parameters:
    ///   - content: HTML内容
    ///   - rule: CSS选择器规则
    /// - Returns: HTML内容数组
    func getHtml(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try SwiftSoup.parse(content)
            let elements = try document.select(rule)
            
            return try elements.array().map { element in
                try element.html()
            }
        } catch {
            throw RuleAnalyzeError.parseError("HTML内容解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 获取元素的外部HTML（包含标签本身）
    /// - Parameters:
    ///   - content: HTML内容
    ///   - rule: CSS选择器规则
    /// - Returns: 外部HTML数组
    func getOuterHtml(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try SwiftSoup.parse(content)
            let elements = try document.select(rule)
            
            return try elements.array().map { element in
                try element.outerHtml()
            }
        } catch {
            throw RuleAnalyzeError.parseError("外部HTML解析失败: \(error.localizedDescription)")
        }
    }
}
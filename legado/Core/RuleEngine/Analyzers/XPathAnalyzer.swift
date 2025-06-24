//
//  XPathAnalyzer.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import Fuzi

/// XPath表达式解析器
class XPathAnalyzer: RuleAnalyzing {
    
    // MARK: - RuleAnalyzing协议实现
    
    /// 解析XPath表达式并返回文本数组
    func analyze(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try HTMLDocument(string: content)
            let nodes = document.xpath(rule)
            
            return nodes.compactMap { node in
                node.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
        } catch {
            throw RuleAnalyzeError.parseError("XPath解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 解析XPath表达式并返回第一个匹配结果
    func analyzeFirst(content: String, rule: String) throws -> String? {
        let results = try analyze(content: content, rule: rule)
        return results.first
    }
    
    /// 解析XPath表达式并返回XMLNode数组
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try HTMLDocument(string: content)
            let nodes = document.xpath(rule)
            return Array(nodes)
        } catch {
            throw RuleAnalyzeError.parseError("XPath元素解析失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - XPath特有功能扩展
extension XPathAnalyzer {
    
    /// 获取节点的指定属性值
    /// - Parameters:
    ///   - content: HTML/XML内容
    ///   - rule: XPath表达式
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
            let document = try HTMLDocument(string: content)
            let nodes = document.xpath(rule)
            
            return nodes.compactMap { node in
                node.attr(attribute)
            }.filter { !$0.isEmpty }
        } catch {
            throw RuleAnalyzeError.parseError("XPath属性解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 获取节点的原始HTML内容
    /// - Parameters:
    ///   - content: HTML/XML内容
    ///   - rule: XPath表达式
    /// - Returns: HTML内容数组
    func getRawHTML(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try HTMLDocument(string: content)
            let nodes = document.xpath(rule)
            
            return nodes.compactMap { node in
                node.rawXML
            }.filter { !$0.isEmpty }
        } catch {
            throw RuleAnalyzeError.parseError("XPath HTML解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 执行XPath表达式并返回数值结果
    /// - Parameters:
    ///   - content: HTML/XML内容
    ///   - rule: XPath表达式（如count()、sum()等）
    /// - Returns: 数值结果
    func evaluateNumber(content: String, rule: String) throws -> Double? {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            let document = try HTMLDocument(string: content)
            
            // 尝试执行XPath表达式并获取数值结果
            let result = document.xpath(rule)
            
            // 如果结果是数值类型的XPath函数结果
            if let firstNode = result.first,
               let numberValue = Double(firstNode.stringValue) {
                return numberValue
            }
            
            return nil
        } catch {
            throw RuleAnalyzeError.parseError("XPath数值计算失败: \(error.localizedDescription)")
        }
    }
    
    /// 检查XPath表达式是否有匹配结果
    /// - Parameters:
    ///   - content: HTML/XML内容
    ///   - rule: XPath表达式
    /// - Returns: 是否有匹配结果
    func hasMatch(content: String, rule: String) throws -> Bool {
        do {
            let document = try HTMLDocument(string: content)
            let nodes = document.xpath(rule)
            return !nodes.isEmpty
        } catch {
            throw RuleAnalyzeError.parseError("XPath匹配检查失败: \(error.localizedDescription)")
        }
    }
}
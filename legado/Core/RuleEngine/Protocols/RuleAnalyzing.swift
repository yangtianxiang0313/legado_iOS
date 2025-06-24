//
//  RuleAnalyzing.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// 规则解析器协议 - POP设计的核心协议
protocol RuleAnalyzing {
    /// 解析规则并返回字符串数组
    /// - Parameters:
    ///   - content: 待解析的内容
    ///   - rule: 解析规则
    /// - Returns: 解析结果字符串数组
    func analyze(content: String, rule: String) throws -> [String]
    
    /// 解析规则并返回第一个匹配结果
    /// - Parameters:
    ///   - content: 待解析的内容
    ///   - rule: 解析规则
    /// - Returns: 第一个匹配结果，如果没有匹配则返回nil
    func analyzeFirst(content: String, rule: String) throws -> String?
    
    /// 解析规则并返回元素数组（用于进一步处理）
    /// - Parameters:
    ///   - content: 待解析的内容
    ///   - rule: 解析规则
    /// - Returns: 解析得到的元素数组
    func analyzeElements(content: String, rule: String) throws -> [Any]
}

/// 规则类型检测协议
protocol RuleTypeDetecting {
    /// 检测规则类型
    /// - Parameter rule: 规则字符串
    /// - Returns: 检测到的规则类型
    func detectRuleType(_ rule: String) -> RuleType
    
    /// 验证规则是否有效
    /// - Parameters:
    ///   - rule: 规则字符串
    ///   - type: 期望的规则类型
    /// - Returns: 规则是否有效
    func isValidRule(_ rule: String, type: RuleType) -> Bool
    
    /// 规则预处理 - 移除前缀等
    /// - Parameter rule: 原始规则
    /// - Returns: 处理后的规则
    func preprocessRule(_ rule: String) -> String
}
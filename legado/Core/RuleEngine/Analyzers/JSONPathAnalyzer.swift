//
//  JSONPathAnalyzer.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

/// JSONPath表达式解析器
class JSONPathAnalyzer: RuleAnalyzing {
    
    // MARK: - RuleAnalyzing协议实现
    
    /// 解析JSONPath表达式并返回文本数组
    func analyze(content: String, rule: String) throws -> [String] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            // 解析JSON内容
            guard let jsonData = content.data(using: .utf8) else {
                throw RuleAnalyzeError.parseError("无法将内容转换为UTF-8数据")
            }
            
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 执行JSONPath查询
            let results = try executeJSONPath(rule: rule, on: jsonObject)
            
            // 将结果转换为字符串数组
            return results.compactMap { result in
                convertToString(result)
            }.filter { !$0.isEmpty }
            
        } catch {
            throw RuleAnalyzeError.parseError("JSONPath解析失败: \(error.localizedDescription)")
        }
    }
    
    /// 解析JSONPath表达式并返回第一个匹配结果
    func analyzeFirst(content: String, rule: String) throws -> String? {
        let results = try analyze(content: content, rule: rule)
        return results.first
    }
    
    /// 解析JSONPath表达式并返回原始对象数组
    func analyzeElements(content: String, rule: String) throws -> [Any] {
        guard !content.isEmpty else {
            throw RuleAnalyzeError.contentEmpty
        }
        
        guard !rule.isEmpty else {
            throw RuleAnalyzeError.ruleEmpty
        }
        
        do {
            guard let jsonData = content.data(using: .utf8) else {
                throw RuleAnalyzeError.parseError("无法将内容转换为UTF-8数据")
            }
            
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return try executeJSONPath(rule: rule, on: jsonObject)
            
        } catch {
            throw RuleAnalyzeError.parseError("JSONPath元素解析失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - JSONPath特有功能扩展
extension JSONPathAnalyzer {
    
    /// 获取JSON对象的指定键值
    /// - Parameters:
    ///   - content: JSON内容
    ///   - rule: JSONPath表达式
    ///   - key: 键名
    /// - Returns: 键值数组
    func getValues(content: String, rule: String, key: String) throws -> [String] {
        let elements = try analyzeElements(content: content, rule: rule)
        
        return elements.compactMap { element in
            if let dict = element as? [String: Any],
               let value = dict[key] {
                return convertToString(value)
            }
            return nil
        }.filter { !$0.isEmpty }
    }
    
    /// 检查JSONPath表达式是否有匹配结果
    /// - Parameters:
    ///   - content: JSON内容
    ///   - rule: JSONPath表达式
    /// - Returns: 是否有匹配结果
    func hasMatch(content: String, rule: String) throws -> Bool {
        let results = try analyze(content: content, rule: rule)
        return !results.isEmpty
    }
}

// MARK: - Private Methods
private extension JSONPathAnalyzer {
    
    /// 执行JSONPath查询
    /// - Parameters:
    ///   - rule: JSONPath规则
    ///   - jsonObject: JSON对象
    /// - Returns: 查询结果数组
    func executeJSONPath(rule: String, on jsonObject: Any) throws -> [Any] {
        let processedRule = preprocessJSONPathRule(rule)
        
        // 简单的JSONPath实现
        if processedRule == "$" {
            return [jsonObject]
        }
        
        // 处理根路径查询 $.key
        if processedRule.hasPrefix("$.") {
            let keyPath = String(processedRule.dropFirst(2))
            return try queryByKeyPath(keyPath: keyPath, in: jsonObject)
        }
        
        // 处理数组索引查询 $[0]
        if processedRule.hasPrefix("$[") && processedRule.hasSuffix("]") {
            let indexStr = String(processedRule.dropFirst(2).dropLast(1))
            if let index = Int(indexStr) {
                return try queryByIndex(index: index, in: jsonObject)
            }
        }
        
        // 处理通配符查询 $.*
        if processedRule == "$.*" {
            return try queryAllValues(in: jsonObject)
        }
        
        // 默认返回空数组
        return []
    }
    
    /// 通过键路径查询
    func queryByKeyPath(keyPath: String, in jsonObject: Any) throws -> [Any] {
        let keys = keyPath.split(separator: ".").map(String.init)
        var current: Any = jsonObject
        
        for key in keys {
            if let dict = current as? [String: Any] {
                guard let value = dict[key] else {
                    return []
                }
                current = value
            } else {
                return []
            }
        }
        
        if let array = current as? [Any] {
            return array
        } else {
            return [current]
        }
    }
    
    /// 通过索引查询
    func queryByIndex(index: Int, in jsonObject: Any) throws -> [Any] {
        if let array = jsonObject as? [Any] {
            guard index >= 0 && index < array.count else {
                return []
            }
            return [array[index]]
        }
        return []
    }
    
    /// 查询所有值
    func queryAllValues(in jsonObject: Any) throws -> [Any] {
        if let dict = jsonObject as? [String: Any] {
            return Array(dict.values)
        } else if let array = jsonObject as? [Any] {
            return array
        }
        return [jsonObject]
    }
    
    /// 预处理JSONPath规则
    func preprocessJSONPathRule(_ rule: String) -> String {
        var processedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 确保以$开头
        if !processedRule.hasPrefix("$") {
            processedRule = "$." + processedRule
        }
        
        return processedRule
    }
    
    /// 将任意对象转换为字符串
    func convertToString(_ object: Any) -> String {
        if let string = object as? String {
            return string
        } else if let number = object as? NSNumber {
            return number.stringValue
        } else if let bool = object as? Bool {
            return bool ? "true" : "false"
        } else if object is NSNull {
            return ""
        } else {
            // 对于复杂对象，尝试转换为JSON字符串
            do {
                let data = try JSONSerialization.data(withJSONObject: object, options: [])
                return String(data: data, encoding: .utf8) ?? ""
            } catch {
                return String(describing: object)
            }
        }
    }
}
//
//  RuleParser.swift
//  legado
//
//  规则切分器，按 ||、&&、%% 切分为规则段
//  对应 Android RuleAnalyzer.splitRule、book-source-rules §3-4
//

import Foundation

/// 规则段，切分后的一段规则
struct RuleSegment {
    /// 规则字符串（已 trim）
    let rule: String
}

enum RuleParser {

    private static let delimiters = ["%%", "||", "&&"]

    /// 按 ||、&&、%% 切分规则串，引号内及 []、() 内不切分
    /// - Parameter rule: 规则串，如 "a||b"、`class.x a@text||@css:.y`
    /// - Returns: 规则段列表
    static func splitRule(_ rule: String) -> [RuleSegment] {
        let trimmed = trimStart(rule)
        guard !trimmed.isEmpty else { return [] }
        let segments = split(trimmed)
        return segments.map { RuleSegment(rule: $0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.rule.isEmpty }
    }

    /// 修剪开头的 @ 或空白
    private static func trimStart(_ s: String) -> String {
        var i = s.startIndex
        while i < s.endIndex {
            let c = s[i]
            if c == "@" || c.isWhitespace || c < "!" {
                i = s.index(after: i)
            } else {
                break
            }
        }
        return String(s[i..<s.endIndex])
    }

    /// 查找从左到右第一个出现的分隔符位置，跳过引号内及 []、() 内
    private static func findFirstDelimiter(_ s: String, start: String.Index) -> (index: String.Index, delimiter: String)? {
        var pos = start
        var inSingleQuote = false
        var inDoubleQuote = false
        var bracketDepth = 0  // [ ]
        var parenDepth = 0    // ( )

        while pos < s.endIndex {
            let c = s[pos]

            if !inSingleQuote && !inDoubleQuote {
                if c == "[" { bracketDepth += 1 }
                else if c == "]" { bracketDepth -= 1 }
                else if c == "(" { parenDepth += 1 }
                else if c == ")" { parenDepth -= 1 }
                else if bracketDepth == 0 && parenDepth == 0 {
                    for d in delimiters {
                        if s[pos...].hasPrefix(d) {
                            return (pos, d)
                        }
                    }
                }
            }

            if c == "'" && !inDoubleQuote { inSingleQuote.toggle() }
            else if c == "\"" && !inSingleQuote { inDoubleQuote.toggle() }
            else if c == "\\" && (inSingleQuote || inDoubleQuote) {
                pos = s.index(after: pos)
                if pos >= s.endIndex { break }
            }

            pos = s.index(after: pos)
        }
        return nil
    }

    /// 切分，使用最早出现分隔符的类型
    private static func split(_ s: String) -> [String] {
        let startIdx = s.startIndex
        guard startIdx < s.endIndex else { return [] }

        guard let (delimPos, delimiter) = findFirstDelimiter(s, start: startIdx) else {
            let segment = String(s[startIdx..<s.endIndex])
            return segment.isEmpty ? [] : [segment]
        }

        var result: [String] = []
        var pos = startIdx
        let delimEnd = s.index(delimPos, offsetBy: delimiter.count)

        result.append(String(s[pos..<delimPos]))
        pos = delimEnd
        while pos < s.endIndex {
            guard let next = findFirstDelimiter(s, start: pos) else {
                result.append(String(s[pos..<s.endIndex]))
                break
            }
            if next.delimiter != delimiter {
                result.append(String(s[pos..<s.endIndex]))
                break
            }
            result.append(String(s[pos..<next.index]))
            pos = s.index(next.index, offsetBy: next.delimiter.count)
        }

        return result
    }
}
